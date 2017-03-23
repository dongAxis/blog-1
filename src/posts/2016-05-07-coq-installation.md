<!--
{
  "title": "Coq Installation",
  "date": "2016-05-07T19:39:55.000Z",
  "category": "",
  "tags": [
    "coq"
  ],
  "draft": false
}
-->

_Coq installation_

```
$ brew install coq
```

_ProofGeneral installation_

Follow the instruction [here](http://proofgeneral.inf.ed.ac.uk/download):

```
$ wget http://proofgeneral.inf.ed.ac.uk/releases/ProofGeneral-4.3pre150930.tgz
$ open http://proofgeneral.inf.ed.ac.uk/releases/ProofGeneral-4.3pre150930.tgz
$ cd ProofGeneral-4.3pre150930/ProofGeneral-4.3pre150930
$ make clean; make compile EMACS=/Applications/Emacs.app/Contents/MacOS/Emacs
```

Add below to _init.el_ file: 

```prettyprint
(load-file (expand-file-name "~/.emacs.d/nonelpa/ProofGeneral-4.3pre150930/generic/proof-site.elc"))
```

Because of [the known issue](http://proofgeneral.inf.ed.ac.uk/trac/ticket/509), I used pre-released version, which you can download from [here](http://proofgeneral.inf.ed.ac.uk/devel).