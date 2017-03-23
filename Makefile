## Nodejs setup ##
PATH := $(PWD)/node_modules/.bin:$(PATH)

## Main build dependencies ##

_SRC_POSTS = $(shell ls src/posts)
SRC_POSTS = $(addprefix src/posts/,$(_SRC_POSTS))
OUT_POSTS = $(addprefix out/posts/,$(patsubst %.md,%.html,$(_SRC_POSTS)))

posts: $(OUT_POSTS)
out/posts/%.html: src/posts/%.md $(addprefix src/templates/,_entry.html _post.html)
	node build.js post $<

index: out/index.html
out/index.html: $(addprefix src/templates/,_entry.html _index.html) $(SRC_POSTS)
	node build.js index

css: out/index.css
out/index.css: $(shell find src/scss -name '*.scss')
	node-sass src/scss/index.scss > out/index.css


ifdef IGNORE_INDEX
INDEX =
else
INDEX = index
endif

build: $(INDEX) css posts


## Some helpers ##

deploy: build
	aws s3 sync out s3://blog.hiogawa.net

prepare:
	npm install
	mkdir -p out/posts

start:
	nf start builder,server

clean:
	rm -r out

.PHONY: prepare deploy start clean
