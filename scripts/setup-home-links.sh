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

    cat >/tmp/.wslconfig <<EOF
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
EOF

    sudo ${sudo_args} -s install -D /tmp/.wslconfig $USERPROFILE/.wslconfig

    fi

    cat >/tmp/localhost <<EOF
# allow all commands with no-password
$(id -un) ALL=(ALL:ALL) NOPASSWD: ALL
EOF

    sudo ${sudo_args} -s install -D -m 0600 /tmp/localhost /etc/sudoers.d/localhost

    cat >/tmp/wsl.conf <<EOF
[boot]
systemd=true

[automount]
uid=$(id -u)
gid=$(id -g)
options=uid=$(id -u),gid=$(id -g),case=dir,umask=077,fmask=077,dmask=077

[user]
default=$(id -un)
EOF

    sudo ${sudo_args} -s install -D -m 0644 /tmp/wsl.conf /etc/wsl.conf

    cat >/tmp/fstab <<EOF
# drvfs mount to a drive letter
# M: /mnt/m drvfs rw,noatime,uid=$(id -u),gid=$(id -g),case=dir,umask=077,fmask=077,dmask=077 0 0
# bind mount to windows user home
# $USERPROFILE /mnt/home none bind,default 0 0
# nfs downloads, sstate-cache
# 192.168.1.10:/volume1/shared/downloads     /nfs/downloads     nfs  nfsvers=3,user,rw,sec=sys,uid=$(id -u),gid=$(id -g).noauto,x-systemd.automount 0 0
# 192.168.1.10:/volume1/shared/sstate-cache  /nfs/sstate-cache  nfs  nfsvers=3,user,rw,sec=sys,uid=$(id -u),gid=$(id -g),noauto,x-systemd.automount 0 0
# cifs downloads, sstate-cache, requires /home/$(id -un)/.smbcredentials
# //192.168.1.10/shared/downloads            /mnt/downloads     cifs vers=3,user,rw,credentials=/home/$(id -un)/.smbcredentials,iocharset=utf8,uid=$(id -u),forceuid,gid=$(id -g),forcegid,noauto,x-systemd.automount 0 0
# //192.168.1.10/shared/sstate-cache         /mnt/sstate-cache  cifs vers=3,user,rw,credentials=/home/$(id -un)/.smbcredentials,iocharset=utf8,uid=$(id -u),forceuid,gid=$(id -g),forcegid,noauto,x-systemd.automount 0 0
EOF

    sudo ${sudo_args} -s install -D -m 0644 /tmp/fstab /etc/fstab

    cat >/tmp/smbcredentials <<EOF
user=username
pass=password
EOF

    sudo ${sudo_args} -s install -D -m 0600 /tmp/smbcredentials /root/.smbcredentials

    sudo ${sudo_args} -s install -d /mnt/m

    sudo ${sudo_args} -s install -d /mnt/home

    sudo ${sudo_args} -s install -d /mnt/downloads

    sudo ${sudo_args} -s install -d /mnt/sstate-cache

    sudo ${sudo_args} -s install -d /nfs/downloads

    sudo ${sudo_args} -s install -d /nfs/sstate-cache

    sudo ${sudo_args} -s systemctl daemon-reload

    cat >/tmp/10-fs-inotify.conf <<EOF
fs.inotify.max_user_watches = 524288
EOF

    sudo ${sudo_args} -s install -D -m 0644 /tmp/10-fs-inotify.conf /etc/sysctl.d/10-fs-inotify.conf

    sudo ${sudo_args} -s sysctl --system

    # working folder per doc
    sudo ${sudo_args} -s install -d -m 1777 /srv/repo

    # Creation of ~/.config WSL2 path at %USERPROFILE%
    install -d $USERPROFILE/.config && ln -sf $USERPROFILE/.config ~/.config
    rm -f ~/.config/.config

    # Creation of ~/.gnupg WSL2 path at %USERPROFILE%
    install -d $USERPROFILE/.gnupg && ln -sf $USERPROFILE/.gnupg ~/.gnupg
    rm -f ~/.gnupg/.gnupg

    # Creation of ~/.local WSL2 path at %USERPROFILE%
    install -d $USERPROFILE/.local && ln -sf $USERPROFILE/.local ~/.local
    rm -f ~/.local/.local

    # Creation of ~/.ssh WSL2 path at %USERPROFILE%
    install -d $USERPROFILE/.ssh && ln -sf $USERPROFILE/.ssh ~/.ssh
    rm -f ~/.ssh/.ssh

    # Creation of ~/.netrc WSL2 path at %USERPROFILE%; obtain personal web token
    touch $USERPROFILE/.netrc && ln -sf $USERPROFILE/.netrc ~/.netrc

    # example content ~/.netrc
    # machine github.com
    # login username
    # password webtoken

fi

# install this script in instance
sudo ${sudo_args} -s rm -f /usr/local/bin/setup-home-links /usr/local/bin/setup-host-deps
sudo ${sudo_args} -s install -o root -g root -m 0755 ${SCRIPT_DIR}/setup-home-links.sh /usr/local/bin/setup-home-links.sh
sudo ${sudo_args} -s install -o root -g root -m 0755 ${SCRIPT_DIR}/setup-host-deps.sh /usr/local/bin/setup-host-deps.sh

# Install host dependency
# [[ -x ${SCRIPT_DIR}/setup-host-deps.sh ]] && ${SCRIPT_DIR}/setup-host-deps.sh

echo "Run ${SCRIPT_NAME} to repeat steps."
echo "Setup keys for git, gpg, and ssh if not already done."

if [[ -n "$(command -v setx.exe)" ]]; then
    echo "Terminate the WSL2 instance and restart. Run ${SCRIPT_NAME} again to finalize."
    echo "wsl.exe --shutdown"
fi
