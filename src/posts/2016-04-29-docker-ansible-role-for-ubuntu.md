<!--
{
  "title": "Docker Ansible role for Ubuntu",
  "date": "2016-04-29T22:57:21.000Z",
  "category": "",
  "tags": [
    "ansible",
    "docker"
  ],
  "draft": false
}
-->

I've tried using _ansible-role_ several times:

- [hi-ogawa/jenkins_rails_ansible](https://github.com/hi-ogawa/jenkins_rails_ansible),
- [hi-ogawa/rails_jenkins](https://github.com/hi-ogawa/rails_jenkins/tree/master/ansible), 

but I felt it's too much abstraction. So, I separated from ansible-role and just include task files from main _playbook_, which is easier/simpler enough for my small scale use case.

Recently, however, I found myself copy-and-pasting my own script from one project to another and getting sick of it. So, this is a good time to come back ansible-role and, further more, make it available from _ansible-galaxy_.

I chose docker installation as my first target since I've made [such tasks before](http://wp.hiogawa.net/2016/04/25/ci-on-jenkins-and-docker/)

I made it!

- [hi-ogawa.docker](https://galaxy.ansible.com/hi-ogawa/docker/)

### References

- [galaxy.ansible.com documentation](https://galaxy.ansible.com/intro#share)