<!--
{
  "title": "Atom Editor",
  "date": "2017-04-16T11:22:02+09:00",
  "category": "",
  "tags": ["editor", "source"],
  "draft": false
}
-->

# Build from source

```
$ mkdir -p _install
$ ./script/build --install $PWD/_install
$ ln -s $PWD/_install/bin/atom ~/.local/bin
$ atom .
```


# Development (Debugging renderer javascript)

```
$ mkdir -p $PWD/_install/dev
$ ATOM_DEV_RESOURCE_PATH=$PWD ATOM_HOME=$PWD/_install/dev/.atom atom -f --socket-path $PWD/_install/dev/atom.sock --dev --profile-startup .
```

Note:

- --profile-startup opens chromium devtools on startup and it helps injecting debugger anywhere you want.
- By specifing non-default --socket-path, you can create different instance of atom application with same version.


# Code Reading

```
[ Browser process ]
- src/main-process/main.js => start.js =>
  - AtomApplication.open (atom-application.coffee) =>
    - if `net.connect(..socketPath)`` works, send current options to existing app,
    - otherwise, new AtomApplication and initialize. =>
      - constructor =>
        - new Config, FileRecoveryService, StorageFolder, AutoUpdateManager, CompositeDisposable
        - handleEvents => ?
      - initialize =>
        - new ApplicationMenu
        - new AtomProtocolHandler => registerAtomProtocol => electron.protocol.registerFileProtocol('atom', ...)
        - listenForArgumentsFromNewProcess (listen for next `net.connect( socketPath )`)
        - launch => openWithOptions => openPaths =>
          - new AtomWindow =>
            - new BrowserWindow
            - handleEvents => ?
            - BrowserWindow.loadURL(...static/index.html)
            - openLocations =>
              - register browserWindow.webContents.send('message', 'open-locations') on browserWindow's 'window:loaded'

[ Render process (static/index.html, index.js) ]
- (index.js) window.onload => setupWindow =>
  - require('../src/compile-cache') =>
  - CompileCache.install => (patch `require.extensions` to be able to require .coffee file)
  - require("../src/initialize-application-window.coffee") =>
    - global.atom = new AtomEnvironment =>
      - this.applicationDelegate = new ApplicationDelegate
      - new Config, CommandRegistry, GrammarRegistry, StyleManager, PackageManager, Project
      - new Workspace =>
        - createCenter => new WorkspaceCenter
        - createDock => new Dock
        - new PanelContainer
      - registerDefaultCommands =>
        - CommandRegistry.prototype.add('atom-workspace', ...)
  - (initialize-application-window.coffee's exports function) =>
    - AtomEnvironment.prototype.initialize =>
      - Config.prototype.load
      - StyleManager.prototype.buildStylesElement =>
        - new StylesElement (extends HTMLElement and registered as <atom-style>)
      - document.head.appendChild <atom-style>
    - AtomEnvironment.prototype.startEditorWindow =>
      - (promise loadState and displayWindow) =>
        - register onDidOpenLocations (call AtomEnvironment.prototype.openLocations on 'open-locations' message)
        - PackageManager.prototype.loadPackages (SEE BELOW)
        - document.body.appendChild @workspace.getElement
        - PackageManager.prototype.activate (SEE BELOW)
        - loadUserKeymap
        - requireUserInitScript
        - openInitialEmptyEditorIfNecessary
  - then, electron.ipcRenderer.send('window-command', 'window:loaded')


[ IPC example (browser side AtomWindw)]
(browser side module is AtomWindow and renderer side module is ApplicationDelegate)

- (browser)
  - BrowserWindow.loadURL(...static/index.html)

- (renderer)
  - send('window-command', 'window:loaded')

- (browser)
  - AtomWindow.prototype.resolveLoadedPromise() => send('message', 'open-locations')

- (renderer)
  - AtomEnvironment.prototype.openLocations ...


[ Package loading and activation ]
- PackageManager.prototype.loadPackages =>
  - getAvailablePackages =>
    - add package from (<atom-home>/packages/<package-name>)
    - add package from packageDependencies in package.json (<atom-resource-path>/node_modules/<package-name>)
  - loadAvailablePackage =>
    - new Package
    - package.load =>
      - (read keymap cson and others ...)
      - requireMainModule =>
        - getMainModulePath (package.json's main or index)
        - this.mainModule = require(...)

- PackageManager.prototype.activate =>
  - packageManager.activatePackages => activatePackage => package.activate => activateNow =>
    - this.mainModule.activate (e.g. WelcomePackage.prototype.activate) =>
      - async welcomPackage.activate =>
        - atom.workspace.addOpener for 'atom://welcome/consent', which calls welcomPackage.createConsentView
        - await atom.workspace.open('atom://welcome/consent') (if consent agreement is not done yet)


[ Workspace ]
- Workspace.prototype.constructor =>
  - createCenter => new WorkspaceCenter => ?
  - createDock (x 3) => new Dock => ?
  - paneContainers = { center, left, right, bottom }
  - activePaneContainer = center
  - new PanelContainer (x 7) => ?
  - panelContainers = { top, left, right, bottom, header, footer, modal }

- Workspace.prototype.open(url) =>
  - getActivePaneContainer (returns WorkspaceCenter or Dock ?)
  - workspaceCenter.getActivePane => paneContainer.getActivePane
  - (check if itemExistsInWorkspace. if not, continue)
  - createItemForURI =>
    - call existing openers for given uri and check if any of them corresponds to it
    - (for example, welcomePackage.createConsentView will be returned for 'atom://welcome/consent')
    - otherwise openTextFile =>
      - (check file read permission and size etc..)
      - project.bufferForPath =>
        - buildBuffer =>
          - new TextBuffer (from text-buffer 3rd-party lib)
          - textBuffer.load
      - then textEditorRegistry.build =>
        - grammarRegistry.selectGrammar => ...
        - new TextEditor (SEE BELOW)
  - pane.activateItem =>
    - addItem =>
      - emit 'did-add-item' => tabBarView.addTabForItem
      - paneContainer.didAddPaneItem => emit('did-add-pane-item', ...)
      - setActiveItem =>
        - emit 'did-change-active-item' => paneElement.activeItemChanged =>
          - viewRegistry.getView => createView => (e.g. consentView.element (div.welcome))
          - "div.item-views" appendChild "div.welcome"
          - showItemView
          - "div.welcome".focus
      - paneContainer.didChangeActiveItemOnPane => emit('did-change-active-pane-item')
  - pane.activate =>
    - paneContainer.didActivatePane => emit('did-activate-pane') =>
      - (for example of Dock and TreeView)
        - dock.show => setState(visible) => render =>
          - "div.atom-dock-inner" add class "atom-dock-open"
          - (add width to some other DOMs to make it visible)


[ TreeView package ]
- treeViewPackage.activate =>
  - project.onDidChangePaths createOrDestroyTreeViewIfNeeded

- atomEnvironment.openLocations =>
  - project.addPath => emit 'did-change-paths' =>
    - treeViewPackage.createOrDestroyTreeViewIfNeeded =>
      - new TreeView => ?
      - workspace.open(treeView)

- (user clicks file from tree-view in dock) =>
  - treeView.entryClicked => fileViewEntryClicked => atom.workspace.open
```


# TextEditor

```
(from workspace.open => createItemForURI)
- new TextEditor => ?

(from workspace.open => pane.activateItem => ...)
- textEditor.element => getElement =>
  - new TextEditorElement =>
  - textEditorElement.initialize => setModel =>
    - initializeContent => appendChild "div.editor--private"
    - mountComponent =>
      - new TextEditorComponent =>
        - new TextEditorPresenter
        - "div.editor-contents--private" appendChild "div.scroll-view"
        - new InputComponent
        - new LinesComponent (extends TiledComponent) =>
          - domNode = createElement "div.lines"
          - tilesNode = createElement "div" with style "isolation: isolate;"
        - updateSync => ...
      - "div.editor--private" appendChild "div.editor-contents--private"

- "div.item-views" appendChild "atom-text-editor" =>
  - textEditorElement.attachedCallback =>
    - textEditorComponent.checkForVisibilityChange => becomeVisible =>
      - this.editor.setVisible(true) => tokenizedBuffer.setVisible =>
        - tokenizeInBackground => set timer for tokenizeNextChunk (SEE BELOW)
      - updateSync =>
        - updateSyncPreMeasurement =>
          - presenter.getPreMeasurementState => ??
          - TiledComponent.prototype.updateSync (as linesComponent) =>
            - updateTileNodes =>
              - buildComponentForTile => new LinesTileComponent
              - this.tilesNode appendChild LinesTileComponent
              - LinesTileComponent.updateSync => updateLineNodes =>
                - (for each line on this tile)
                  - buildLineNode =>
                    - (NOTE: at this point, "lineState" doesn't include tag for syntax highlighting)
                    - create element of span.syntax--source.syntax--js "6  + 24"
                  - domNode.appendChild(lineNode) (div appendChild div.line)
        - gutterContainerComponent.updateSync =>
        - linesComponent.updateSync


(Syntax highlight)
for example, test.js:

-----------
6  + 24

-----------

produces DOM:

div.line
  span.syntax--source.syntax--js
    span.syntax--constant.syntax-numeric.syntax--decimal.syntax--js "6"
    "  "
    span.syntax-keyword.syntax--operator.syntax--js "+"
    " "
    span.syntax--constant.syntax-numeric.syntax--decimal.syntax--js "24"

which is generated from a kind of packed line data:

{
  lineText: "1 + 1",
  tagCodes: [    (DisplayLayer knows how to translate these tags (e.g. tagsByCode))
    -1,        | -1 => syntax--source.syntax--js
      -3,      | -3 => syntax--constant.syntax--numeric.syntax--decimal.syntax--js
        1,     | text length of "6"
        -4,    | close tag for (-3)
      2,       | text length of "  "
      -5,      | -5 => syntax--keyword.syntax--operator.syntax--js
        1,     | text length of "+"
        -6,    | close tag for (-5)
      1,       | text length of " "
      -3,      |
        2      | text length of "24"
        -4,    |
      -2       | close tag for (-1)
  ]
}

- tokenizedBuffer.tokenizeNextChunk (timer set during textEditorComponent.becameVisible) =>
  - this.tokenizedLines[n] = buildTokenizedLineForRow =>
    - buildTokenizedLineForRowWithText =>
      - grammer.tokenizeLine (first-mate (3rd party lib) implements)
      - new TokenizedLine (with the result you got from grammer.tokenizeLine)
  - emit 'did-invalidate-range' =>
    - (displayLayer.setTextDecorationLayer had registered callback onDidInvalidateRange)
      - emitDidChangeSyncEvent => emit 'did-change-sync' =>
        - (textEditorPresenter.observeModel had registered callback onDidChangeSync) =>
          - emitDidUpdateState =>
            - (new TextEditorComponent had registered requestUpdate callback onDidUpdateState)
            - textEditorComponent.requestUpdate (SEE BELOW)
        - (here, textEditor emit 'did-change' (for public use) too)

- textEditorComponent.requestUpdate =>
  - viewRegistry.updateDocument =>
    - documentWriters.push(textEditorComponent.updateSync ...)
    - requestDocumentUpdate => requestAnimationFrame(performDocumentUpdate)

- viewRegistry.performDocumentUpdate =>
  - (call each this.documentWriters) =>
    - textEditorComponent.updateSync =>
      - (NOTE: this second time will buildLineNode with syntax highlight)
      - updateSyncPreMeasurement =>
        - textEditorPresenter.getPreMeasurementState =>
          - updateLines (SEE BELOW)
          - updateTilesState

- textEditorComponent.updateLines =>
  - (for each pair of startRow and endRow (i.e. each tile ?))
    - displayLayer.getScreenLines =>
      - screenLineBuilder.buildScreenLines =>
        - displayLayer.textDecorationLayer.buildIterator =>
          - (new TextEditor setTextDecorationLayer to TokenizedBuffer)
          - new TokenizedBufferIterator
        - tokenizedBufferIterator.seek =>
          - tokenizedBuffer.tokenizedLineForRow =>
            - new TokenizedLine (with initial `tags` as [-1, text's length, -2]) (if this is not made yet)
            - NOTE:
                tokenizedBufferIterator keeps global context concerning which tag
                is left open up until this single line. `seek` returns it.
        - NOTE:
            here screenLineBuilder will emitOpenTag, emitText, and emitCloseTag interacting with tokenizedBufferIterator
            and constructs a tuple of  { id, lineText, tagCodes }.
            tokenizedBufferIterator is responsible for tokenizing file content "as it is".
            but, screenLineBuilder does additional processing (e.g. softwap, tab indent width, etc..) on top of that.
  - this.linesByScreenRow.set


(Text input)
- new TextEditorComponent =>
  - listenForDOMEvents =>
    - addEventListener 'textInput', @onTextInput
    - (and mouse event too)

- textEditorComponent.onTextInput =>
  - editor.insertText => mutateSelectedText =>
    - (here comes pretty heavy looking transactional thing, but simply)
    - (for each selection)
      - selection.insertText =>
        - editor.buffer.setTextInRange => applyChange =>
          - ...
          - emitDidChangeEvent =>
            - (looks event system is a bit unorganized... like, I guess this order matters.)
            - textDecorationLayer.bufferDidChange (e.g. tokenizedBuffer) => tokenizedBuffer.bufferDidChange =>
              - invalidate some data and `buildTokenizedLinesForRows` again
            - displayLayer.bufferDidChange => returns efficient change set ?
            - displayLayer.emitDidChangeSyncEvent => ... will reach textEditorComponent.updateSync as ABOVE
      - emitter.emit 'did-insert-text' (this is for public use)

- Q. does workspace (or body) stopPropagation on capture phase in any case ?


(TextEditorElement DOM overview)
ATOM-TEXT-EDITOR.editor
  DIV.editor--private                     <-- textEditor.rootElement
      DIV.editor-contents--private        <-- textEditorComponent.domNode
          DIV.gutter-container
              DIV.gutter
                  DIV.line-numbers
                      DIV.line-number ...
                      DIV ...
                      ...
          DIV.scroll-view                 <-- textEditorComponent.scrollViewNode
              INPUT.hidden-input          <-- InputComponent (this input DOM is focused and listen 'textInput' Event)
              DIV.lines                   <-- LinesComponent (extends TiledComponent)
                  DIV                     <-- style="isolation: isolate;"
                      DIV ...             <-- LinesTileComponent
                        DIV
                          DIV.highlights  <-- HighlightsComponent
                          DIV.line
                            SPAN.syntax--source ...
                          DIV.line
                          ...
                      DIV ...             <-- LinesTileComponent
                      ...                 <-- ...  
                  DIV.cursors.blink-off
                      DIV.cursor ...
                  DIV.wrap-guide
              DIV
              DIV.horizontal-scrollbar
                  DIV.scrollbar-content
          DIV.vertical-scrollbar
              DIV.scrollbar-content
```


# Workspace DOM tree

Pretty print document tree until certain depth:

```
> var f = (node, depth) => {
    var tag = node.nodeName;
    var classes = (node.classList && Array.from(node.classList).map(c => '.' + c).join(''));
    var children = depth > 0 ? Array.from(node.childNodes).filter(n => n.nodeName !== '#text').map(n => f(n, depth - 1)) : "...";
    return { [tag + classes]: children };
  }
> console.log(
    JSON.stringify(f(document.body, 7), null, 2)
    .replace(/[\{\}\[\]\,\"\:]/g, '')
    .split('\n')
    .filter(line => !line.match(/^(\ )*$/))
    .join('\n')
  )
BODY.platform-linux.is-blurred
  ATOM-WORKSPACE.workspace.scrollbars-visible-always.theme-one-dark-syntax.theme-one-dark-ui
      ATOM-PANEL-CONTAINER.header                                       <== PanalContainer (x 7)
      ATOM-WORKSPACE-AXIS.horizontal
          ATOM-PANEL-CONTAINER.left                                     <== PanalContainer
              ATOM-DOCK.left                                            <-- Dock (x 3)
                  DIV.atom-dock-inner.left.atom-dock-open
                      DIV.atom-dock-mask
                          DIV.atom-dock-content-wrapper.left ...
                      DIV.atom-dock-toggle-button.left
                          DIV.atom-dock-toggle-button-inner.left ...
          ATOM-WORKSPACE-AXIS.vertical
              ATOM-PANEL-CONTAINER.top                                  <== PanalContainer
              ATOM-PANE-CONTAINER.panes                                 <~~ PaneContainer (x 1)
                  ATOM-PANE.pane
                      UL.list-inline.tab-bar.inset-panel
                          LI.texteditor.tab.sortable.active ...
                      DIV.item-views
                          ATOM-TEXT-EDITOR.editor ...                   <++ TextEditor
                          ATOM-TEXT-EDITOR.editor ...                   <++ TextEditor
              ATOM-PANEL-CONTAINER.bottom                               <== PanalContainer
                  ATOM-DOCK.bottom                                      <-- Dock
                      DIV.atom-dock-inner.bottom
                          DIV.atom-dock-mask ...
                          DIV.atom-dock-toggle-button.bottom ...
          ATOM-PANEL-CONTAINER.right                                    <== PanalContainer
              ATOM-DOCK.right                                           <-- Dock
                  DIV.atom-dock-inner.right
                      DIV.atom-dock-mask
                          DIV.atom-dock-content-wrapper.right ...
                      DIV.atom-dock-toggle-button.right
                          DIV.atom-dock-toggle-button-inner.right ...
      ATOM-PANEL-CONTAINER.footer                                       <== PanalContainer
          ATOM-PANEL.footer.tool-panel.panel-footer
              STATUS-BAR.status-bar
                  DIV.flexbox-repaint-hack
                      DIV.status-bar-left
                          STATUS-BAR-FILE.file-info.inline-block ...
                          STATUS-BAR-CURSOR.cursor-position.inline-block ...
                          STATUS-BAR-SELECTION.selection-count.inline-block ...
                      DIV.status-bar-right
                          A.line-ending-tile.inline-block ...
                          DIV.deprecation-cop-status.inline-block.text-warning ...
                          ENCODING-SELECTOR-STATUS.encoding-status.inline-block ...
                          GRAMMAR-SELECTOR-STATUS.grammar-status.inline-block ...
                          STATUS-BAR-GIT.git-view ...
                          DIV.package-updates-status-view.inline-block.text.text-info ...
      ATOM-PANEL-CONTAINER.modal                                       <== PanalContainer
          ATOM-PANEL.modal.overlay.from-top
              DIV.select-list.tabs-mru-switcher
                  OL.list-group
          ATOM-PANEL.modal.overlay.from-top
              DIV.select-list.tabs-mru-switcher
                  OL.list-group
          ATOM-PANEL.modal.overlay.from-top
              DIV.select-list.tabs-mru-switcher
                  OL.list-group
          ATOM-PANEL.modal.overlay.from-top
              DIV.select-list.tabs-mru-switcher
                  OL.list-group
      DIV.tabs-layout-overlay

# Dock and TreeView
> console.log(
    JSON.stringify(f(document.querySelector('ATOM-DOCK.left'),8), null, 2)
    .replace(/[\{\}\[\]\,\"\:]/g, '')
    .split('\n')
    .filter(line => !line.match(/^(\ )*$/))
    .join('\n')
  )
ATOM-DOCK.left
  DIV.atom-dock-inner.left.atom-dock-open
      DIV.atom-dock-mask
          DIV.atom-dock-content-wrapper.left
              DIV.atom-dock-resize-handle.left.atom-dock-resize-handle-resizable
              ATOM-PANE-CONTAINER.panes
                  ATOM-PANE.pane
                      UL.list-inline.tab-bar.inset-panel
                          LI.tab.sortable.active
                              DIV.title ...
                      DIV.item-views
                          DIV.tool-panel.tree-view
                              OL.full-menu.list-tree.has-collapsable-children.focusable-panel ...
              DIV.atom-dock-cursor-overlay.left
      DIV.atom-dock-toggle-button.left
          DIV.atom-dock-toggle-button-inner.left
              SPAN.icon.icon-chevron-left       
```


# Keybinding and command dispatch

```
(Setup listener for key event on document level)
- atomEnvironment.initialize =>
  - windowEventHandler.initialize =>
    - document.addEventListener('keyup', this.handleDocumentKeyEvent)
    - document.addEventListener('keydown', this.handleDocumentKeyEvent)

(Command registration)
- atom.commands.add => commandRegistry.addSelectorBasedListener =>
  - commandRegistered =>
    - window.addEventListener(commandName, this.handleCommandEvent,true)

(Example: user presses 'ctrl-t' (fuzzy-finder:toggle-file-finder)) =>
- windowEventHandler.handleDocumentKeyEvent =>
  - keymaps.handleKeyboardEvent (follow atom-keymap library) =>
    - (check partial match and etc...)
    - dispatchCommandEvent =>
      - new CustomEvent (extends CommandEvent)
      - target.dispatchEvent(event) (this will be "captured" by commandRegistry.handleCommandEvent)
    - (check if commandEvent.abortKeyBinding is called. if it's called, continue next matched command)

- commandRegistry.handleCommandEvent =>
  - ?
```


# TODO

- css (less) and theme architecture
- first-mate implementation (tokenization architecture)
- testing infrastructure


# Customization and Migration from VSCode

- [x] open project: use 'application:reopen-project'
- [x] open terminal: use `require('child_process').exec`
- remove trailing space on save
- clang based c/c++ cross reference
- remove dock chevron
- list existing commands: run `atom.commands.registeredCommands`
- delete entry from project history


# Reference

- http://flight-manual.atom.io/behind-atom/sections/keymaps-in-depth/
