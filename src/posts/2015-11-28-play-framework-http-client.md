<!--
{
  "title": "WS, Play framework HTTP client",
  "date": "2015-11-28T21:49:15.000Z",
  "category": "",
  "tags": [
    "play",
    "scala",
    "async"
  ],
  "draft": false
}
-->

I did some experiments on `play.api.libs.ws`, HTTP client library included in Play framework. All codes are in [my scala playground](https://github.com/hi-ogawa/scala_playground) and the relevant commit relevant to this post is [this](https://github.com/hi-ogawa/scala_playground/commit/44afc0d4f6b617663f82442f0660cd84a07b46c7).

### What I learned

- How to throw multiple http requests and handle responses in parallel

<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/scala_playground/blob/44afc0d4f6b617663f82442f0660cd84a07b46c7/src/main/scala/net/hiogawa/playground/ws/WSStuff.scala?slice=2:31"></script>

- How to run WS independent from main play application

<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/scala_playground/blob/44afc0d4f6b617663f82442f0660cd84a07b46c7/src/main/scala/net/hiogawa/playground/ws/IndependentClient.scala?slice=16:26"></script>

<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/scala_playground/blob/44afc0d4f6b617663f82442f0660cd84a07b46c7/src/test/scala/net/hiogawa/playground/ws/IndependentClientTest.scala?slice=15:17"></script>

- How to test with main play application

<script src="http://gist-it.appspot.com/https://github.com/hi-ogawa/scala_playground/blob/44afc0d4f6b617663f82442f0660cd84a07b46c7/src/test/scala/net/hiogawa/playground/ws/WSStuffTest.scala?slice=11:29"></script>

### References

- independent ws client: http://stackoverflow.com/questions/24881145/how-do-i-use-play-ws-library-in-normal-sbt-project-instead-of-play
- testing in play framework: https://www.playframework.com/documentation/2.3.x/ScalaFunctionalTestingWithSpecs2