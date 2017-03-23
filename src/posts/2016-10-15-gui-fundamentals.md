<!--
{
  "title": "GUI Fundamentals",
  "date": "2016-10-15T21:09:17.000Z",
  "category": "",
  "tags": [
    "gui"
  ],
  "draft": true
}
-->

# Big Images (Overview)

- Display Server: https://en.wikipedia.org/wiki/Display_server
- Window system:
  - X window system:
   - https://en.wikipedia.org/wiki/X_Window_System_core_protocol
   - https://www.x.org/wiki/guide/concepts/
   - https://en.wikipedia.org/wiki/X_window_manager
  - Wayland: https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)
- GTK archtecture: http://www.gtk.org/overview.php
- Qt: http://doc.qt.io/qt-5/overviews-main.html
- https://commons.wikimedia.org/wiki/File:Free_and_open-source-software_display_servers_and_UI_toolkits.svg
- https://en.wikipedia.org/wiki/File:Linux_Graphics_Stack_2013.svg
- Connection with browser rendering engines
  - Webkit: https://webkit.org/
  - Blink: http://www.chromium.org/blink, http://www.chromium.org/developers/design-documents
  - Gecko: https://developer.mozilla.org/en-US/docs/Mozilla/Gecko
- SDL: https://en.wikipedia.org/wiki/Simple_DirectMedia_Layer
  - Direct3D
  - OpenGL
- Realation between OpenGL and window system: https://en.wikipedia.org/wiki/OpenGL
  - https://en.wikipedia.org/wiki/GLX
  - Mesa: https://en.wikipedia.org/wiki/Mesa_(computer_graphics)
  - "The specification says nothing on the subject of obtaining, and managing, an OpenGL context, leaving this as a detail of the underlying windowing system, OpenGL is purely concerned with rendering"

# Things to try

- Choices
  - Different protocol: X, Wayland, Quarts
  - Different server: XQuarts, ...
  - Different Client: GTK, Qt, Clutter, Xlib, XCB
- directly Xlib: https://en.wikipedia.org/wiki/Xlib
- directly XCB: https://en.wikipedia.org/wiki/XCB
- Interact with XQuarts and Quarts
- Remote X Client (in Docker?)
- OpenGL programming
- xmonad: https://en.wikipedia.org/wiki/Xmonad

---

- GTK
- Qt
- Xlib, XCB
- Android case: https://source.android.com/devices/graphics/index.html

---


# Game

## Library

- frameworks
  - http://www.ogre3d.org/
  - https://urho3d.github.io/
  - https://github.com/ValveSoftware/source-sdk-2013
  - http://xenko.com/
  - https://www.unrealengine.com/what-is-unreal-engine-4

## Reference

- http://www.gamasutra.com/blogs/YanickBourbeau/20150902/252624/Linux_game_development_in_2015.php
- http://pingugamedevelopmer.blogspot.jp/
- https://www.reddit.com/r/linux/comments/1z5ema/game_programming_development_on_linux/
- http://www.worldofleveldesign.com/categories/level_design_tutorials/recommended-game-engines.php
- https://en.wikipedia.org/wiki/List_of_game_engines
- mod: http://wiki.garrysmod.com/page/Chair_Throwing_Gun

- Vulkan
  - https://github.com/KhronosGroup/Khronosdotorg/blob/master/api/vulkan/resources.md

- https://en.wikipedia.org/wiki/File:Linux_kernel_and_gaming_input-output_latency.svg

# Notes

- X.org server
- GNOMU on GTK
- KDE on Qt
- https://www.wikivs.com/wiki/GTK_vs_Qt
- https://keyj.emphy.de/files/linuxgraphics_en.pdf