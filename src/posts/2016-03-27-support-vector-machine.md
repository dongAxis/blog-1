<!--
{
  "title": "Support Vector Machine",
  "date": "2016-03-27T01:25:01.000Z",
  "category": "",
  "tags": [
    "algorithm",
    "machine-learning"
  ],
  "draft": true
}
-->

### Implementation

- numpy basic operation: https://docs.scipy.org/doc/numpy-dev/user/quickstart.html#basic-operations

- cvxopt to solve quadratic programming: http://cvxopt.org/userguide/coneprog.html#quadratic-programming

- using `numpy.matrix` is not recommended generally: http://stackoverflow.com/questions/3890621/how-does-multiplication-differ-for-numpy-matrix-vs-array-classes/3892639#3892639

- confusing matrix representation:

```
&gt;&gt;&gt; np.array([1, 2, 3]).transpose()
array([1, 2, 3])
&gt;&gt;&gt; np.array([[1, 2, 3]]).transpose()
array([[1],
       [2],
       [3]])
&gt;&gt;&gt; np.array([[4], [5], [6]]).dot(np.array([[1, 2, 3]]))
array([[ 4,  8, 12],
       [ 5, 10, 15],
       [ 6, 12, 18]])
```
---
### Theoretic Interests

TODO: the below discussions are OPPOSITE (necessity and sufficient conditions)

##### Lagrange Multiplier

I wrote (informal and simple) proof of the theorem about one way implication between original problem and "_Lagrange-multiplier_ed" problem.
In simple term, we can say two things:

- if you find an answer in converted problem, that must be an answer in original problem,
- but, there might be a problem where you can not find an answer in converted problem even though the answer exists in original problem.

![](http://)

##### Karushâ€“Kuhnâ€“Tucker Conditions

This technique expands application of _Lagrange Multiplier_ so that it includes inequality constraints. but, of course, this requires condition for objective function or others.

The optimization problem appearing in finding SVM can be written very simple equation and inequation, which satifies [those condition](https://en.wikipedia.org/wiki/Karush%E2%80%93Kuhn%E2%80%93Tucker_conditions#Sufficient_conditions), so it can be solved by this technique.

Intuitively, inequality can be deal with same way as equality case since anyway extreme point exists on the boundary of area made by inequality. (maybe this is too rough.)


TODO: write down problem definition for the SVM case (mimization)

---
### Future Work

- follow proof of necessity implication in _Lagrange Multiplier_ and _KKT conditions_

### References

- SVM:
  - http://docs.opencv.org/2.4/doc/tutorials/ml/introduction_to_svm/introduction_to_svm.html#introductiontosvms
  - http://research.nii.ac.jp/~satoh/utpr/utpr_2015_06_09.pdf
- Wikipedia
  - [Lagrange Multiplier](https://en.wikipedia.org/wiki/Lagrange_multiplier)
  - [KKT conditions](https://en.wikipedia.org/wiki/Karush%E2%80%93Kuhn%E2%80%93Tucker_conditions)
  - [Quadratic Programming](https://en.wikipedia.org/wiki/Quadratic_programming)
- [cvxopt](http://cvxopt.org/): convex optimization in python