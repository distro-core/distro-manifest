# WSL Ubuntu-24.04 Instance

**NOTE:** Any existing WSL instance named Ubuntu-24.04 is destroyed,
with any customizations which may have been made.

At a non-elevated command prompt; the process will generate
an UAW for installation.

~~~ batch
wsl --shutdown
wsl --update
~~~

Copy the cloud-init template to the required location before
installing the Ubuntu-24.04 instance. Download [Ubuntu-24.04.user-data](./.cloud-init/Ubuntu-24.04.user-data).
Edit the apt.proxy section if required, and install at the path
created by

~~~ batch
mkdir %USERPROFILE%\.cloud-init
~~~

Perform the installation of the Ubuntu-24.04 instance.

~~~ batch
wsl --unregister Ubuntu-24.04
wsl --install Ubuntu-24.04
~~~

Start the installed instance and allow it to provision. The
provisioning information is used by cloud-init to specialize
the instance. The distribution will exit when it completes
the provisioning.

~~~ batch
wsl --distribution Ubuntu-24.04
~~~

Exit the terminal; and reopen. A new menu selection for Ubunbtu-24.04
should now be present. If necessary, parameters for WSL can be modified
with the app "WSL Settings" to tune things such as the network mode,
number of allowed CPUs, memory limit, etc. It is required to shutdown
and restart WSL to pickup the changes.

These steps can be repeated periodically to update WSL, and install an
Ububtu-24.04 instance.

## Docker Initialize

Docker Community Edition is installed as part of the provisioning, but
is disabled until explicitly enabled.

~~~ batch
sudo systemctl enable docker.service docker.socket
sudo shutdown -r now
~~~

## Repo Initialize

Initialize to work with distro-core from its manifest:

~~~ sh
mkdir -p /srv/repo/distro-core && cd /srv/repo/distro-core
printf "\n\ny\n\n" | repo init -u https://github.com/distro-core/distro-manifest.git -b main -m distro-head-scarthgap.xml --no-clone-bundle --groups default
repo sync --force-sync --force-checkout --force-remove-dirty --no-repo-verify
~~~

Set the manifests path to track the upstream branch; on first
initialization, a local branch "default" is created.

~~~ sh
git -C .repo/manifests branch -D main
git -C .repo/manifests checkout --track origin/main
git -C .repo/manifests branch -D default
~~~

Initialize all of the repo managed layers to the HEAD of their
specific branchs.

~~~ sh
repo forall -c 'echo $REPO_PATH $REPO_RREV; git checkout --track $(git remote)/$REPO_RREV'
repo status
~~~
