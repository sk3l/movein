#!/bin/bash

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

echo -e "\n~~~ Starting movein... ~~~\n"
if [[ -f $HOME/.movedin ]]; then
	echo -e "Already moved in; returning\n"
	return 0
fi

echo -e "\n~~~ Examining host Linux distro ~~~\n"

OS_TYPE=""
OS_VERSION=""
if [[ -f /etc/redhat-release ]]; then
    if grep 'CentOS' /etc/redhat-release; then
        echo -e "* Detected CentOS  distro *"
	    OS_TYPE="centos"
    else 
        echo -e "* Detected Red Hat Enterprise Linux distro *"
	    OS_TYPE="rhel"
    fi
elif [[ $(lsb_release) ]]; then
	echo -e "* Detected Ubuntu distro *"
	OS_TYPE="ubuntu"
else
	echo -e "!!! Detected unknown distro!!!"
    echo -e "Aborting movein due to unrecognized OS"
    exit 1 
fi

# Source user baseline script
echo -e "\n~~~ Sourcing base user ~~~\n"
source crates/base/user

# Source per-distro baseline script
echo -e "\n~~~ Sourcing base env for ${OS_TYPE}  ~~~\n"
source crates/${OS_TYPE}/${OS_TYPE}_base

# Custom scripts from argv are sourced here
echo -e "\n~~~ Sourcing scripts from command-line   ~~~\n"

#echo -e "\n~~~ Installing shell resource files ~~~\n"

#cp $SRCPATH/sk3lshell/dot-files/.bashrc $HOME 

#if [[ -f "$SRCPATH/sk3lshell/dot-files/.bashrc_local_$TYPE" ]]; then
#    echo -e "* Found distro-specific shell resource file for $TYPE; installing *"
#    cp "$SRCPATH/sk3lshell/dot-files/.bashrc_local_$TYPE" $HOME/
#fi

#source $HOME/.bashrc

echo $(date) > $HOME/.movedin
echo -e "\nMovein has completed\n"
