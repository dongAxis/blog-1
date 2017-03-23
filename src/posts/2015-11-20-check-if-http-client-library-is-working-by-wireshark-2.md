<!--
{
  "title": "Check if HTTP client library is working by Wireshark",
  "date": "2015-11-20T01:33:32.000Z",
  "category": "",
  "tags": [
    "wireshark",
    "ruby"
  ],
  "draft": false
}
-->

### Screencast
![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/wireshark-1448255653226.gif)

<!--
this gif image is made by using this command (original .mov file is taken via QuickTime).
$ ffmpeg -i ~/Desktop/wireshark.mov -vf scale=1000:-1 -r 15 -f gif - | gifsicle --optimize=3 --delay=4 > ~/Desktop/wireshark.gif
-->

### Procedure

- Install Wireshark from [here](https://www.wireshark.org/download.html) and start capturing packets with specifying network device (in my case, it was `Wi-Fi: en0`).

- Run the http client library as you like. In my case I wanted to check POST method request with `Net::HTTP` Ruby library (http://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html#class-Net::HTTP-label-POST+with+Multiple+Values
), so I did this in console:

<pre class="prettyprint lang-ruby">
[1] pry(main)> require 'net/http'
=> true
[2] pry(main)> Net::HTTP.post_form URI("http://example.com/index.html"), x: 1, y: 2
=> #&lt;Net::HTTPOK 200 OK readbody=true>
[3] pry(main)> Net::HTTP.post_form URI("http://example.com/index.html"), z: 3, w: 4
=> #&lt;Net::HTTPOK 200 OK readbody=true>
</pre>

- Filter and search for the corresponding web flow in Wireshark. You can set HTTP Method (`http.request.method`) or URI (`http.request.uri`) to filtering entries.

![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/2015_11_23_1431-1448256730614.png)