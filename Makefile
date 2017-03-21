## Main build dependencies ##

_SRC_POSTS = $(shell ls src/posts)
SRC_POSTS = $(addprefix src/posts/,$(_SRC_POSTS))
OUT_POSTS = $(addprefix out/posts/,$(patsubst %.md,%.html,$(_SRC_POSTS)))

posts: $(OUT_POSTS)
out/posts/%.html: src/posts/%.md $(addprefix src/templates/,_entry.html _post.html)
	POST_MD=$< npm run build:post

index: out/index.html
out/index.html: $(addprefix src/templates/,_entry.html _index.html) $(SRC_POSTS)
	npm run build:index

css: out/index.css
out/index.css: $(shell find src/scss -name '*.scss')
	npm run build:css


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
	npm start

clean:
	rm -r out

.PHONY: prepare deploy start clean
