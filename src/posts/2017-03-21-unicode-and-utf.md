<!--
{
  "title": "Unicode and UTF",
  "date": "2017-03-22T02:27:55+09:00",
  "category": "",
  "tags": ["spec"],
  "draft": true
}
-->

# Example

"浩志" (Hiroshi) is my first name in Japanese kanji:

```
$ irb
> "浩志".bytes
=> [230, 181, 169, 229, 191, 151]
> "浩志".bytes.map { |b| b.to_s(2) }
=> ["11100110", "10110101", "10101001", "11100101", "10111111", "10010111"]


[ First unicode ]
1110-0110, 10-110101, 10-101001 ==> 0110110101101001 ==> 0x6d69

[ Second unicode ]
1110-0101, 10-111111, 10-010111 ==> 0101111111010111 ==> 0x5fd7
                                ^^^                  ^^^
                            (decode utf8)          (in hex)
```

# References

- Standard:
  - http://www.unicode.org/versions/Unicode9.0.0/
  - http://www.unicode.org/standard/principles.html
  - https://tools.ietf.org/html/rfc3629
- Wiki
  - Charcter set: https://en.wikipedia.org/wiki/List_of_Unicode_characters
  - Encoding: https://en.wikipedia.org/wiki/Comparison_of_Unicode_encodings
- Programming Library: http://userguide.icu-project.org/unicode
- Programming language integration
  - v8 string ?
  - webkit/blink string ?
- Web Platform
  - https://html.spec.whatwg.org/multipage/infrastructure.html#encoding-terminology
