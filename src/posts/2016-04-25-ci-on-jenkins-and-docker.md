<!--
{
  "title": "CI with Jenkins and Docker",
  "date": "2016-04-25T01:27:10.000Z",
  "category": "",
  "tags": [
    "haskell",
    "docker",
    "ci",
    "jenkins"
  ],
  "draft": false
}
-->

For my haskell project, I couldn't get cache working [on travis CI](https://travis-ci.org/hi-ogawa/haskell_playground/builds/125526351), so I setup CI by myself.
Here is [working example](http://jenkins.hiogawa.net/job/haskell_playground/).

Three components necessary to reproduce what I'm saying:

- [Ansible scripts to install jenkins and docker](https://github.com/hi-ogawa/jenkins_docker_ansible)
- [Dockerfile from hi-ogawa/haskell_playground](https://github.com/hi-ogawa/haskell_playground/blob/7b6d211634634d52ed70e626f90149bed2e1a95d/Dockerfile)
- [Build script in jenkins](https://github.com/hi-ogawa/haskell_playground/blob/37c2dfa0ba7f174fce122806494db961e18c3352/jenkins.sh)

### Reference

- Haskell docker example:
  - [freebroccolo/docker-haskell: snap example](https://github.com/freebroccolo/docker-haskell/blob/master/examples/7.10/snap/Dockerfile)
- Cabal sandbox caching idea comes from those posts: 
  - [how-to-cache-bundle-install-with-docker](https://medium.com/@fbzga/how-to-cache-bundle-install-with-docker-7bed453a5800#.uec49epuh)
  - [Make bundler fast again in Docker Compose](http://bradgessler.com/articles/docker-bundler/)

---

__UPDATE__: what the heck, finally [cache started to work on travis ci](https://travis-ci.org/hi-ogawa/haskell_playground/builds/127524855).