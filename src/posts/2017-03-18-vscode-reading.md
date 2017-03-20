<!--
{
  "title": "VS Code, reading source",
  "date": "2017-03-18T22:43:32+09:00",
  "category": "",
  "tags": ["source"],
  "draft": true
}
-->

# Browser process (a.k.a. electron-main) initialization

```
- (vs/code/electron-main/main.ts) start =>
  - createServices => new InstantiationService
- setupIPC => ?
- main =>
  - new ElectronIPCServer
  - new SharedProcess
  - IWindowsMainService.open =>
    - openInBrowserWindow =>
      - new VSCodeWindow =>
        - new BrowserWindow
      - VSCodeWindow.load =>
        - BrowserWindow.loadURL("vs/workbench/electron-browser/bootstrap/index.html?config=...")
  - SharedProcess.spawn => ?
```

# Renderer (a.k.a. electron-browser, browser) initialization

```
- (vs/workbench/electron-browser/bootstrap/index.js) main =>
  - (vs/workbench/electron-browser/main.js) startup =>
    - getWorkspace
    - openWorkbench =>
      - new WorkbenchShell
      - WorkbenchShell.open
        - createContents =>
          - new Workbench
          - Workbench.startup =>
            - createWorkbench (DOM setup)
            - initServices =>
               - instantiate many things, e.g. :
                 -  ContextKeyService, WorkbenchKeybindingService
                 - SidebarPart, ViewletService, PanelPart, EditorPart, WorkbenchEditorService
               - WorkbenchContributionsRegistry.setInstantiationService
            - initSettings (check initial UI component visibility)
            - renderWorkbench =>
	      - createTitlebarPart, createActivityBarPart, createSidebarPart, ...
              - this.workbenchContainer.build (mount on DOM with Node.appendChild)
            - createWorkbenchLayout => new WorkbenchLayout (with passing all of those parts)
            - ViewletService.openViewlet =>
              - SidePart.openViewlet =>
                - (in Promise) openComposite (as CompositePart) => doOpenComposite =>
                  - createComposite => new ExplorerViewlet
                  - showComposite =>
                    - create offDOM "#workbench.view.explorer"
                    - compositeContainer.build
            - (in Promise) EditorPart.openEditors or restoreEditors (for clean session, it does nothing)
          - new ElectronWindow (holding BrowserWindow got from remote.getCurrentWindow)
      - layout =>
        - WorkbenchShell.contentsContainer.size (set some div's physical width and height to viewport size)
        - Workbench.layout => WorkbenchLayout.layout =>
          - literally calculate physical size of parts (e.g. sidebarSize, editorSize) and apply them to on-DOMs
          - then go into laying out content of each part, e.g.
            - EditorPart.layout =>
              - Part.layout (as super) => PartLayout.layout
            - SidebarPart.layout (as CompositePart)
      - registerListeners (register layout on window resize)
```

# UI component

- `Part`: content with optional title (e.g. `EditorPart`)
- `CompositePart`: extends `Part` having replaceable `Composite` as content (e.g. `SidebarPart`, `PanelPart`)
- `Composite`: rendered inside of CompositePart (e.g. `ExplorerViewlet`)
- `Panel`: extends `Composite` for `PanelPart` (e.g. `TerminalPanel`, `OutputPanel`, `BaseEditor`)
- `WorkbenchComponent`:  base class `Part` and `Composite` (for book-keeping UI object?)


# Workbench parts preview

```
[One liner to preview node hierarchy with arbitrary depth]
> var f = (node, depth) => ({
    class: (node.classList && Array.from(node.classList).join(', ')),
    children: (depth > 0 ? Array.from(node.childNodes).map(c => f(c, depth - 1)) : "...")
  })
> JSON.stringify(f(document.body, 5), null, 2)
...
  "class": "monaco-shell, vs-dark, vscode-theme-defaults-themes-dark_plus-json", // WorkbenchShell.container
      "class": "monaco-shell-content",
          "class": "",                                                           // Workbench.container (== WorkbenchShell.contentsContainer)
              "class": "monaco-workbench-container",                             // Workbench.workbenchContainer
                  "class": "monaco-workbench, linux, nopanel",
                      "class": "part, titlebar, builder-hidden, blurred",
                      "class": "part, activitybar, left, builder-hidden",
                      "class": "part, sidebar, left",
                      "class": "part, editor, monaco-editor-background",
                      "class": "part, panel, monaco-editor-background",
                      "class": "part, statusbar",
                      "class": "monaco-sash, vertical",
                      "class": "monaco-sash, horizontal",
                      "class": "quick-open-widget, show-file-icons, commands-handler, builder-hidden",
      "class": "aria-container",
      "class": "context-view, builder-hidden",
...
```


# Editor (Part) initialization

```
== Setup ==

- workbench.main.ts imports vs/editor/browser/editor.all
- ExplorerViewlet.addExplorerView =>
  - DelegatingEditorService.setEditorOpenHandler
    - (set handler as ExplorerViewlet.editorService.openEditor)


== Call stack ==

(User clicks file on explorer sidebar (I opened tslint.json in vscode repo))
- TreeView.onClick => ... =>
  - FileController.openEditor (ExplorerViewer.ts) => ... (delegation as above setup) =>
    - WorkbenchEditorService.openEditor => doOpenEditor =>
      - EditorPart.openEditor =>
        - EditorRegistry.getEditor (returns EditorDescriptor, which says 'TextFileEditor')
        - doOpenEditor =>
          - EditorGroup.openEditor => EditorGroup.setActive
          - doShowEditor =>
            - doCreateEditor =>
              - doInstantiateEditor => new TextFileEditor
              - BaseEditor.create (as TextFileEditor) =>
                - TextEditor.createEditor (as TextFileEditor) => (GO BELOW [1])
            - EditorGroupsControl.show =>
              - TextFileEditor.getContainer().build (on DOM ".container" of first silo)
              - layoutContainers =>
                - update style of DOM
                - layoutEditor =>
                  - TextEditor.layout (as TextFileEditor) =>
                    - CodeEditorWidget.layout => render (do nothing because of !CodeEditorWidget.hasView)
                - tabsTitleControl.layout
            - EditorGroupsControl.layoutEditor (you did already...)
          - doSetInput (setup conten's input source (this case, it's file system)) =>
            - TextFileEditor.setInput =>
              - FileEditorInput.resolve =>
                - ITextFileEditorModelManager.loadOrCreate (some async file read ?)
              - (after file read as TextFileEditorModel) CommonCodeEditor.setModel (as CodeEditor) =>
                - CodeEditorWidget._attachModel =>
                  - CommonCodeEditor._attachModel (super) =>
                    - CodeEditorWidget._createView => new View => (GO BELOW [2])
                  - ".editor-container".appendChild(".monaco-editor")
                  - View.addContentWidget (on-DOM bunch of widgets)
                  - View.render(false, true) =>
                    - only set `forceShouldRender` (after View.render(true, false) for initial window resize. SEE BELOW [3])

[1]
- TextEditor.createEditor =>
  - createEditorControl => new CodeEditor =>
    - (super) CodeEditorWidget =>
      - (super) CommonCodeEditor =>
        - initialize fromEventEmitter and others
      - instantiate contributions from EditorBrowserRegistry and CommonEditorRegistry
      - instantiate editor actions from CommonEditorRegistry => new InternalEditorAction
      - AbstractCodeEditorService.addCodeEditor(this)
  - register event listeners on CodeEditor

[2]
- new View =>
  - new ViewEventDispatcher (with View._renderOnce callback, which later LayoutProvider triggers)
  - new LayoutProvider (some line layout and scroll master) =>
    - _updateHeigh => Scrollable.updateState => _onScroll.fire => .... =>
      - View._renderOnce => _scheduleRender (requestAnimationFrame for _flushAccumulatedAndRenderNow, SEE BELOW [3])
  - createTextArea
  - createViewParts => prepare DOM widgets on ".monaco-editor"
  - _setLayout =>

[3]
- animationFrameRunner => ... =>
  - View._flushAccumulatedAndRenderNow =>
    - _renderNow => _actualRender =>
      - ViewLines.renderText => VisibleLinesCollection.renderLines =>
        - new ViewLayerRenderer
        - ViewLayerRenderer.render =>
          - ViewLines.createVisibleLine => new ViewLine
          - _finishRendering =>
            - (for each line) ViewLine.renderLine =>
              - ViewportData.getViewLineRenderingData (returns ViewLineRenderingData which includes line literally content)
              - new RenderLineInput (with just gotten ViewLineRenderingData)
              - renderViewLine =>
                - resolveRenderLineInput => new ResolvedRenderLineInput
                - _renderLine (returns new RenderLineOutput ("<span><span class="mtk1">{</span></span>" for tslint.json))
              - returns "<div style="top:0px;height:19px;" class="view-line"><span><span class="mtk1">{</span></span></div>"
            - _finishRenderingNewLines =>
              - set `.view-lines`'s innerHTML as rendered lines above (on-DOM)
      - new RenderingContext
      - (for each view part) ViewPart.render (e.g. EditorScrollbar.render)


== Class hierarchy ==

- Panel (vs/workbench/browser)
  - BaseEditor (vs/workbench/browser/parts/editor)
    - BaseTextEditor
      - TextFileEditor (vs/workbench/parts/files/browser/editors)

- Part
  - EditorPart

- CommonCodeEditor (vs/editor/browser)
  - CodeEditorWidget (implements ICodeEditor)
    - CodeEditor


== DOM tree ==

JSON.stringify(f(document.querySelector('.part.editor'), 5), null, 2)
"{
  "class": "part, editor, monaco-editor-background, empty",
      "class": "content, vertical-layout",
          "class": "watermark",
              "class": "watermark-box",
              "children": [
          "class": "one-editor-silo, editor-one, monaco-editor-background, builder-hidden",
              "class": "container",
                  "class": "title, tabs, show-file-icons",
                      "class": "monaco-scrollable-element",
                      "class": "editor-actions",
                  "class": "progress-container, builder-hidden",
                      "class": "progress-bit",
                  "class": "editor-container", // <= id: workbench.editors.files.textFileEditor
                      "class": "monaco-editor vs-dark vscode-theme-defaults-themes-dark_plus-json",
                         => ".overflow-guard" => ".monaco-scrollable-element" =>
                           => ".lines-content" => ".view-lines" => ".view-line"
          "class": "monaco-sash, vertical, builder-hidden",
          "class": "one-editor-silo, editor-two, monaco-editor-background, builder-hidden",
          "class": "monaco-sash, vertical, builder-hidden",
          "class": "one-editor-silo, editor-three, monaco-editor-background, builder-hidden",
          ...
}"
```


# "Contribution" architecture

For example, `WorkbenchContribution` and `WatermarkContribution`

```
- "workbench.main.ts" imports "vs/workbench/parts/watermark/electron-browser/watermark.ts
  - WatermarkContribution is defined extending IWorkbenchContribution
    - constructor represents vscode subsystem dependencies (e.g. keybindingService, partService)
    - service provides interface what Watermark needs:
      - partService.joinCreation: provide hook entry triggered when all parts have been created
      - partService.getContainer(Parts.EDITOR_PART): DOM entry point watermark renders
      - keybindingService.lookupKeybinding: get information about current keybinding
  - WorkbenchContributionsRegistry.registerWorkbenchContribution(WatermarkContribution)
```


# Debugging setup

Code breakpoint

- Run `./script/code-cli.sh --verbose .`
- Open devtool and add breakpoint around workbench initilization (e.g. `Workbench.startup`)
- Run command pallete "Reload Window"

DOM breakpoint

- for example, if you cannot figure out how monaco editor DOM is initialized, you can
  set DOM breakpoint to its container `".editor-container"` and wait for `appendChild` kinds of things.


# IDE 101

TODO: follow implementations of

- syntax highlight
- keyboard/mouse shortcut
- symbol resolution
    - autocomplete
- file search
- word search


# Q

Q. Worker

```
(vs/base/common/worker/workerMain.ts)
Q. how is it loaded ?
Q. purpose

- ? => new WebWorker
```

Q. --type=watcherService


# Extension architecture

```
[Renderer]
- WorkbenchShell.open => createContents => initServiceCollection =>
  - new ExtensionHostProcessWorker
  - extensionHostProcessWorker.start =>
    - tryListenOnPipe =>
      - createServer (from node)
      - server.listen on generateRandomPipeName unix socket
    - fork 'code-oss out/bootstrap --type=extensionHost' with some environment variables
      - AMD_ENTRYPOINT: vs/workbench/node/extensionHostProcess
      - VSCODE_IPC_HOOK_EXTHOST: unix socket generated above
    - register logExtensionHostMessage on 'message'
    - tryExtHostHandshake =>
      - server.on('connection')
      - new Protocol
      - Protocol.onMessage
        - 'ready' => createExtHostInitData and Protocol.send
        - 'initialized' => LazyMessagePassingProtol.resolve

[Forked process (--type=extensionHost)]
- out/bootstrap.js => vs/workbench/node/extensionHostProcess.ts (from AMD_ENTRYPOINT) =>
  - createExtHostProtocol =>
    - createConnection on VSCODE_IPC_HOOK_EXTHOST
    - new Protocol with connected socket (from node/ipc.net.ts)
  - connectToRenderer =>
    - register onMessage with
      - createProxyProtocol => ?
      - Protocol.send('initialized')
    - Protocol.send('ready')
  - new ExtensionHostMain =>
    - new ExtHostExtensionService
  - ExtensionHostMain.start =>
    - ExtHostExtensionService.onReady
    - handleEagerExtensions =>
      - activateByEvent('*')
      - handleWorkspaceContainsEagerExtensions => activateByEvent('workspaceContains...')
  - ... later on just communicate on protocol
```


Follow CSS (kept in the same repo under extensions/css). Smart functionality is provided from
vscode-css-languageservice (https://github.com/Microsoft/vscode-css-languageservice).

```
[Setup]
Q. when to load extension's package.json ?
- ? => (read package.json)
- ? => (read client/out/cssMain.js) =>
  -

[Activation]
Q. where's the hook to call `activate` function of main file specified in package.json ?
Q. lifecycle of `vscode.ExtensionContext`
Q. Server ? how is this process launched ?

(client)
- ? => activate =>
  - construct ServerOptions and LanguageClientOptions (both from package vscode-languageclient)
  - new LanguageClient
  - LanguageClient.start => ?
  - (onReady) =>

(server)
- ? => (read server/out/cssServerMain.js) =>
  - createConnection (from vscode-languageserver)
  - new TextDocuments
  - TextDocuments.listen
  - register IConnection.onInitialize
  - register IConnection.onHover
  - IConnection.listen

[Action]
(user hovers some css property)

(server)
- ? =>
  - IConnection.onHover =>
    - LanguageService.doHover => ?

(client)
- ?
```


# Wishlist

- sidebar scrollability
- add entry to context menu
- keyboard shortcut outside of text editor (e.g. quick view or explorer)


# Future work

- Promise implementation
- More Chromium internal
