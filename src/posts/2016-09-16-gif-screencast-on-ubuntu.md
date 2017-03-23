<!--
{
  "title": "GIF ScreenCast on Ubuntu",
  "date": "2016-09-16T00:32:46.000Z",
  "category": "",
  "tags": [
    "ubuntu",
    "gif"
  ],
  "draft": false
}
-->

# Requirements

```
$ sudo apt install gtk-recordmydesktop ffmpeg
```

# Process

Just 2 steps:

1. Record screencast ans create .ogv file with [_RecordMyDesktop_](http://recordmydesktop.sourceforge.net/about.php)

2. Run [_ffmpeg_](https://ffmpeg.org/) command like below:

```
$ ffmpeg -i out.ogv -filter:v &quot;setpts=0.7*PTS&quot; -pix_fmt rgb24 test.gif
```

Here is an example:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/09/test.gif"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/09/test.gif" alt="test" width="704" height="752" class="alignnone size-full wp-image-1664" /></a>

# Reference

- [gtk-recordmydesktop](http://recordmydesktop.sourceforge.net/about.php)
- [ffmpeg](https://ffmpeg.org/)
- [ffmpeg wiki: How to speed up/slow down a video](https://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video)