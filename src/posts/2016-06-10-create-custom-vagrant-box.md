<!--
{
  "title": "Create Custom Vagrant Box",
  "date": "2016-06-10T18:31:50.000Z",
  "category": "",
  "tags": [
    "ops",
    "vagrant"
  ],
  "draft": false
}
-->

I made two custom boxes, so far:

- [https://github.com/hi-ogawa/vagrant_ubuntu_docker](https://github.com/hi-ogawa/vagrant_ubuntu_docker)
- [https://github.com/hi-ogawa/vagrant_os_dev](https://github.com/hi-ogawa/vagrant_os_dev)

# Create custom box and upload to Atlas

You'll need an account on [Atlas](https://atlas.hashicorp.com/account/new).

After you launched VM from vagrant by:

```
$ vagrant up
```

You can create `.box` file by:

```
$ vagrant package --output foo.box
```

Then, you can upload your box from [this page](https://atlas.hashicorp.com/boxes/new).


# Reuse box without uploading to Atlas.

In this case, you don't need an account on Atlas.

From the `.box` file you created above, you can use `vagrant box add` command for registering on local:

```
$ vagrant box add foo.box --name hiogawa/foo
```

Then, you can resue from anywhere on the same pc by:

```
$ vagrant init hiogawa/foo
```

# References

- [HashiCorp: Creating a New Vagrant Box](https://atlas.hashicorp.com/help/vagrant/boxes/create)
- [Vagrant: `vagrant package`](https://www.vagrantup.com/docs/cli/package.html)
- [Vagrant: `vagrant box add`](https://www.vagrantup.com/docs/cli/box.html#add)
- [scotch.io: How to Create a Vagrant Base Box from an Existing One](https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one)