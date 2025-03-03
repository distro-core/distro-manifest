#!/bin/bash

# Setup for a new WSL2 instance

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )
SCRIPT_NAME=$(basename $0)

# sudo_args="--preserve-env=USERNAME,USERPROFILE,http_proxy,https_proxy"

. /etc/os-release

if [[ -n "$(command -v setx.exe)" ]]; then
    if [[ -z "$USERPROFILE" ]]; then
        setx.exe GNUPGHOME '%USERPROFILE%\.gnupg'
        setx.exe WSLENV 'USERNAME:USERPROFILE/p'
        echo "Terminate the WSL2 instance and restart. Run ${SCRIPT_NAME} again to finalize."
        echo "wsl.exe --shutdown"
        exit 0
    fi
fi

# existing metadata could reflect uid/gid from a different instance; these settings attempt
# to mitigate the difference in uid between different distro if necessary.

if [[ -d "$USERPROFILE" ]]; then

    user_uid=$(id -u)
    user_name=$(id -un)
    group_gid=$(id -g)
    group_name=$(id -gn)

    if [[ ! -e $USERPROFILE/.wslconfig ]]; then

        echo "Tune WSL2 service resource use at $USERPROFILE/.wslconfig"

        cat <<EOF >/tmp/.wslconfig 
[wsl2]
# memory=32G
# processors=12
defaultVhdSize=549755813888
networkingMode=mirrored
autoProxy=false
dnsProxy=false
firewall=true
guiApplications=true
# kernelCommandLine=cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1
[interop]
enabled=true
[experimental]
autoMemoryReclaim=disabled
sparseVhd=true
EOF

        sudo ${sudo_args} -s install -D /tmp/.wslconfig $USERPROFILE/.wslconfig

    fi

    cat <<EOF >/tmp/localsudoers 
# allow all commands with no-password
$user_name ALL=(ALL:ALL) NOPASSWD:ALL
EOF

    sudo ${sudo_args} -s install -D -m 0600 /tmp/localsudoers /etc/sudoers.d/localsudoers

    cat <<EOF >/tmp/wsl.conf 
[boot]
systemd=true
[automount]
uid=$user_uid
gid=$group_gid
options=uid=$user_uid,gid=$group_gid,case=dir,umask=077,fmask=077,dmask=077
[user]
default=$user_name
EOF

    sudo ${sudo_args} -s install -D -m 0644 /tmp/wsl.conf /etc/wsl.conf

    cat <<EOF >/tmp/fstab 
# drvfs mount to a drive letter
# M: /mnt/m drvfs rw,noatime,uid=$user_uid,gid=$group_gid,case=dir,umask=077,fmask=077,dmask=077 0 0
# bind mount to windows user home
# $USERPROFILE /mnt/home none bind,default 0 0
# nfs downloads, sstate-cache
# 192.168.1.10:/volume1/shared/downloads     /nfs/downloads     nfs  nfsvers=3,user,rw,sec=sys,uid=$user_uid,gid=$group_gid.noauto,x-systemd.automount 0 0
# 192.168.1.10:/volume1/shared/sstate-cache  /nfs/sstate-cache  nfs  nfsvers=3,user,rw,sec=sys,uid=$user_uid,gid=$group_gid,noauto,x-systemd.automount 0 0
# cifs downloads, sstate-cache, requires /home/$user_name/.smbcredentials
# //192.168.1.10/shared/downloads            /mnt/downloads     cifs vers=3,user,rw,credentials=/home/$user_name/.smbcredentials,iocharset=utf8,uid=$user_uid,forceuid,gid=$group_gid,forcegid,noauto,x-systemd.automount 0 0
# //192.168.1.10/shared/sstate-cache         /mnt/sstate-cache  cifs vers=3,user,rw,credentials=/home/$user_name/.smbcredentials,iocharset=utf8,uid=$user_uid,forceuid,gid=$group_gid,forcegid,noauto,x-systemd.automount 0 0
EOF

    sudo ${sudo_args} -s install -D -m 0644 /tmp/fstab /etc/fstab

    cat >/tmp/smbcredentials <<EOF
user=username
pass=password
EOF

    sudo ${sudo_args} -s install -D -m 0600 -o $user_name -g $group_name /tmp/smbcredentials /home/$user_name/.smbcredentials

    sudo ${sudo_args} -s install -d /mnt/m

    sudo ${sudo_args} -s install -d /mnt/home

    sudo ${sudo_args} -s install -d /mnt/downloads

    sudo ${sudo_args} -s install -d /mnt/sstate-cache

    sudo ${sudo_args} -s install -d /nfs/downloads

    sudo ${sudo_args} -s install -d /nfs/sstate-cache

    sudo ${sudo_args} -s systemctl daemon-reload

    sudo ${sudo_args} -s sysctl --system

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

    # Creation of ~/.netrc WSL2 path at %USERPROFILE%; obtain personal web token
    touch $USERPROFILE/.s3cfg && ln -sf $USERPROFILE/.s3cfg ~/.s3cfg

    # example content ~/.netrc
    # machine github.com
    # login username
    # password webtoken

    echo "Run ${SCRIPT_NAME} to repeat steps."
    echo "Setup keys for git, gpg, and ssh if not already done."

    exit 0

fi

if [[ -n "$(command -v setx.exe)" ]]; then
    echo "Terminate the WSL2 instance and restart. Run ${SCRIPT_NAME} again to finalize."
    echo "wsl.exe --shutdown"
fi
