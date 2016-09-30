# rods

Virtual machine configuration for development environment for [lightning](https://github.com/ElementsProject/lightning).

### How to run

- clone the [lightning](https://github.com/ElementsProject/lightning) repository.
- Install [vagrant](http://www.vagrantup.com/downloads)
- Make sure you have a virtual machine provider. [Virtualbox](https://www.virtualbox.org/wiki/Downloads) will do.
- clone this repository *to the same directory that you cloned the lightning repository to*.
- `vagrant up`

### what it's doing

fairly simple. We're grabbing all the dependencies, then building from source:

- elements alpha
- protobuf
- protobuf-c
- lightning (your host's local copy)

### what to do next

- log into your VM using `vagrant ssh`
- go into the lightning directory and run the tests `cd lightning && make check`
- fix bugs, write code, open pull request

### contributing

This was thrown together very quickly. Any comments, issues, Pull Requests gratefully accepted.