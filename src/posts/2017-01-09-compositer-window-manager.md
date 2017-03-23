<!--
{
  "title": "Compositer/WIndow manager",
  "date": "2017-01-09T00:05:06.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- Compiz (Unity)
  - general architecture
    - x root window
    - child window management
      - layout
      - composiitng 
      - how hook stuff after child window rendering ?
    - threading
    - plugin architecture
        - #? registration
        - #? hook and dispatch
        - configuration file
    - process management (.desktop file)
    - other part (indicator, some lens panel things, ...)
    - build system (cmake)
  - play with compiz plugin first
    - plugins/move
      - opacity blending must use GL compositing.
  - Important data structures
    - screen
      - CompScreen, CompositeScreen
      - ScreenInterface, CompositeScreenInterface
      - XXXScreen (plugin)
    - window
      - CompWindow
      - GLWindowInterface
      - XXXWindow (plugin)

  - Main control path
    - main =>
      - CompManager::init =>
        - new CompScreenInpl =>
          - new PrivateScreen (Window root(None), Display* dpy (NULL))
          - CompPlugin::load ("core") (NOTE: core plugin is put under src/plugin.cpp, see src/CMakeLists.txt)
        - ::screen = screen.get() (set global variable)
        - CompScreenImpl::init =>
          - privateScreen.eventManager.init => mainloop = Glib::MainLoop::create ...
          - privateScreen.initDisplay =>
            - XOpenDisplay
            - sn_display_new, sn_monitor_context_new (I guess, those are from <libsn/sn.h> and sn stands for "startup notification")
            - Window root_tmp = XRootWindow (dpy, DefaultScreen (dpy));
            - root = root_tmp;
            - Window newWmSnOwner = XCreateWindow (dpy, root_tmp, -100, -100, 1, 1, 0, ...)
            - XChangeProperty (dpy, newWmSnOwner, Atoms::wmName, ...)
            - XCreateWindow (dpy, root_tmp, ...)
            - PrivateWindow::createCompWindow (...) ?
            - CompPlugin::screenInitPlugins (screen)
          - privateScreen.initPlugins => CompPlugin::load
        - CompSession::init => SmcbbOpenConnection (from X11/SM/SMlib.h) ?
      - CompManager::run => screen->eventLoop (NOTE: CompScreen screen is a global variable) =>
        - privateScreen.eventManager.startEventLoop =>
          - CompEventSource::create => new CompEventSource => connect (... &CompEventSource::callback...)
          - mainloop->run()

  - Window management
    - CompEventSource::callback => ... => screen->alwaysHandleEvent (&event) => ... => CompScreenImpl::_handleEvent (for CreateNotify XEvent) =>
      - PrivateWindow::createCompWindow =>
        - screen->insertWindow (this, aboveId)
        - screen->insertServerWindow (this, aboveServerId)
        - CompPlugin::windowInitPlugins(this)
    - ? window focusing (choosing one window to be active) and event dispatching to children
      - are we even intercepting all event ? (maybe, it's not always so)
      - PrivateScreen::handleActionEvent (dispatching event to plugins. not for general window children ?)
      - ? grabbing and XAllowEvents (replaying event) ? but I don't think it's healthy to do this everytime ?
        - I think it's fine for keyboard, pointer press/release interaction, but it's bad for pointer move kind of inherently continuous interface (MotionNotify).
      - Window *privateScreen.orphanData.activeWindow
      - ? (CompWindow *w)->focus
    - ? wtf is "server window" ?
      - this might be the compiz internal windows where you finally render stuff ? this might be "Composite Overlay Window" mentioned in Xcompose(3) ?

  - Window rendering/compositing (assume composite and opengl plugins)
    - X extensions:
      - composite, damage, randr (this too?), glx (of course)
      - Xcomposite: [man](ftp://www.x.org/pub/X11R7.7/doc/man/man3/Xcomposite.3.xhtml), [proto](https://cgit.freedesktop.org/xorg/proto/compositeproto/tree/compositeproto.txt)
      - no expose event ? (because how does xserver know window exposed ?)
      - "redirect" means WM makes clients to use off-screen rendering space transparently.
      - how does it nicely work with DRI ? (DRI does only matter for device dependent Drawable part, so I guess it does't affect much?)
      - what about damageext ?
      - what's the performance hit ?
      - what's extents ?
      - "overlay window" and "redirect to off-screen" is an orthogonal concept ?
      - general steps (WM perspective)
        - client render on off-screen (WM "redirect" clients to do so)
        - transform each client off-screen window (e.g. Negative (negate color)) and composite on overlay window of WM's window (root window) (e.g. Opacify)
    - combination with opengl
      - GLX_EXT_texture_from_pixmap to the rescue
        - WM can use client's off-screen window as opengl texture.
        - how complex can we go?
          - that's totally depends on compiz opengl interface, and of course it doesn't let us call arbitrary gl function.


    - composite and opengl plugins

      - data structure
        - CompositeScreen
          - class CompositeScreen : public WrapableHandler<CompositeScreenInterface, 8>
        - PrivateCompositeScreen
          - class PrivateCompositeScreen : ScreenInterface
          - Window output, overlay; (sounds like something #?)
          - DamageTracking  currentlyTrackingDamage;
          - std::map<Damage, XRectangle> damages;
        - CompositeWindow
        - PrivateCompositeScreen
          - Pixmap pixmap ()

      - initialization (see below for general plugin loading)

        - new CompositeScreen(CompScreen *s) =>
          - new PrivateCompositeScreen (CompositeScreen *cs) =>
            - ScreenInterface::setHandler (screen)
          - makeOutputWindow =>
            - output = overlay = XCompositeGetOverlayWindow (screen->dpy (), screen->root ())
            - hideOutputWindow =>
          - PrivateCompositeScreen::init =>
            - newCmSnOwner = XCreateWindow (dpy, screen->root (), ...)
        - new CompositeWindow(CompWindow *w) =>
          - new PrivateCompositeWindow (CompWindow *c, ...) =>
            - WindowInterface::setHandler (w)
          - priv->damage = XDamageCreate(...)

        - #? new GLScreen, new PrivateGLScreen, new GLWindow, new PrivateGLWindow
        - GLScreen::glInitContext => GLScreen::registerBindPixmap => CompositeScreen::registerPaintHandler (here pHnd is PrivateGLScreen) =>
          - XCompositeRedirectSubwindows (dpy, screen->root (), CompositeRedirectManual)
          - showOutputWindow =>
            - ? XFixesSetWindowShapeRegion ShapeBounding and ShapeInput to output window (root overlay window)
            - damageScreen
        - #? => PrivateGLScreen::paintOutputRegion or GLWindow::glDraw => GLWindow::bind => CompositeWindow::bind =>
          - CompositeWindow::redirect =>
            - XCompositeRedirectWindow
            - showOutputWindow/updateOutputWindow
          - PrivateCompositeWindow::bind => mPixmapBinding.bind

      - compositing/rendering mechanism
        - how many opengl context do we use ?
          - 1 + n (root window overlay + the number of child windows)
        - how do WM know when client renders ? (X damage extension)
           - PrivateCompositeScreen::handleEvent (case event->type == damageEvent + XDamageNotify) => CompositeWindow::processDamage  
        - CompositeWindow::addDamage/addDamageRect/DamageRegion/... => screen->damageRegion
        - CompositeScreen::damageScreen/damageRegion => scheduleRepaint => CompositeScreen::handlePaintTimeout =>
          - preparePaint
          - ? some damage processing
          - paint => paintOutputs => PrivateGLScreen::paintOutputs =>
            - #?
          - donePaint
      - how to determine final screen image

    - plugin opengl
      - let's forget this because opengl is just one of rendering interface (it can be done even cpu)
    - plugin move (as an example plugin using composite and opengl)
      - (roughly) handle event => initiate move => paint ?
      - interface hooks
        - MoveScreen::handleEvent (from ScreenInterface)
          - moveInitiate (called for configured button combination or normal move window event (ClientMessage with Atoms::wmMoveResize))
          - moveHandleMotionEvent (called for MotionNotify after moveInitated and before moveTerminated)
        - MoveWindow::glPaint (from GLWindowInterface)
          - #? when is it called ?
      - moveInitiate =>
        - grab pointer ?
          - when to release ?
        - mw->cWindow->addDamage () ?
        - mw->gWindow->glPaintSetEnabled (mw, true) ?  
      - moveHandleMotionEvent (some snapping processing and w->move)

  - Plugin management

    - General plugin initialization steps
      - cps::PluginManager::updatePlugins (CompPlugin::load when plugin is not dl'ed yet) => CompManager::push => CompManager::initPlugin =>
        - p->vTable->init ()
        - p->vTable->initScreen (screen)
        - screen->initPluginForScreen (p) => _initPluginForScreen => p->vTable->initWindow (w)
      - CompPlugin::load => dlloaderLoadPlugin =>
        - dlsym("getCompPluginVTable20090315_XXX")
        - setup (CompPlugin *p)->vTable
      - when plugin class is instantiated ? (this depends on the class of vTable (e.g. VTableForScreenAndWindow, VTableForScreen))
        - VTableForScreenAndWindow::initScreen<Tplugin, Tbase, ..> => PluginClassHandler::get (via Tplugin::get) => PluginClassHandler::getInstance => new Tplugin

    - Intricate of PluginClassHandler, Wrapable,
      - PluginClassHandler takes template arguments as base class (e.g. CompWindow, CompScreen) and its inherited class which represents a plugin (e.g. CompositeWindow, CompositeScreen)
        - when its instantiated, base class keeps plugin classes as pluginClasses (base class has to inherit from PluginClassStorage)
      - WrapableInterface/WrapableHandler: http://wiki.compiz.org/Development/zero-nine/Interfaces
        - this is the trick to hook plugin's function