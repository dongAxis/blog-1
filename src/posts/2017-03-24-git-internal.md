<!--
{
  "title": "Git Internal",
  "date": "2017-03-24T23:54:53+09:00",
  "category": "",
  "tags": ["git", "source"],
  "draft": false
}
-->

# Documentation/glossary-content.txt

_reference:_ https://github.com/git/git/blob/master/Documentation/glossary-content.txt

- repository
- object
  - types
    - blob object
    - tree object
    - commit object
    - tag object
  - object database
  - object name (hash, SHA1)
- ref
  - pointer to object (normal case)
  - pseudoref (e.g. MERGE_HEAD)
  - symref (e.g. HEAD)
- head
  - detached head
  - HEAD
- index
  - some intermidiate state ? (like stage or rebasing)
- branch
  - a tip of a branch (ref, head)
- commit
- commit-ish
- tree-ish
- working tree
- chain
  - parents

# Files under .git/

- HEAD
- ORIG_HEAD
- FETCH_HEAD
- index
- config
- objects/
- refs/
  - heads/
  - remotes/
    - origins/
  - tags/
- logs/
  - HEAD
  - refs/
- branches/

# TODO

- Read some git frontend
  - how about vscode? (I feel like it more than emacs magit)

