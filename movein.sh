#!/bin/bash

function usage {
	echo -e "\nUsage:\n"
	echo -e "    movein.sh [-d distro] [-l logfile] <script1> <script2> ..."
	echo -e "\nWhere:"
    echo -e "   -d distro = linux distribution to use (don't prompt)"
    echo -e "               supported distros: 'ubuntu', 'rhel', 'centos'"
    echo -e "   <scriptN> = movein scripts to execute"
}

# Parse cmd-line arguments
LOG=/var/log/movein-$(date "+%Y%m%d_%H_%M_%S")
DISTRO=""
while getopts "d:l:" option; do
    case "${option}" in
    d)
        DISTRO=${OPTARG}
        ;;
    l)
        LOG=${OPTARG}
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done

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

echo -e "\n~~~ Verifying Git ~~~\n"

GIT=$(which git)
if [[ $? -ne 0 ]]; then
	echo -e "No Git detected; check and retry"
	exit 11 
fi
GITVER=$(git --version)
echo -e "Found Git, $GITVER"

echo -e "* Setting .gitconfig *"
$GIT config --global --add user.name "Michael Skelton"
$GIT config --global --add user.email "mskelton@bloomberg.net" # TO DO ~> parameterize

if [[ ! -d $HOME/Code ]]; then
	echo -e "~~~ Creating ~/Code directory ~~~"
	mkdir -p $HOME/Code/{linux,sk3l}
fi

GITHUB=https://github.com/sk3l

SRCPATH="$HOME/Code/sk3l"
echo -e "\n~~~ Pulling down source repos ~~~"

if [[ ! -d $SRCPATH/sk3lshell ]]; then
    echo -e "\n* cloning sk3lshell *"
    if ! $GIT clone -c http.sslVerify=false $GITHUB/sk3lshell $SRCPATH/sk3lshell; then
	    echo -e "Unable to clone sk3lshell; aborting"
	    return 1 
    fi
fi

if [[ ! -d $SRCPATH/tmux-conf ]]; then
    echo -e "\n* cloning tmux-conf*"
    if ! $GIT clone -c http.sslVerify=false $GITHUB/tmux-conf $SRCPATH/tmux-conf; then
	    echo -e "Unable to clone tmux-conf; aborting"
	    return 1 
    fi
fi

if [[ ! -d $SRCPATH/vim-conf ]]; then
    echo -e "\n* cloning vim-conf*"
    if ! $GIT clone -c http.sslVerify=false $GITHUB/vim-conf $SRCPATH/vim-conf; then
	    echo -e "Unable to clone vim-conf; aborting"
	    return 1 
    fi
fi

echo -e "\n~~~ Installing ViM config ~~~\n"

[[ ! -d $HOME/.vim ]] && mkdir $HOME/.vim

cp $SRCPATH/vim-conf/conf/.vimrc $HOME 
cp -R $SRCPATH/vim-conf/conf $HOME/.vim/
cp -R $SRCPATH/vim-conf/colors $HOME/.vim/

echo -e "\n~~~ Installing tmux config ~~~\n"

cp $SRCPATH/tmux-conf/.tmux.conf $HOME 

echo -e "\n~~~ Installing shell resource files ~~~\n"

cp $SRCPATH/sk3lshell/dot-files/.bashrc $HOME 

if [[ -f "$SRCPATH/sk3lshell/dot-files/.bashrc_local_$TYPE" ]]; then
    echo -e "* Found distro-specific shell resource file for $TYPE; installing *"
    cp "$SRCPATH/sk3lshell/dot-files/.bashrc_local_$TYPE" $HOME/
fi

source $HOME/.bashrc

echo $(date) > $HOME/.movedin
echo -e "\nAll moved in... \n"
