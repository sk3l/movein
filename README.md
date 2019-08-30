# movein - make yourself @ $HOME

This is a Bash script intended to automate 'bootstrapping' of a workable development environment on a new system. The genesis of the new system could be a brand new physical PC or laptop, a virtual machine, or a Docker container; really doesn't matter. Your new environment just has a few pre-requisites to run movein:

* access to Bash shell
* some version of Git pre-installed
* an Internet connection

## movein procedure

1. download or `git clone` this source repository from GitHub

2. From root of movein source directory, `cp movein ~/`

3. `source movein`; this will download repos containing shell .dot files, utility scripts and other goodies

The movein process should leave you with:

- a new Bash .rc file with useful aliases
- a localized distro-specific .rc file
- a .gitconfig

## TODO

- additional distro-specific setup in localized .rc
- installation of other helpful apps/tools, using appropriate distro package manager 
