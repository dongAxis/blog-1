<!--
{
  "title": "cgroup interface",
  "date": "2016-08-13T11:20:03.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

Cited from https://web.archive.org/web/20140305130851/http://functionaljobs.com/jobs/8687-nixos-haskell-devops-engineer-at-zalora

# Selection Task - Part 1

Write a FastCGI program (preferably in Haskell) that provides a restful API to manage the cgroups of a server. It should support the following:

- list available cgroups
- list the tasks (PIDs) for a given cgroup
- place a process into a cgroup

You can assume that the server is running a Linux 3.4 kernel with the cgroup root mounted via sysfs. Include a default.nix to build your program as a nix package. Bonus points for including a NixOS module.nix.