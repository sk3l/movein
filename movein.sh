#!/bin/bash

# Utility functions
function usage {
	echo -e "\nmovein - Make Yourself @ \$HOME\n"
    echo -e "\tA provisioning script for development environments"
	echo -e "\nUsage:\n"
	echo -e "    movein.sh [-h] [-l logfile] [-u user] <crate1> <crate2> ..."
	echo -e "\nWhere:"
    echo -e "   -h         = show this usage"
    echo -e "   -l logfile = location of movein log (default=/var/log)"
    echo -e "   -u user    = name of base movein user (default=\$USER)"
    echo -e "   <crateN>   = name of script in ./crates to source"
    echo -e ""
}

NO_COLOR="\033[0m"
INFO_COLOR="\033[1;32m"
ERR_COLOR="\033[0;31m"

function prompt_user() {
    local action=$1
    local choice=0
    while true; do
        read -p "Do you wish to ${action}? " yn
        case $yn in
            [Yy]* ) choice=1; break;;
            [Nn]* ) break;;
	    * ) echo "Please answer (Y)es or (N)o.";;
        esac
    done
    echo ${choice}
}

function read_user_variable() {
    local variable=$1
    while true; do
        read -p "Please enter a value for ${variable}" value
        if ! [[ -z ${value} ]];then
            break;
	fi
    done
    echo ${value}
}

function run_as_user() {
    cmd=$1
    user=$2
    print_cmd=${3:0}

    if [[ ${print_cmd} -eq 1 ]];then
        echo -e "${cmd}"
    fi

    if [[ ${user} != ${USER} ]];then
       cmd="sudo -u ${user} ${cmd}"
    fi
    eval ${cmd}
}

function run_as_sudo() {
    cmd=$1
    print_cmd=${2:0}

    if [[ ${print_cmd} -eq 1 ]];then
        echo -e "${cmd}"
    fi

    if [[ "$EUID" -ne 0 ]];then
       cmd="sudo -E ${cmd}"
    fi
    eval ${cmd}
}

function log_info() {
    echo -e "${INFO_COLOR}$1${NO_COLOR}"
}

function log_error() {
    echo -e "${ERR_COLOR}$1${NO_COLOR}"
}

# Variables
LOG=/var/log/movein-$(date "+%Y%m%d_%H_%M_%S")
DISTRO=""

# Parse cmd-line arguments
while getopts "d:hl:u:" option; do
    case "${option}" in
    d)
        DISTRO=${OPTARG}
        ;;
    l)
        LOG=${OPTARG}
        ;;
    u)
        BASE_USER=${OPTARG}
        ;;
    h)
        usage
        exit 1
        ;;
    esac
done
shift "$((OPTIND-1))"

# Write output to the log file and stdout
exec &> >(tee -a "$LOG")

log_info "\n(movein)[I] - Starting movein"

log_info "\n(movein)[I] - Examining host Linux distro"

OS_TYPE=""
OS_VERSION=""
if [[ -f /etc/redhat-release ]]; then
    if grep 'CentOS' /etc/redhat-release; then
        log_info "* Detected CentOS  distro *"
	    OS_TYPE="centos"
    else
        log_info "* Detected Red Hat Enterprise Linux distro *"
	    OS_TYPE="rhel"
    fi
elif lsb_release -i -s 2>&1 | grep -q "Ubuntu"; then
	log_info "* Detected Ubuntu distro *"
	OS_TYPE="ubuntu"
elif lsb_release -i -s 2>&1 | grep -q "Debian"; then
	log_info "* Detected Debian distro *"
	OS_TYPE="debian"
else
    log_error "(movein)[E] - Detected unknown distro"
    log_error "Aborting movein due to unrecognized OS"
    return 1
fi

# Custom scripts from argv are sourced here
for SCRIPT in $@; do
    log_info "\n(movein)[I] - Sourcing script $SCRIPT"
    if [[ ! -f ./crates/$SCRIPT ]]; then
	log_error "(movein)[W] - No crate named $SCRIPT found; skipping"
    else
        source ./crates/$SCRIPT
    fi
done

log_info "\n(movein)[I] - Movein has completed"
