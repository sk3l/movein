<h1 align="center">
<img src="https://github.com/sk3l/movein/assets/4662876/9dff0772-1d88-4b7d-bf88-03f138b5b9c7" alt="dice">
     <div><strong>movein - make yourself @ $HOME</strong></div>
</h1>

This is a Bash script intended to automate provisioning of a fully functional development environment on a new system. What does 'fully functional' imply?

* creation of arbitrary user login and $HOME
* setup of developer tools (for example `git config --global user.name 'Alan Turing'`
* per-distribution installation of developer tools (GCC, Clang, Python)
* positioning of shell .rc files, configs (~/.vim, ~/.tmux.con, and so on) for shells and tools to work as desired

The composition of the new system could be a brand new physical PC or laptop, a virtual machine, or a Docker container; really doesn't matter. Your new environment just has a few pre-requisites to run movein:

* access to Bash shell
* some version of Git pre-installed (can be installed using one of the OS-specific 'crates')
* an Internet connection

## movein 'crates'

The idea behind crates are modular scripts that provide customizations, either per OS, per user login, etc, that you wish to add during provisioning. If you want to bring along a 'crate' during your movein, just append the crate file name (*without leading path info*) to the command line. For example:

`movein.sh base_user centos_base centos_dev base_dev`

## Environment variables influencing movein

- BASE_USER   - main user login to create
- BASE_HOME   - main user login's $HOME folder
- BASE_GROUPS - comma-seperated set of groups for BASE_USER (e.g. `wheel`)
- GIT_USER    - user name to assign to git config
- GIT_EMAIL   - user email to assign to git config

## movein procedure

1. download or `git clone` this source repository from GitHub

2. From root of movein source directory, execute `movein.sh`, supplying any crates of your choosing.

3. after movein, change to your BASE_USER and you should have access to dev tools, configs, etc. from your crates

**NOTE**: For executing crates that create \*nix logins or install software, you will need to execute movein as `root` or super-user on most systems.

## Examples

Here is an example movein in which you already have a development user created (under which login your shell is running), you donot have sudo privilege, and you simply wish to prep your .rc and config files:

```
BASE_USER=$USER BASE_HOME=$HOME ./movein.sh -l /tmp/mskelton8-movein-log.txt base_user base_dev
```

## TODO

- build any apps from source (e.g. ViM on Cent/RHEL) for which suitable versions aren't provided in stock distro repos
