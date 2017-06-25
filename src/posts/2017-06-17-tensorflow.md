<!--
{
  "title": "Tensorflow",
  "date": "2017-06-17T11:20:31+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# TODO

- code structure and built artifacts
  - \_pywrap_tensorflow_internal.so
- python api (seems it's better to follow c++ example)
- graph generation/execution
- automatic gradient descent algorithm inference


# Build from source

```
# tensorflow/python/BUILD
tf_py_wrap_cc(
    name = "pywrap_tensorflow_internal",
    srcs = ["tensorflow.i"],
    swig_includes = [
      ...
```

```
$ bazel build //tensorflow/cc:tutorials_example_trainer
$ bazel-bin/tensorflow/cc/tutorials_example_trainer
```


# Example

```
import tensorflow as tf

W = tf.Variable([.3], dtype=tf.float32)
b = tf.Variable([-.3], dtype=tf.float32)

x = tf.placeholder(tf.float32)
linear_model = W * x + b
y = tf.placeholder(tf.float32)

loss = tf.reduce_sum(tf.square(linear_model - y))

optimizer = tf.train.GradientDescentOptimizer(0.01)
train = optimizer.minimize(loss)

x_train = [1,2,3,4]
y_train = [0,-1,-2,-3]

init = tf.global_variables_initializer()
sess = tf.Session()
sess.run(init)
sess.run(train, {x:x_train, y:y_train})
```


# Code reading

```
[ Data structure ]
Session < BaseSession < SessionInterface
'-' (see tf_session.i)
'-' Graph

Tensor

Operation


[ Example ]
- Session.__init__ =>
  - BaseSession.__init__ =>
    - self._graph = ops.get_default_graph =>
      - _DefaultGraphStack.get_default => _GetGlobalDefaultGraph =>
        - self._global_default_graph = Graph()
    - self._session = tf_session.TF_NewSession(self._graph._c_graph ..) =>
      - (c_api.cc) new TF_Session

- Session.run(fetches, feed_dict) =>
  - _run =>
    - fetch_handler = _FetchHandler(self._graph, fetches ..) => ?
    - final_fetches = fetch_handler.fetches()
    - final_targets = fetch_handler.targets()
    - results = self._do_run(handle, final_targets, final_fetches, ..) =>
      - ?
```


# Reference

- http://download.tensorflow.org/paper/whitepaper2015.pdf
- https://github.com/tensorflow/tensorflow
