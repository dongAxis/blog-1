## Nodejs setup ##
PATH := $(PWD)/node_modules/.bin:$(PATH)

## Main build dependencies ##

_SRC_POSTS = $(shell ls src/posts)
SRC_POSTS = $(addprefix src/posts/,$(_SRC_POSTS))
OUT_POSTS = $(addprefix out/posts/,$(patsubst %.md,%.html,$(_SRC_POSTS)))
OTHER_DEPS = config.js build.js

posts: $(OUT_POSTS)
out/posts/%.html: src/posts/%.md $(addprefix src/templates/,_entry.html _post.html) $(OTHER_DEPS)
	node build.js post $<

index: out/index.html $(OTHER_DEPS)
out/index.html: $(addprefix src/templates/,_entry.html _index.html) $(SRC_POSTS) $(OTHER_DEPS)
	node build.js index

css: out/index.css
out/index.css: $(shell find src/scss -name '*.scss')
	node-sass src/scss/index.scss > out/index.css

ifndef BUILD
BUILD = index css posts
endif

build: $(BUILD)


## Some helpers ##

deploy: build
	aws s3 sync out s3://blog.hiogawa.net

prepare:
	npm install
	mkdir -p out/posts

start:
	nf start builder,server

clean:
	rm -f out/index.html out/index.css out/posts/*

.PHONY: prepare deploy start clean
