<!--
{
  "title": "UVA 10310: Dog and Gopher (and Go language First Impression)",
  "date": "2016-07-01T04:00:07.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "uva",
    "go"
  ],
  "draft": false
}
-->

- [Problem definition](https://uva.onlinejudge.org/external/103/p10310.pdf)
- [Implementation in Go](https://github.com/hi-ogawa/go_playground/tree/b8944fed6f30e8e83f1ad88e19b63f23b9c759fe/p10310)

For the record, it's totally coincidence that my first Go language experiment happens to solve this "Gopher" problem.

# What I learnt

- Interface based polymorphism
  - [`os.File`](https://golang.org/pkg/os/#File) and [`bytes.Buffer`](https://golang.org/pkg/bytes/#Buffer) are [`Reader`](https://golang.org/pkg/io/#Reader) and [`Writer`](https://golang.org/pkg/io/#Writer) (which in turn is [`ReadWriter`](https://golang.org/pkg/io/#ReadWriter)) since those struct implements `Read`, `Write` methods
- Testing framework https://github.com/smartystreets/goconvey
- Debugging tool https://github.com/derekparker/delve
- Official docker image: https://hub.docker.com/_/golang/

# First Impression

- Cons
  - Package system is confusing?
      - I'm not clear about the relation of `package` name and directory/file name yet.
  - Struct pointer concept is necessary
  - Too imperative and explicit (very subjective opinion)
  - Lack of polymorphism in data structure?
     - https://golang.org/pkg/container/heap/#example__priorityQueue
  - Whether to use _struct_ or _struct pointer_ can be one big implementation decision? 
     - readability and efficiency trade-off?

- Pros
  - Standard package documentation is very easy to navigate: https://golang.org/pkg/
  - Clean code base:
     - There's single imperative way of writing code
     - default `go fmt`
     - no compiler warning (compiler doesn't allow unused variable)

# Future Work

- Skim styleguide
- Linting tool integration
- Is there a way to compose `ok`-returning functions like Maybe monad?
  - I don't think so

```prettyprint
    answerWriter, _ := os.Open("./p10310/sample.output")
    answer, _ := ioutil.ReadAll(answerWriter)
```