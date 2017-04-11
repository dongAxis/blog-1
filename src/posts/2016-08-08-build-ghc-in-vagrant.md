<!--
{
  "title": "Build GHC in Vagrant",
  "date": "2016-08-08T13:35:37.000Z",
  "category": "",
  "tags": [
    "haskell",
    "ghc"
  ],
  "draft": false
}
-->

This is my first time to build GHC from source.
I tried this process at this point: https://github.com/ghc/ghc/commit/207890919e9718da71f0c0cf69fc7ff1b9490b85

# Get source code

```
$ git clone --depth 1 git://github.com/ghc/ghc
$ cd ghc
```

# Edit `Vagrantfile`

The prepared `Vagrantfile` didn't work for me (or I don't know how to use), so I wrote script by myself.

```prettyprint
# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
set -x

curl -sSL https://get.haskellstack.org/ | sh

su vagrant -c 'stack setup'
su vagrant -c 'stack install happy'
su vagrant -c 'stack install alex'

apt-get install -y autoconf automake git llvm-dev libedit-dev libffi-dev libncurses5-dev

echo 'export PATH="$(stack path --compiler-bin):$PATH"' >> /home/vagrant/.bashrc
echo 'export PATH="$(stack path --local-bin):$PATH"' >> /home/vagrant/.bashrc

SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, inline: $script
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = 4096
    vb.cpus = 2
  end
end
```

# Run commands

```
$ vagrant up
$ vagrant ssh
(vm)$ cd /vagrant
(vm)$ git config --global url."git://github.com/ghc/packages-".insteadOf git://github.com/ghc/packages/
(vm)$ cp mk/build.mk.sample mk/build.mk
(vm)$ git submodule update --init
(vm)$ ./boot
(vm)$ ./configure
(vm)$ make # I felt like this took half a day
(vm)$ ./inplace/bin/ghc-stage2 --interactive
GHCi, version 8.1.20160801: http://www.haskell.org/ghc/  :? for help
Prelude> sum [1..100]
5050
Prelude> :q
Leaving GHCi.
(vm)$ make fasttest
(vm)$ cat testsuite_summary.txt

Unexpected results from:
TEST="T9203 haddock.Cabal haddock.base T1969 T5837 T3294"

SUMMARY for test run started at Mon Aug  8 05:02:29 2016 UTC
 3:43:44 spent to go through
    5272 total tests, which gave rise to
   21055 test cases, of which
   15894 were skipped

      50 had missing libraries
    5031 expected passes
      74 expected failures

       0 caused framework failures
       0 unexpected passes
       0 unexpected failures
       6 unexpected stat failures

Unexpected stat failures:
   perf/compiler/T1969.run         T1969 [stat not good enough] (normal)
   perf/compiler/T3294.run         T3294 [stat not good enough] (normal)
   perf/compiler/T5837.run         T5837 [stat too good] (normal)
   perf/haddock/haddock.base.run   haddock.base [stat too good] (normal)
   perf/haddock/haddock.Cabal.run  haddock.Cabal [stat too good] (normal)
   perf/should_run/T9203.run       T9203 [stat too good] (normal)
```

I don't know what this test result means, but anyway I somehow managed to build GHC.

# Reference

- https://ghc.haskell.org/trac/ghc/wiki/Building/Preparation/Tools
- https://ghc.haskell.org/trac/ghc/wiki/Newcomers
- http://packages.ubuntu.com/yakkety/haskell-platform
- http://parfunk.blogspot.jp/2013/08/zero-to-ghc-development-in-ubuntu-vm-in.html