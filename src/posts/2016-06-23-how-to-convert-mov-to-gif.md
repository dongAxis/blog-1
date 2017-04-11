<!--
{
  "title": "How to Convert .mov to .gif",
  "date": "2016-06-23T01:00:13.000Z",
  "category": "",
  "tags": [
    "docker"
  ],
  "draft": false
}
-->

I made a dockerized cli application based on this great gist https://gist.github.com/dergachev/4627207

- On Github: https://github.com/hi-ogawa/mov2gif
- On DockerHub: https://hub.docker.com/r/hiogawa/mov2gif/

Usage is simple. Docker _entrypoint_ wraps two commands `ffmpeg` and `gifsicle`, 
so you only need to specify original .mov file name, frame size, and frame rate.
Example is below:

```
$ ls
test_movie.mov
$ docker run -v $PWD:/app --rm hiogawa/mov2gif test_movie.mov 600x800 30 # <filename> <frame size> <frame rate>
...
$ ls
test_movie.gif test_movie.mov
```