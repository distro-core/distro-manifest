#!/bin/bash

# Install host dependency
# https://docs.yoctoproject.org/ref-manual/system-requirements.html#required-packages-for-the-build-host

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )
SCRIPT_NAME=$(basename $0)

sudo_args="--preserve-env=USERNAME,USERPROFILE,http_proxy,https_proxy"

: install user
sudo ${sudo_args} -s useradd -r -s /usr/sbin/nologin -u 967 -U dockremap
sudo ${sudo_args} -s useradd -r -m -d /home/runner -s /bin/bash -u 968 -U runner

: wsl environment
[[ -n "$(command -v setx.exe)" ]] && setx.exe GNUPGHOME '%USERPROFILE%\.gnupg'
[[ -n "$(command -v setx.exe)" ]] && setx.exe WSLENV 'USERNAME:USERPROFILE/p'

sudo ${sudo_args} -s install -d -m 1777 /srv/repo
sudo ${sudo_args} -s install -d -m 0775 -o runner -g runner /srv/actions-runner

. /etc/os-release

case $ID in

almalinux* | rocky* )
    sudo ${sudo_args} -s dnf install -y -q epel-release
    sudo ${sudo_args} -s yum install -y -q dnf-plugins-core
    sudo ${sudo_args} -s dnf config-manager --set-enabled crb
    sudo ${sudo_args} -s dnf makecache
    sudo ${sudo_args} -s dnf upgrade -y
    sudo ${sudo_args} -s dnf install -y -q gawk make wget tar bzip2 gzip python3 unzip perl patch \
                            diffutils diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath \
                            ccache socat perl-Data-Dumper perl-Text-ParseWords perl-Thread-Queue \
                            python3-pip python3-GitPython python3-jinja2 python3-pexpect xz which \
                            rpcgen zstd
    sudo ${sudo_args} -s dnf install -y -q lz4 git-lfs repo s3cmd jq cifs-utils
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
                            iputils-ping python3-git python3-jinja2 python3-subunit zstd
    sudo ${sudo_args} -s locale-gen en_US.UTF-8
    sudo ${sudo_args} -s apt-get install -y -q apt-transport-https ca-certificates cifs-utils curl file git-lfs gnupg-agent \
                            jq libacl1 liblz4-tool libxml2-utils python-is-python3 rsync s3cmd \
                            software-properties-common time uidmap

    sudo ${sudo_args} -s systemctl disable apparmor.socket
    sudo ${sudo_args} -s systemctl disable apparmor.service

    sudo ${sudo_args} -s bash <<EOF    
rm -f /etc/apt/keyrings/github-cli.gpg        
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/github-cli.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main" >/etc/apt/sources.list.d/github-cli.list
apt-get update
apt-get install gh
EOF
    sudo ${sudo_args} -s bash <<EOF
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" >/etc/apt/sources.list.d/docker-ce.list
apt-get update
apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl disable --now docker.socket
systemctl disable --now docker.service
loginctl enable-linger $(id -un)
rm -fr /var/lib/docker/{buildkit,containers,engine-id,image,network,overlay2,plugins,runtimes,swarm,tmp,volumes}
EOF
    ;;

fedora* )
    sudo ${sudo_args} -s dnf install -y -q gawk make wget tar bzip2 gzip python3 unzip perl patch diffutils \
                            diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath ccache perl-Data-Dumper \
                            perl-Text-ParseWords perl-Thread-Queue perl-bignum socat python3-pexpect findutils \
                            which file cpio python python3-pip xz python3-GitPython python3-jinja2 rpcgen \
                            perl-FindBin perl-File-Compare perl-File-Copy perl-locale zstd lz4 hostname \
                            glibc-langpack-en libacl repo s3cmd python3-websockets jq cifs-utils
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
                            libacl1 git-repo s3cmd python3-websockets jq cifs-utils
    sudo ${sudo_args} -s pip3 install GitPython
    if [[ -z "$(command -v gh)" ]] ; then
    sudo ${sudo_args} -s zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo ${sudo_args} -s zypper ref
    sudo ${sudo_args} -s zypper install gh
    fi
    ;;

* )
    echo "Unrecognized OS $ID"
    exit 1
    ;;

esac

: install repo tool
curl --silent https://storage.googleapis.com/git-repo-downloads/repo >/tmp/repo
sudo ${sudo_args} -s install -D -m 0755 /tmp/repo /usr/local/bin/repo

sudo ${sudo_args} -s install -D -m 0755 $SCRIPT_DIR/setup-home-links.sh /usr/local/bin/setup-home-links.sh
sudo ${sudo_args} -s install -D -m 0755 $SCRIPT_DIR/setup-host-deps.sh /usr/local/bin/setup-host-deps.sh

# working folder per doc
sudo ${sudo_args} -s install -d -m 1777 /srv/repo

# general server settings
cat >/tmp/wsl-settings.conf <<EOF
fs.inotify.max_user_watches = 524288
kernel.apparmor_restrict_unprivileged_userns = 0
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
user.max_user_namespaces = 15000
EOF
sudo ${sudo_args} -s install -D -m 0644 /tmp/wsl-settings.conf /etc/sysctl.d/wsl-settings.conf

! grep "dockremap" /etc/subuid && sudo ${sudo_args} -s bash -c "echo dockremap:4294936224:65536 >>/tmp/subuid"
! grep "dockremap" /etc/subgid && sudo ${sudo_args} -s bash -c "echo dockremap:4294936224:65536 >>/tmp/subgid"

! grep "runner" /etc/subuid && sudo ${sudo_args} -s bash -c "echo runner:200000:65536 >>/tmp/subuid"
! grep "runner" /etc/subgid && sudo ${sudo_args} -s bash -c "echo runner:200000:65536 >>/tmp/subgid"

cat >/tmp/docker.json <<EOF
{
    "experimental": false,
    "exec-opts": ["native.cgroupdriver=systemd"],
    "userns-remap": "dockremap",
    "data-root": "/var/lib/docker",
    "log-driver": "journald",
    "log-level": "info",
    "insecure-registries": [],
    "registry-mirrors": [],
    "ip-forward": true,
    "ip-masq": true,
    "iptables": true,
    "ip6tables": true
}
EOF

sudo ${sudo_args} -s install -D -m 0644 /tmp/docker.json /etc/docker/daemon.json

exit 0
