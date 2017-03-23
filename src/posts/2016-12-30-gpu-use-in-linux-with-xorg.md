<!--
{
  "title": "GPU use in Linux with Xorg",
  "date": "2016-12-30T18:51:16.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- forget these for now:
    - compositing

- todo 
    - window management, Xorg gl extension
        - client: SDL wrapper
        - server: just read
    - opengl spec
    - mesa opengl
    - kernel drm subsystem 
    - intel drm driver

- example:
  - pipeline
      - vertex generation/processing
      - primitive generation/processing
      - fragment generation/processing
      - pixel operation => output
  - #? create some cube rendering program