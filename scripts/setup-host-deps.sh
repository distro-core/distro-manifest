#!/bin/bash

# Install host dependency

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME=$(basename $0)

sudo_args="--preserve-env=USERNAME,USERPROFILE,http_proxy,https_proxy"

. /etc/os-release

case $ID in

almalinux* )
    sudo ${sudo_args} -s dnf install -y -q epel-release
    sudo ${sudo_args} -s yum install -y -q dnf-plugins-core
    sudo ${sudo_args} -s dnf config-manager --set-enabled crb
    sudo ${sudo_args} -s dnf makecache
    sudo ${sudo_args} -s dnf upgrade -y
    sudo ${sudo_args} -s dnf install -y -q gawk make wget tar bzip2 gzip python3 unzip perl patch \
                            diffutils diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath \
                            ccache socat perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue \
                            python3-pip python3-GitPython python3-jinja2 python3-pexpect xz which \
                            rpcgen zstd lz4 cpio glibc-langpack-en libacl git-lfs hostname s3cmd \
                            python3-websockets
    sudo ${sudo_args} -s dnf install -y -q 'dnf-command(config-manager)'
    if [[ -z "$(command -v gh)" ]] ; then
    sudo ${sudo_args} -s dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo ${sudo_args} -s dnf install -y -q gh --repo gh-cli
    fi
    ;;

rhel* )
    exit 1
    ;;

debian* | ubuntu* )
    sudo ${sudo_args} -s apt-get update
    sudo ${sudo_args} -s apt-get upgrade -y -q
    sudo ${sudo_args} -s apt-get install -y -q gawk wget git diffstat unzip texinfo gcc build-essential \
                            chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
                            iputils-ping python3-git python3-jinja2 python3-subunit zstd liblz4-tool \
                            file locales libacl1 git-lfs make libxml2-utils s3cmd python3-websockets time
    sudo ${sudo_args} -s locale-gen en_US.UTF-8
    if [[ -z "$(command -v gh)" ]] ; then
    sudo ${sudo_args} -s install -d -p -m 0755 /etc/apt/keyrings
    sudo ${sudo_args} -s bash -c "wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null"
    sudo ${sudo_args} -s bash -c "chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg"
    sudo ${sudo_args} -s bash -c "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    sudo ${sudo_args} -s apt-get update
    sudo ${sudo_args} -s apt-get install -y -q gh
    fi
    ;;

fedora* )
    sudo ${sudo_args} -s dnf install -y -q gawk make wget tar bzip2 gzip python3 unzip perl patch diffutils \
                            diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath ccache perl-Data-Dumper \
                            perl-Text-ParseWords perl-Thread-Queue perl-bignum socat python3-pexpect findutils \
                            which file cpio python python3-pip xz python3-GitPython python3-jinja2 rpcgen \
                            perl-FindBin perl-File-Compare perl-File-Copy perl-locale zstd lz4 hostname \
                            glibc-langpack-en libacl s3cmd python3-websockets
    sudo ${sudo_args} -s dnf install 'dnf-command(config-manager)'
    if [[ -z "$(command -v gh)" ]] ; then
    sudo ${sudo_args} -s dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo ${sudo_args} -s dnf install gh --repo gh-cli
    fi
    ;;

opensuse* )
    sudo ${sudo_args} -s zypper install -y -q python gcc gcc-c++ git chrpath make wget python-xml diffstat \
                            makeinfo python-curses patch socat python3 python3-curses tar python3-pip \
                            python3-pexpect xz which python3-Jinja2 rpcgen zstd lz4 bzip2 gzip hostname \
                            libacl1 s3cmd python3-websockets
    sudo ${sudo_args} -s pip3 install GitPython
    if [[ -z "$(command -v gh)" ]] ; then
    sudo ${sudo_args} -s zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo ${sudo_args} -s zypper ref
    sudo ${sudo_args} -s zypper install gh
    fi
    ;;

* )
    exit 1
    ;;

esac

: install repo tool
mkdir -p $HOME/.local/bin
curl --silent https://storage.googleapis.com/git-repo-downloads/repo > $HOME/.local/bin/repo
chmod a+rx $HOME/.local/bin/repo
[[ -n "$(command -v repo)" ]] || exit 1

exit 0
