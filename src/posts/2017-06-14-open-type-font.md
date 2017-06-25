<!--
{
  "title": "Skia",
  "date": "2017-05-14T18:07:20+09:00",
  "category": "",
  "tags": ["graphics"],
  "draft": true
}
-->

Let's manually parse open font file for nothing. Here is an example font file I found on my PC.

__hexdump__

```
$ hexdump -C -n 0x100 /usr/share/fonts/cantarell/Cantarell-Regular.otf
00000000  4f 54 54 4f 00 0d 00 80  00 03 00 50 43 46 46 20  |OTTO.......PCFF |
00000010  80 c4 c6 9d 00 00 0f 50  00 00 de af 46 46 54 4d  |.......P....FFTM|
00000020  6c 95 3f d6 00 00 fd dc  00 00 00 1c 47 44 45 46  |l.?.........GDEF|
00000030  03 69 06 7b 00 00 ee 00  00 00 00 32 47 50 4f 53  |.i.{.......2GPOS|
00000040  9b e2 7c 10 00 00 ee ac  00 00 0f 30 47 53 55 42  |..|........0GSUB|
00000050  31 50 25 3e 00 00 ee 34  00 00 00 76 4f 53 2f 32  |1P%>...4...vOS/2|
00000060  fa 45 55 cf 00 00 01 40  00 00 00 60 63 6d 61 70  |.EU....@...`cmap|
00000070  9e c6 7d cc 00 00 09 88  00 00 05 a6 68 65 61 64  |..}.........head|
00000080  0a f2 5b 5f 00 00 00 dc  00 00 00 36 68 68 65 61  |..[_.......6hhea|
00000090  07 e2 06 3b 00 00 01 14  00 00 00 24 68 6d 74 78  |...;.......$hmtx|
000000a0  f1 9d 90 44 00 00 fd f8  00 00 0c fc 6d 61 78 70  |...D........maxp|
000000b0  03 3f 50 00 00 00 01 38  00 00 00 06 6e 61 6d 65  |.?P....8....name|
000000c0  f6 18 15 fb 00 00 01 a0  00 00 07 e6 70 6f 73 74  |............post|
000000d0  ff 86 00 32 00 00 0f 30  00 00 00 20 00 01 00 00  |...2...0... ....|
000000e0  00 00 00 00 22 01 fe 98  5f 0f 3c f5 00 0b 03 e8  |...."..._.<.....|
000000f0  00 00 00 00 d3 dc 8b 7f  00 00 00 00 d3 dc 8b 7f  |................|
00000100

$ hexdump -C -n 0x100 /usr/share/fonts/cantarell/Cantarell-Regular.otf
```

(It seems this is not the case of "Font Collections", which uses TTC Header.)


__Offset Table__

```
uint32 sfntVersion	 - 0x4f54544f (= "OTTO")
uint16 numTables     - 0x0000000d (= 14)
uint16 searchRange   - ...
uint16 entrySelector - ...
uint16 rangeShift    - ...
```


__Table Record entries__

1st one

```
uint32   tag      - 0x43464620 (= "CFF ")
uint32   checkSum - ...
Offset32 offset   - 0x00000f50 (= 3920)
uint32   length   - 0x0000deaf (= 57007)
```

2nd one

```
uint32   tag      - 0x43464620 (= "FFTM")
uint32   checkSum - ...
Offset32 offset   - 0x0000fddc (= 64988)
uint32   length   - 0x0000001c (= 29)
```

and continues...


The role of each tables

```
CFF  - Compact Font Format 1.0
FFTM - ??
GDEF - Glyph definition data
GPOS - Glyph positioning data
GSUB - Glyph substitution data
OS/2 - OS/2 and Windows specific metrics (*)
cmap - Character to glyph mapping (*)
head - Font header (*)
hhea - Horizontal header (*)
hmtx - Horizontal metrics (*)
maxp - Maximum profile (*)
name - Naming table (*)
post - PostScript information (*)

((*) is mandatory)
```


__Font Tables__

cmap example

```
$
```


# Implementation

## Skia and FreeType

grid-fitting

```
(how did we get SkPackedID(uint32_t code, SkFixed x, SkFixed y) in the first place ?)
  (SEE SkShaper::shape interface (SkShaper_harfbuzz))
- GlyphFindAndPlaceSubpixel::findAndPositionGlyph(.. position ..) =>
  - SkIPoint lookupPosition = SubpixelAlignment(position) =>
    -
  - SkGlyph& renderGlyph = fGlyphFinder->lookupGlyphXY =>
    - ... => SkPackedGlyphID(SkGlyphID code, SkFixed x, SkFixed y)


- SkScalerContext_FreeType_Base::generateGlyphImage =>
  - (if FT_GLYPH_FORMAT_OUTLINE)
    - FT_Outline* outline = &face->glyph->outline;
    - FT_BBox     bbox
    - FT_Bitmap   target
    - (if SkScalerContext::kSubpixelPositioning_Flag)
      - dx = SkFixedToFDot6(glyph.getSubXFixed()) =>
        - ID2SubX        => id >> (kSubShift + kSubShiftX)
        - SubToFixed     => sub << (16 - kSubBits)
        - SkFixedToFDot6 => (x) >> 10
      - dy = SkFixedToFDot6(glyph.getSubYFixed()) => ...
      - dy = -dy;
    - FT_Outline_Get_CBox(outline, &bbox);
    - FT_Outline_Translate(outline, dx - ((bbox.xMin + dx) & ~63),
                                    dy - ((bbox.yMin + dy) & ~63));
    - FT_Render_Glyph(face->glyph, FT_RENDER_MODE_LCD)
```

# TTC

Example of font collections with TTC header:

```
$ hexdump -C -n 0x200 /usr/share/fonts/noto/NotoSans-Regular.ttc
00000000  74 74 63 66 00 01 00 00  00 00 00 02 00 00 00 14  |ttcf............|
00000010  00 00 01 30 00 01 00 00  00 11 01 00 00 04 00 10  |...0............|
00000020  47 44 45 46 34 06 28 1b  00 00 02 4c 00 00 01 a0  |GDEF4.(....L....|
00000030  47 50 4f 53 87 fd a6 05  00 00 03 ec 00 00 a4 b6  |GPOS............|
00000040  47 53 55 42 46 0c 8f 23  00 00 a8 a4 00 00 09 60  |GSUBF..#.......`|
00000050  4f 53 2f 32 7f a2 53 43  00 00 b2 04 00 00 00 60  |OS/2..SC.......`|
00000060  63 6d 61 70 e1 a8 08 4f  00 00 b2 64 00 00 06 68  |cmap...O...d...h|
00000070  63 76 74 20 19 af 1a c5  00 00 b8 cc 00 00 00 fe  |cvt ............|
00000080  66 70 67 6d 36 0b 16 0c  00 00 b9 cc 00 00 07 b4  |fpgm6...........|
00000090  67 61 73 70 00 16 00 23  00 00 c1 80 00 00 00 10  |gasp...#........|
000000a0  67 6c 79 66 c6 4c f3 83  00 00 c1 90 00 03 96 64  |glyf.L.........d|
000000b0  68 65 61 64 f9 01 5b 78  00 04 57 f4 00 00 00 36  |head..[x..W....6|
000000c0  68 68 65 61 0e af 0c 4f  00 04 58 64 00 00 00 24  |hhea...O..Xd...$|
000000d0  68 6d 74 78 3d ca 78 99  00 04 58 88 00 00 25 be  |hmtx=.x...X...%.|
000000e0  6c 6f 63 61 10 f5 12 22  00 04 7e 48 00 00 25 c4  |loca..."..~H..%.|
000000f0  6d 61 78 70 0b f2 05 16  00 04 a4 0c 00 00 00 20  |maxp........... |
00000100  6e 61 6d 65 85 a3 b3 e1  00 04 a4 2c 00 00 05 ce  |name.......,....|
00000110  70 6f 73 74 ff 69 00 66  00 04 af dc 00 00 00 20  |post.i.f....... |
00000120  70 72 65 70 66 b4 a9 e7  00 04 af fc 00 00 02 1a  |prepf...........|
00000130  00 01 00 00 00 11 01 00  00 04 00 10 47 44 45 46  |............GDEF|
00000140  34 06 28 1b 00 00 02 4c  00 00 01 a0 47 50 4f 53  |4.(....L....GPOS|
00000150  87 fd a6 05 00 00 03 ec  00 00 a4 b6 47 53 55 42  |............GSUB|
00000160  46 0c 8f 23 00 00 a8 a4  00 00 09 60 4f 53 2f 32  |F..#.......`OS/2|
00000170  7f a2 53 43 00 00 b2 04  00 00 00 60 63 6d 61 70  |..SC.......`cmap|
00000180  e1 a8 08 4f 00 00 b2 64  00 00 06 68 63 76 74 20  |...O...d...hcvt |
00000190  19 af 1a c5 00 00 b8 cc  00 00 00 fe 66 70 67 6d  |............fpgm|
000001a0  36 0b 16 0c 00 00 b9 cc  00 00 07 b4 67 61 73 70  |6...........gasp|
000001b0  00 16 00 23 00 00 c1 80  00 00 00 10 67 6c 79 66  |...#........glyf|
000001c0  c6 4c f3 83 00 00 c1 90  00 03 96 64 68 65 61 64  |.L.........dhead|
000001d0  f9 01 5b 78 00 04 58 2c  00 00 00 36 68 68 65 61  |..[x..X,...6hhea|
000001e0  0e af 0c 4f 00 04 58 64  00 00 00 24 68 6d 74 78  |...O..Xd...$hmtx|
000001f0  3d ca 78 99 00 04 58 88  00 00 25 be 6c 6f 63 61  |=.x...X...%.loca|
00000200
```


# HarfBuzz



# Reference

- https://www.microsoft.com/en-us/Typography/OpenTypeSpecification.aspx
