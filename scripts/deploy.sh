#!/bin/bash

bundle exec ruby ./build.rb
aws s3 sync $OUT s3://blog.hiogawa.net
