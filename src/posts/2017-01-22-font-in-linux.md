<!--
{
  "title": "Font in Linux",
  "date": "2017-01-22T14:31:41.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- typography
  - https://www.w3.org/TR/css-fonts-3/#typography-background

- font file format
  - truetype is getting to be de facto standard ?
  - microsoft: https://www.microsoft.com/en-us/Typography/SpecificationsOverview.aspx 
  - apple: https://developer.apple.com/fonts/TrueType-Reference-Manual/

- font rendering
  - https://www.freetype.org/
  - https://skia.org/
    - is this using freetype ?
      - I think so. it looks like src/ports/SkFontHost_{win,mac,FreeType}.cpp handles platform-specific part.

- web
  - css: https://www.w3.org/TR/css-fonts-3/
  - does Chromium use freetype ?
    - this uses skia, so indirectly uses freetype. and of course, "build/install-build-deps.sh" includes "libfreetype6".

- other GUI platform
  - qt
  - gtk

- ? linux text-mode

- a bit off-track
  - encoding: https://www.w3.org/TR/html5/infrastructure.html#encoding-terminology
  - dpi

---

- read Chromium, Skia, FreeType