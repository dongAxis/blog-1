<!--
{
  "title": "Gemfile and Gemspec",
  "date": "2015-12-03T16:56:04.000Z",
  "category": "",
  "tags": [
    "ruby",
    "gem"
  ],
  "draft": false
}
-->

According to http://b.j15e.com/ruby/2013/06/28/gemfile-gemspec-explained.html,

- About `<gem-name>.gemspec`:
> **Gemspec** was created in 2006 by **Rubygems** and is the way to define a ruby package (a gem), publish it on rubygems.org and install them with the gem command.

- About `Gemfile`:
> **Gemfile** was created in 2009 by **Bundler** (Engine Yard, Andre Arko) as a way to define a project gems dependency, deal with dependencies version and lock versions to use the same environment across developpers & deployments.


According to http://stackoverflow.com/questions/6499410/ruby-gemspec-dependency-is-possible-have-a-git-branch-dependency,
the dependency (from top to bottom) like this is fine:
```
     ruby application (e.g. rails)
     /               
 private gem0       private gem2
```
But the chained dependency like below is impossible:
```
 ruby application (e.g. rails)
  |
 private gem0
  |
 private gem1
```