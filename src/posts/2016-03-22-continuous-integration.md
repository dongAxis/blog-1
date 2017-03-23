<!--
{
  "title": "Continuous Integration",
  "date": "2016-03-22T15:01:56.000Z",
  "category": "",
  "tags": [
    "testing",
    "ci"
  ],
  "draft": false
}
-->

Just a list of something relevant.
Here is my test project for setting up jenkins with ansible: https://github.com/hi-ogawa/jenkins_rails_ansible.

### Jenkins

- documents: https://wiki.jenkins-ci.org/display/JENKINS/Use+Jenkins
- github integration:
  - https://wiki.jenkins-ci.org/display/JENKINS/GitHub+Plugin
  - https://www.cloudbees.com/blog/better-integration-between-jenkins-and-github-github-jenkins-plugin
  - https://jenkins-ci.org/files/Jenkins-hearts-Ruby.pdf
  - https://medium.com/@WoloxEngineering/ruby-on-rails-continuous-integration-with-jenkins-and-docker-compose-8dfd24c3df57#.ncwg4u3pr
- security: https://wiki.jenkins-ci.org/display/JENKINS/Securing+Jenkins
- install plugin (programically):
  - http://stackoverflow.com/questions/7709993/how-can-i-update-jenkins-plugins-from-the-terminal
  - https://wiki.phpmyadmin.net/pma/Jenkins_Setup#Getting_plugins
  - https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI
  -
- rails app:
  - http://www.eq8.eu/blogs/6-jenkins-ci-for-rails-4-rspec-cucumber-selenium
  - https://jenkins-ci.org/solutions/ruby/

- where is default jenkins home?
```
$ sudo cat /etc/passwd | grep &#039;^jenkins:&#039; | cut -d: -f6
/var/lib/jenkins
```

- create jenkins user from command line: http://stackoverflow.com/questions/17716242/creating-user-in-jenkins-via-api

### References

- general CI practice:
  - https://www.cloudbees.com/blog/better-integration-between-jenkins-and-github-github-jenkins-plugin
- external services
  - http://www.yegor256.com/2014/10/05/ten-hosted-continuous-integration-services.html

  - https://github.com/ligurio/Continuous-Integration-services/blob/master/continuous-integration-services-list.md
  - https://about.gitlab.com/gitlab-ci/