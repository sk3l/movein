#!/bin/bash

# Utility functions
function usage {
	echo -e "\nUsage:\n"
	echo -e "    movein.sh [-d distro] [-l logfile] [-u user] <script1> <script2> ..."
	echo -e "\nWhere:"
    echo -e "   -d distro  = linux distribution to use (don't prompt)"
    echo -e "               supported distros: 'ubuntu', 'rhel', 'centos'"
    echo -e "   -l logfile = location of movein log"
    echo -e "   -u user    = name of base movein user"
    echo -e "   <scriptN>  = movein scripts to execute"
}

NO_COLOR="\033[0m"
INFO_COLOR="\033[1;32m"
ERR_COLOR="\033[0;31m"

function log_info {
    echo -e "${INFO_COLOR}$1${NO_COLOR}"
}

function log_error {
    echo -e "${ERR_COLOR}$1${NO_COLOR}"
}

# Variables
LOG=/var/log/movein-$(date "+%Y%m%d_%H_%M_%S")
DISTRO=""

# Parse cmd-line arguments
while getopts "d:l:u:" option; do
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
    \?)
        usage
        exit 1
        ;;
    esac
done
shift "$((OPTIND-1))"

# Write output to the log file and stdout
exec &> >(tee -a "$LOG")

log_info "\n====== Starting movein ======"
#if [[ -f $HOME/.movedin ]]; then
#	echo -e "Already moved in; returning\n"
#	exit 0
#fi

log_info "\n~~~ Examining host Linux distro ~~~\n"

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
elif [[ $(lsb_release) ]]; then
	log_info "* Detected Ubuntu distro *"
	OS_TYPE="ubuntu"
else
	log_error "!!! Detected unknown distro!!!"
    log_error "Aborting movein due to unrecognized OS"
    exit 1
fi

# Source user baseline script
log_info "\n~~~ Sourcing base user ~~~\n"
source crates/base/user

# Source per-distro baseline script
log_info "\n~~~ Sourcing base env for ${OS_TYPE}  ~~~\n"
source crates/${OS_TYPE}/${OS_TYPE}_base

# Custom scripts from argv are sourced here
log_info "\n~~~ Sourcing scripts from command-line  ~~~\n"
for SCRIPT in $@; do
    log_info "Sourcing $SCRIPT"
    source $SCRIPT
done

#echo $(date) > $HOME/.movedin
log_info "\n====== Movein has completed ======\n"
