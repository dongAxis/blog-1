<!--
{
  "title": "Github-like Auto Link on Wordpress",
  "date": "2016-06-22T05:07:46.000Z",
  "category": "",
  "tags": [
    "wordpress",
    "js"
  ],
  "draft": false
}
-->

I like [automatic link in Github](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown) so much. But, it's not supported by wordpress plugin [Jetpack Markdown](https://wordpress.org/plugins/jetpack-markdown/).
So, I made a javascript library https://github.com/hi-ogawa/ahrefy to solve this problem. 
This library replaces all plain url text with `<a href=''>` wrapped version of it.

On this wordpress, I only added the `<script>` tag around the footer as below:

<img src="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-22_2300-1024x886.png" alt="2016-06-22_2300" width="580" height="502" class="alignnone size-large wp-image-842" />

Javascript file is hosted by http://rawgit.com/ .