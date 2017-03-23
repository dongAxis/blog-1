<!--
{
  "title": "Development Practice",
  "date": "2016-06-19T06:33:31.000Z",
  "category": "",
  "tags": [
    "agile",
    "development"
  ],
  "draft": false
}
-->

This post will be updated constantly.

# My Experience

- http://c2.com/cgi/wiki?YouArentGonnaNeedIt
  - abstraction (make a thing as "library") for single use
  - don't try to solve unseen/undefined problem

- two kinds of abstraction
  - file separation (syntactic separation)
      - (ruby/rails) put ruby code in model to use in view
  - reusable library

- "define a problem (find a problem)" vs. "solve a problem"
  - ex. optimize something (e.g. assets size, query)

- http://c2.com/cgi/wiki?CodeBloat, good tight code
  - ruby/rails: safer way of nil check kills readability
      - don't use `arr.blank?` when `arr` cannot be `nil` at the exact line
  - type system:
      - relation to "sub typing" ? (approximated to `Any`)

- Testing for encouraging faster change
  - you can aggressively and safely change existing code as long as there's a test

- Pair Programming: http://c2.com/cgi/wiki?PairProgramming
  - in any cases, two pairs of eyes contributed to decreasing a gap between syntax and semantics
      - typo, naming
      - constant way of code review
  - three types:
     - junior/senior case (programming knowledge differs)
     - new-comer/long-lived (system/source code familiarity differs)
     - same level case

- Not talk on chat if you can discuss face-to-face. after discussion, keep a log somewhere.

- Rule of Representation (from Unix Philosopy):
  - from this point, we can say Haskell's rich custom data type has crucial advantages

>  Fold knowledge into data, so program logic can be stupid and robust.
  

# References

- http://agileatlas.org/articles/item/dimensional-planning

- http://abailly.github.io/posts/agile-startup.html

> the importance of evaluating your capability to deliver features against your capability to maintain your software and make it able to sustain more change in the future.

- https://medium.com/product-love/the-scrum-backlog-is-where-features-go-to-die-b1336ff707aa

> Adding an idea or a potential awesome feature to the backlog is way easier than designing, building, delivering, marketing & maintaining it.
> ...
> In the end managing software projects is all about deciding what to do and what not to do. Having a clear separation between what sounds like a good idea and what actually gets implemented is key.

- Unix Philosophy
  - https://en.wikipedia.org/wiki/Unix_philosophy
  - http://homepage.cs.uri.edu/~thenry/resources/unix_art/ch01s06.html

- Development Philosophies
  - https://en.wikipedia.org/wiki/List_of_software_development_philosophies

- http://c2.com/cgi/wiki?ExtremeProgramming
- http://c2.com/cgi/wiki?ExtremeProgrammingCorePractices

- https://google.github.io/styleguide/cppguide.html#Goals
  - reasons to have styleguide

- good things: https://about.gitlab.com/handbook/

- https://github.com/opencontainers/runc/blob/master/PRINCIPLES.md

- criteria to asses company's development quality
  - http://jvns.ca/blog/2013/12/30/questions-im-asking-in-interviews/
  - https://medium.com/@edwardog/questions-to-ask-your-future-web-dev-employer-f7a161b5bc70#.82hqwfb95
  - http://www.joelonsoftware.com/articles/fog0000000043.html

- https://training.kalzumeus.com/newsletters/archive/do-not-end-the-week-with-nothing
  - prefer to work at company where you can work on things you can show anytime

- Agile with remote work 
  - https://about.gitlab.com/2015/04/08/the-remote-manifesto/
  - https://www.pandastrike.com/posts/20150304-agile

- Books
  - Team Geek: https://www.amazon.com/Team-Geek-Software-Developers-Working/dp/1449302440
      - what good manager is
      - normal developer/human mind
  - The Lean Startup - Eric Ries
  - Making It Right - Rian van der Merwe
  - Lean from the Trenches - Henrik Kniberg
  - Getting Real - Jason Fried: https://basecamp.com/about/books/Getting%20Real.pdf
     - books from basecamp: https://basecamp.com/about/books