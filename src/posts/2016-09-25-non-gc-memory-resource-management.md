<!--
{
  "title": "Non-GC Memory Resource Management",
  "date": "2016-09-25T07:30:03.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Keywords

- scope
  - _destructor_ will be called when a variable gets out of scope
- RAII (Resource Acquisition is Initialization)
- smart pointer
  - _unique_ptr_ in c++ (how's implementation? is it needed to be implemented inside of runtime?)

shared, weak pointer example

```
weak_ptr wp;

f () : void = 
  shared_ptr p = ...
  wp = p
  ... # here p will be destructed when f gets out because of scope

wp.lock() # check validity somewhere else
```

---

but, FP-like algebraic data type transformation cannot be achieved within this limitted way ?
like, creating object (i.e. allocate memory) inside of function and return it?
not really, because such an object anyway will be destructed when the variable referencing it gets out of scope.

- find example where memory leaks
  - of course, it happens if several initialized (heap-allocated) objects are assigned to single variable.
  - but that's not SSA (static single assignment) style programming. I want to find other example.




# Reference

- https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization
- https://en.wikipedia.org/wiki/Smart_pointer
- https://msdn.microsoft.com/en-us/library/hh279674.aspx
- http://www.wellho.net/mouth/3069_Strings-Garbage-Collection-and-Variable-Scope-in-C-.html
- http://stackoverflow.com/questions/228620/garbage-collection-in-c-why