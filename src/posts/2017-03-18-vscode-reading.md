<!--
{
  "title": "VS Code, reading source",
  "date": "2017-03-18T22:43:32+09:00",
  "category": "",
  "tags": ["reading-source"],
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
            - createWorkbench (dom setup)
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
- `CompositePart`: extends "Part" having replaceable "Composite" as content (e.g. `SidebarPart`, `PanelPart`)
- `Composite`: rendered inside of CompositePart (e.g. `ExplorerViewlet`)
- `Panel`: extends `Composite` for `PanelPart` (e.g. `TerminalPanel`, `OutputPanel`, `BaseEditor`)

    ```
    some code
    ```

- `WorkbenchComponent`:  base class `Part` and `Composite` (for book-keeping UI object?)


# Editor (Part) initialization

```
(workbench.main.ts imports vs/editor/browser/editor.all)
- ??
```


# "Contribution" architecture

For example, WorkbenchContribution and WatermarkContribution

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

- run `./script/code-cli.sh --verbose .`
- open devtool and add breakpoint around workbench initilization (e.g. Workbench.startup)
- run command pallete "Reload Window"


# Workbench parts preview

```
[One liner to preview node hierarchy with arbitrary depth]
> var f = (node, depth) => ({ class: (node.classList && Array.from(node.classList).join(', ')), children: (depth > 0 ? Array.from(node.childNodes).map(c => f(c, depth - 1)) : "...")})
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


# IDE 101

- syntax highlight
- keyboard shortcut
- symbol resolution
  - autocomplete
- file search
- word search

# Extension architecture

TODO

# Wishlist

- sidebar scrollability
- add entry to context menu
- keyboard shortcut outside of text editor

# Future work

- Promise implementation
- More Chromium internal
