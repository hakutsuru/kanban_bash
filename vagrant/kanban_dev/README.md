kanban_dev
=========

This directory allows you to bring up a development environment for testing kanban\_bash. If you have issues, please read [_when your environment breaks_](../README.md).

Requirements
------------

See the Vagrant directory README -- you will need Ansible, Vagrant and Virtualbox to work with the kanban_dev environment.

kanban_dev is configured to use 192.168.251.42. If you are already using this ip, you will need to resolve the conflict.

### Clone this Repository

The rest of this guide assumes that you're working within a clone of this repository. The examples use repository URLs based on connecting to GitHub with [SSH keys](https://help.github.com/articles/generating-ssh-keys), but feel free to swap out the URLs for their HTTPS counterparts (e.g. https://github.com/hakutsuru/kanban_bash.git for the following clone):

    $ git clone git@github.com:hakutsuru/kanban_bash.git

Working on euler_dev
--------------------

### TL;DR

    $ git clone git@github.com:hakutsuru/kanban_bash.git
    $ cd kanban_bash
    $ cd vagrant/kanban_dev
    $ vagrant up
    $ vagrant ssh

### Memory Usage

By default, the development VM is configured to use 1024 MB of RAM. If you'd like to change that, simply export the `$KANBAN_MEMORY` environment variable with a string of your desired amount (in MB) before bringing up the machine:

    $ export KANBAN_MEMORY='2048'
    $ vagrant up
