#!/bin/bash

# Setup for a new WSL2 instance

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME=$(basename $0)

sudo_args="--preserve-env=USERNAME,USERPROFILE,http_proxy,https_proxy"

. /etc/os-release

if [[ -n "$(command -v setx.exe)" ]]; then
    if [[ -z "USERPROFILE" ]]; then
        setx.exe GNUPGHOME %USERPROFILE%\.gnupg
        setx.exe WSLENV USERNAME:USERPROFILE/p
        echo "Terminate the WSL2 instance and restart. Run ${SCRIPT_NAME} again to finalize."
        echo "wsl.exe --shutdown"
        exit 0
    fi
fi

# existing metadata could reflect uid/gid from a different instance; these settings attempt
# to mitigate the difference in uid between different distro if necessary.

if [[ -d "$USERPROFILE" ]]; then

    if [[ ! -e $USERPROFILE/.wslconfig ]]; then

    echo "Tune WSL2 service resource use at $USERPROFILE/.wslconfig"

    cat >/tmp/.wslconfig <<_EOF_
[wsl2]
# memory=32G
# processors=12
defaultVhdSize=549755813888
networkingMode=mirrored
autoProxy=false
dnsProxy=false

[experimental]
autoMemoryReclaim=dropcache
sparseVhd=true
_EOF_

    sudo ${sudo_args} install -D /tmp/.wslconfig $USERPROFILE/.wslconfig

    fi

    cat >/tmp/localhost <<_EOF_
# allow all commands with no-password
$(id -un) ALL=(ALL:ALL) NOPASSWD: ALL
_EOF_

    sudo ${sudo_args} install -D -m 0600 /tmp/localhost /etc/sudoers.d/localhost

    cat >/tmp/wsl.conf <<_EOF_
[boot]
systemd=true

[automount]
uid=$(id -u)
gid=$(id -g)
options=uid=$(id -u),gid=$(id -g),case=dir,umask=077,fmask=077,dmask=077

[user]
default=$(id -un)
_EOF_

    sudo ${sudo_args} install -D -m 0644 /tmp/wsl.conf /etc/wsl.conf

    cat >/tmp/fstab <<_EOF_
# drvfs mount to a drive letter
# M: /mnt/m drvfs rw,noatime,uid=$(id -u),gid=$(id -g),case=dir,umask=077,fmask=077,dmask=077 0 0
# bind mount to windows user home
# $USERPROFILE /mnt/home none bind,default 0 0
# nfs downloads, sstate-cache
# 192.168.1.10:/volume1/shared/downloads /nfs/downloads nfs nfsvers=3,rw,noatime,sec=sys,uid=1000,gid=1000 0 0
# 192.168.1.10:/volume1/shared/sstate-cache /nfs/sstate-cache nfs nfsvers=3,rw,noadime,sec=sys,uid=1000,gid=1000 0 0
_EOF_

    sudo ${sudo_args} install -D -m 0644 /tmp/fstab /etc/fstab

    sudo ${sudo_args} install -d /mnt/m

    sudo ${sudo_args} install -d /mnt/home

    sudo ${sudo_args} install -d /nfs/downloads

    sudo ${sudo_args} install -d /nfs/sstate-cache    

    sudo ${sudo_args} systemctl daemon-reload

    cat >/tmp/10-fs-inotify.conf <<_EOF_
fs.inotify.max_user_watches = 524288
_EOF_

    sudo ${sudo_args} install -D -m 0644 /tmp/10-fs-inotify.conf /etc/sysctl.d/10-fs-inotify.conf

    sudo ${sudo_args} sysctl --system

    # working folder per doc
    sudo ${sudo_args} install -d -m 1777 /srv/repo

    # install this script in instance
    sudo ${sudo_args} bash -c "rm -f /usr/local/bin/setup-home-links /usr/local/bin/setup-host-deps"
    sudo ${sudo_args} install -o root -g root -m 0755 ${SCRIPT_DIR}/setup-home-links.sh /usr/local/bin/setup-home-links.sh
    sudo ${sudo_args} install -o root -g root -m 0755 ${SCRIPT_DIR}/setup-host-deps.sh /usr/local/bin/setup-host-deps.sh

    # Creation of ~/.config WSL2 path at %USERPROFILE%
    mkdir -p $USERPROFILE/.config && ln -sf $USERPROFILE/.config ~/.config
    rm -f ~/.config/.config

    # Creation of ~/.gnupg WSL2 path at %USERPROFILE%
    mkdir -p $USERPROFILE/.gnupg && ln -sf $USERPROFILE/.gnupg ~/.gnupg
    rm -f ~/.gnupg/.gnupg

    # Creation of ~/.local WSL2 path at %USERPROFILE%
    mkdir -p $USERPROFILE/.local && ln -sf $USERPROFILE/.local ~/.local
    rm -f ~/.local/.local

    # Creation of ~/.ssh WSL2 path at %USERPROFILE%
    mkdir -p $USERPROFILE/.ssh && ln -sf $USERPROFILE/.ssh ~/.ssh
    rm -f ~/.ssh/.ssh

    # Creation of ~/.netrc WSL2 path at %USERPROFILE%; obtain personal web token
    touch $USERPROFILE/.netrc && ln -sf $USERPROFILE/.netrc ~/.netrc

    # example content ~/.netrc
    # machine github.com
    # login username
    # password webtoken

fi

# Install host dependency
# [[ -x ${SCRIPT_DIR}/setup-host-deps.sh ]] && ${SCRIPT_DIR}/setup-host-deps.sh

echo "Run ${SCRIPT_NAME} to repeat steps."
echo "Setup keys for git, gpg, and ssh if not already done."

if [[ -n "$(command -v setx.exe)" ]]; then
    echo "Terminate the WSL2 instance and restart. Run ${SCRIPT_NAME} again to finalize."
    echo "wsl.exe --shutdown"
fi
