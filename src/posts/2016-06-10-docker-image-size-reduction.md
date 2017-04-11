<!--
{
  "title": "Docker image size reduction",
  "date": "2016-06-10T19:04:41.000Z",
  "category": "",
  "tags": [
    "docker"
  ],
  "draft": false
}
-->

I've never cared about the size of Docker image. But, when I was trying to dockerize [gcc cross compiler](https://github.com/hi-ogawa/docker-gcc-cross-compiler), I couldn't ignore this problem.

I employed a technique explained in [this blog](http://chrisstump.online/2016/02/23/docker-image-reduction-techniques/). Here are two _Dockerfile_ doing same things:

_Dockerfile:_

```
FROM ubuntu:14.04

RUN apt-get update &amp;&amp; apt-get install -y gcc wget build-essential

# specify binutils/gcc version
ENV DOWNLOAD_BINUTILS=binutils-2.26
ENV DOWNLOAD_GCC=gcc-4.9.3

# download binutils/gcc and its dependencies
RUN wget -q http://ftp.gnu.org/gnu/binutils/$DOWNLOAD_BINUTILS.tar.gz
RUN tar -xzf $DOWNLOAD_BINUTILS.tar.gz

RUN wget -q ftp://ftp.gnu.org/gnu/gcc/$DOWNLOAD_GCC/$DOWNLOAD_GCC.tar.gz
RUN tar -xzf $DOWNLOAD_GCC.tar.gz

RUN cd /$DOWNLOAD_GCC &amp;&amp; contrib/download_prerequisites

# specify TARGET
ENV TARGET=i686-elf
ENV PREFIX=/usr/local

# build binutils
RUN mkdir -p /srv/build_binutils
WORKDIR /srv/build_binutils
RUN /$DOWNLOAD_BINUTILS/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
RUN make
RUN make install

# build gcc
RUN mkdir -p /srv/build_gcc
WORKDIR /srv/build_gcc
RUN /$DOWNLOAD_GCC/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
RUN make all-gcc
RUN make all-target-libgcc
RUN make install-gcc
RUN make install-target-libgcc

# remove big files
RUN rm -r /$DOWNLOAD_BINUTILS /$DOWNLOAD_GCC /srv/build_binutils /srv/build_gcc

WORKDIR /
```

_Dockerfile.slim:_

```
FROM ubuntu:14.04

# install dependencies
RUN apt-get update                                                &amp;&amp; \
    apt-get install -y gcc wget build-essential                   &amp;&amp; \
    apt-get clean autoclean                                       &amp;&amp; \
    apt-get autoremove -y                                         &amp;&amp; \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

# specify binutils/gcc version
ENV DOWNLOAD_BINUTILS=binutils-2.26
ENV DOWNLOAD_GCC=gcc-4.9.3

# specify TARGET
ENV TARGET=i686-elf
ENV PREFIX=/usr/local

# binutils
RUN wget -q http://ftp.gnu.org/gnu/binutils/$DOWNLOAD_BINUTILS.tar.gz &amp;&amp; \
    tar -xzf $DOWNLOAD_BINUTILS.tar.gz                                &amp;&amp; \
    mkdir -p /srv/build_binutils                                      &amp;&amp; \
    cd /srv/build_binutils                                            &amp;&amp; \
    /$DOWNLOAD_BINUTILS/configure --target=$TARGET --prefix="$PREFIX"    \
                        --with-sysroot --disable-nls --disable-werror &amp;&amp; \
    make                                                              &amp;&amp; \
    make install                                                      &amp;&amp; \
    rm -r /$DOWNLOAD_BINUTILS /srv/build_binutils

# gcc
RUN wget -q ftp://ftp.gnu.org/gnu/gcc/$DOWNLOAD_GCC/$DOWNLOAD_GCC.tar.gz &amp;&amp; \
    tar -xzf $DOWNLOAD_GCC.tar.gz                                        &amp;&amp; \
    cd /$DOWNLOAD_GCC &amp;&amp; contrib/download_prerequisites                  &amp;&amp; \
    mkdir -p /srv/build_gcc                                              &amp;&amp; \
    cd /srv/build_gcc                                                    &amp;&amp; \
    /$DOWNLOAD_GCC/configure --target=$TARGET --prefix="$PREFIX"            \
                 -disable-nls --enable-languages=c,c++ --without-headers &amp;&amp; \
    make all-gcc                                                         &amp;&amp; \
    make all-target-libgcc                                               &amp;&amp; \
    make install-gcc                                                     &amp;&amp; \
    make install-target-libgcc                                           &amp;&amp; \
    rm -r /$DOWNLOAD_GCC /srv/build_gcc

WORKDIR /
```

```
$ docker build -f Dockerfile -t hiogawa/i686-elf .
$ docker build -f Dockerfile.slim -t hiogawa/i686-elf-slim .
$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED              SIZE
hiogawa/i686-elf        latest              85de86d956f5        6 hours ago          2.902 GB
hiogawa/i686-elf-slim   latest              588d6a8e1a3f        About a minute ago   864.8 MB
```

(TODO: add `docker history` command results) 

### References

- [chrisstump.online: docker-image-reduction-techniques](http://chrisstump.online/2016/02/23/docker-image-reduction-techniques/)
- [ctl.io: optimizing-docker-images](https://www.ctl.io/developers/blog/post/optimizing-docker-images/)