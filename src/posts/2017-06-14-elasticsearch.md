<!--
{
  "title": "Elasticsearch and Lucene",
  "date": "2017-06-14T16:39:19+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# TODO

- lucene score implementation
  - tfidf: https://lucene.apache.org/core/6_6_0/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html#formula_tf
- index format on disk
- non goals
  - http server impl
  - clustering


# Scoring

- https://lucene.apache.org/core/6_6_0/core/org/apache/lucene/search/similarities/TFIDFSimilarity.html#formula_tf

Small example from my company's data:

```
# Example score of query "title_en:ramen"
# on document X with title_en "Ichiran Ramen: One of the Best Ramen in Japan"
#
# idf * tfNorem (= 4.2 * 1.2)   <= boost is multiplied to this if any (on-field or on-query-term)
# where
# idf = 1 + log(docCount + 1 / docFreq + 1) = 4.2
#   - docFreq=34              <= the smaller the higher
#   - docCount=2459
# tfNorm = sqrt(termFreq) * ??? = 1.2
#   - termFreq=2
#   - avgFieldLength=2.6      <= the smaller the higher ?
#   - fieldLength=7.1         <= the smaller the higher
#   - some params k1=1.2, b=0.75
```


# Code reading

```
[ Data structure ]
bootstrap.Elasticsearch (< EnvironmentAwareCommand < Command)
Netty4HttpServerTransport (< HttpServerTransport)
RestController (< HttpServerTransport.Dispatcher)
RestSearchAction (< BaseRestHandler < RestHandler)
SearchAction (< Action)

FetchSearchPhase < SearchPhase


[ Initialization ]
- org.elasticsearch.bootstrap.Elasticsearch.main =>
  - new Elasticsearch
  - Elasticsearch.main (as Command.main) =>
    - mainWithoutErrorHandling => Elasticsearch.execute =>
      - Bootstrap.init =>
        - new Bootstrap
        - Bootstrap.setup => new Node =>
          - ModulesBuilder modules = new ModulesBuilder
          - NodeService nodeService = new NodeService(.. httpServerTransport ..)
          -  ??
        - Bootstrap.start => Node.start =>
          - Netty4HttpServerTransport.start (as AbstractLifecycleComponent.start) =>
            - Netty4HttpServerTransport.doStart =>
              - ...


[ Request handling ]
- Netty4HttpServerTransport.dispatchRequest =>
  - RestController.dispatchRequest (as HttpServerTransport.Dispatcher) =>
    - RestHandler handler = getHandler(request) => ...
    - dispatchRequest =>
      - (assume we got RestSearchAction as RestHandler)
      - RestSearchAction.handleRequest (as BaseRestHandler.handleRequest) =>
        - RestChannelConsumer action = RestSearchAction.prepareRequest =>
          - new SearchRequest
          - SearchRequest.withContentOrSourceParamParserOrNull =>
            - CheckedConsumer.accept (i.e. parseSearchRequest) =>
              - SearchRequest.indices, searchType
        - RestChannelConsumer.accept (i.e. NodeClient.search(searchRequest)) =>
          - AbstractClient.search => execute(SearchAction.INSTANCE, request) =>
            - NodeClient.doExecute => executeLocally =>
              - transportAction(action) =>
                - TransportAction<Request, Response> = actions.get(action) =>
                  - ? TransportSearchAction
              - TransportSearchAction.execute (as ?) => ... =>
                - TransportSearchAction.doExecute => executeSearch =>
                  - searchAsyncAction =>
                    - AbstractSearchAsyncAction searchAsyncAction = new SearchQueryThenFetchAsyncAction
                  - SearchQueryThenFetchAsyncAction.start

[ Search execution ]
- ...
```


Lucene demo

```
$ cd <lucene root>
$ ant

$ cd <lucene root>/demo
$ ant

$ cd <lucene root>
$ export \
CLASSPATH=build/analysis/common/lucene-analyzers-common-7.0.0-SNAPSHOT.jar:\
build/core/lucene-core-7.0.0-SNAPSHOT.jar:\
build/demo/lucene-demo-7.0.0-SNAPSHOT.jar:\
build/queryparser/lucene-queryparser-7.0.0-SNAPSHOT.jar

$ java org.apache.lucene.demo.IndexFiles -index $PWD/demo_index -docs $PWD/core
Indexing to directory '/home/hiogawa/code/others/lucene-solr/lucene/demo_index'...
adding /home/hiogawa/code/others/lucene-solr/lucene/core/ivy.xml
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/overview.html
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/DocValuesType.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/BufferedUpdatesStream.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/ByteSliceReader.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/DocValues.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/SortingLeafReader.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/SlowCodecReaderWrapper.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/TermState.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/DirectoryReader.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/MergedPrefixCodedTermsIterator.java
adding /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/index/NumericDocValuesFieldUpdates.java
...

$ ls demo_index -ll
total 2320
-rw-r--r-- 1 hiogawa hiogawa     341 Jun 16 12:30 _0.cfe
-rw-r--r-- 1 hiogawa hiogawa 2360255 Jun 16 12:30 _0.cfs
-rw-r--r-- 1 hiogawa hiogawa     381 Jun 16 12:30 _0.si
-rw-r--r-- 1 hiogawa hiogawa     137 Jun 16 12:30 segments_1
-rw-r--r-- 1 hiogawa hiogawa       0 Jun 16 12:30 write.lock

$ java org.apache.lucene.demo.SearchFiles -index $PWD/demo_index -query IndexSearcher
Searching for: indexsearcher
219 total matching documents
1. /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/search/SearcherFactory.java
2. /home/hiogawa/code/others/lucene-solr/lucene/core/src/test/org/apache/lucene/search/TestIndexSearcher.java
3. /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/search/SearcherManager.java
4. /home/hiogawa/code/others/lucene-solr/lucene/core/src/test/org/apache/lucene/index/TestTryDelete.java
5. /home/hiogawa/code/others/lucene-solr/lucene/core/src/test/org/apache/lucene/search/TestControlledRealTimeReopenThread.java
6. /home/hiogawa/code/others/lucene-solr/lucene/core/src/test/org/apache/lucene/search/TestSearcherManager.java
7. /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/search/SearcherLifetimeManager.java
8. /home/hiogawa/code/others/lucene-solr/lucene/core/src/test/org/apache/lucene/search/TestBooleanQuery.java
9. /home/hiogawa/code/others/lucene-solr/lucene/core/src/java/org/apache/lucene/search/Rescorer.java
10. /home/hiogawa/code/others/lucene-solr/lucene/core/src/test/org/apache/lucene/search/TestBooleanScorer.java
```
