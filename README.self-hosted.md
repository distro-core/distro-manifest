# GitHub Self Hosted Instance

## OS Installation

Prepare host with installation of

- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS

Configure all prerequsite dependencies to meet any required
compliance goals. Test for recovery and proper operation
through a few reboot and power cycles to eliminate additional
issues that will keep the host from restarting and recovering.

## OS Configuration

Proceed with system installation of git and git-lfs; note the
commands indicate the expected user.

~~~ bash
root% apt-get install git git-lfs
~~~

Proceed with git clone of the repository distro-core/distro-manifest

~~~ bash
root% git clone https://github.com/distro-core/distro-manifest.git
~~~

Execute the script to install bitbake host dependency tools; the
script will populate the current versions of setup scripts into
/usr/local/bin.

~~~ bash
root% cd distro-manifest
root% scripts/setup-host-deps.sh
~~~

Cleanup and remove the repository, it is not needed anymore.

~~~ bash
root% cd ..
root% rm -rf distro-manifest
~~~

## GitHub Actions Runner Installation

Installation details of the GitHub Actions Runner are available at
GitHub, to the repository admin, under Settings. Utilize a path that
will have sufficient space for all potential workflows.

~~~ bash
root% install -d -m 755 -o runner -g runner /srv/actions-runner
root% su -l runner
runner% cd /srv/actions-runner
runner% ...
~~~

## GitHub Actions Runner Configuration

Configuration details of the GitHub Actions Runner are available at
GitHub, to the repository admin, under Settings.

~~~ bash
runner% ...
runner% exit
root% cd /srv/actions-runner
root% ./svc.sh install runner
root% ./svc.sh start
~~~

Check the status of the GitHub Actions Runner to insure it is started
and waiting for jobs. A self-hosted runner is only capable of processing
jobs individually, one at a time. When a self-hosted runner is attached
to a specific repository, it is only capable of processing jobs for that
repository.

The benefit of a self-hosted runner is persistence between jobs of the
same repository will be saved on the local disk, unless explicitly
removed.

~~~ bash
root% ./svc.sh status
~~~

Again, reboot and power cycle, testing that host operation is stable,
consistent, and fully operating as expected. The GitHub Actions
Runner should reconnect for jobs every time.
