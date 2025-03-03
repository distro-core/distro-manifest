# Self Hosted

~~~ bash
: uid=root: install user
sudo ${sudo_args} -s useradd -r -m -d /home/runner -s /bin/bash -u 968 -U runner

: uid=root: create actions-runner paths
install -d -m 1777 /srv/repo
install -D -u runner -g runner /srv/repo/actions-runner

: uid=root/runner: install actions-runner
su -l runner
cd /srv/repo/actions-runner
~~~

[Install actions runner](https://github.com/organizations/distro-core/settings/actions/runners/new) then exit
the shell back to uid=root.

~~~ text
:uid=root to install service
cd /srv/repo/actions-runner
./svc.sh install runner
./svc.sh start
./svc.sh status
~~~
