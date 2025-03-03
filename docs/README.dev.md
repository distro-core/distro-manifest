## SPECIAL INSTRUCTIONS: LICENSE STANDARD

LICENSE = GPLv3: GPLv3 may carry specific clauses that can potentially
have implications of intellectual property rights reassignment. Do not
bundle GPLv3 with any other license; GPLv3 may be incompatible with
the entire bundle. A contributor is expected to perform due diligence
as part of the contribution.

LICENSE = CLOSED: CLOSED licenses are not compatible with the open
source nature of **DISTRO**; please do not contribute any materials
with a CLOSED license. A contributor is expected to perform due
diligence as part of the contribution.

LICENSE = Proprietary: Proprietary licenses are not compatible with
the open source nature of **DISTRO**; please do not contribute any
materials with a Proprietary license. A contributor is expected to
perform due diligence as part of the contribution.

## SPECIAL INSTRUCTIONS: PACKAGE STANDARD

SGID/SUID Permissions - Programs should not arbitrarily be granted
SGID or SUID permissions; such permissions may be possible to utilize
as a security breach gadget. When necessary, use image-sgid-suid-set.bbclass
to keep the list of these exceptions in a central location. Do not
apply SGID or SUID permissions from a recipe. The appropriate location
for SGID or SUID permissions changes is in the image-sgid-suid-set.bbclass.

Packagegroups - All packagegroups for meta-distro are managed in a
single recipe: packagegroup-distro.bb. The recipe contains instructions
on how to add and remove package groups and associated recipes. By
policy, there is no method for .bbappends adding to packagegroups-distro;
make all changes directly to the packagegroup recipe.

## SPECIAL INSTRUCTIONS: LOCAL DEVELOPMENT

Repository meta-distro creates a local branch based from **yocto-lts-branch**
branch. The local branch naming scheme should include the the issue
number, and a short slug that helps to identify the feature.

~~~ bash
git checkout -b ISSUE-work-branch-slug scarthgap
~~~

Development testing and builds are perfomed when the local branch is
pushed to the server. This is an iterative process as necessary, using
the local branch, pushing, and building and testing of the feature. It
is expected that the local branch will be rebased to the tip of
**yocto-lts-branch** as needed to insure that builds and operation are
staying current with the **yocto-lts-branch** branch.

Repository layers should use the following git command to commit. This
insures a general format for the commit message. The commit message
should be a short description of the change. The commit command uses a
common template to create uniform commit log entries.

~~~ bash
git commit --template ~/.config/git/commit.template --edit --signoff --gpg-sign
git push -u origin ISSUE#-work-branch-slug
~~~

A pull request should be made when the local branch is ready to be
merged into the **yocto-lts-branch** branch. Use the repository server
to create the pull request from the local branch to the **yocto-lts-branch**
branch. Verify the pull request builds successfully before merging. The
pull request should be reviewed by a second person. The pull request
should be merged by a second person. The pull request should delete
the source branch upon successful merge. The pull request should be
closed by the repository server. Insure the pull request is rebased
to the HEAD of **yocto-lts-branch** branch and tested to build before
merging.

There are no upstream changes to the **yocto-lts-branch** branch. The
**yocto-lts-branch** branch is the main branch for all development
pull requests. The **yocto-lts-branch** branch is the main branch for
all releases. The repo tool is used to manage the commit-id's for all
repositories. The repo tool will sync all repositories to the commit-id's
for all branches used in the final build.

## SPECIAL INSTRUCTIONS: WSL CONFIGURATION

Install and activate the Windows components. Reboot on completion to
allow installation to complete. From an elevated command prompt

~~~ bash
@REM Elevated command prompt
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
~~~

Reboot the host if necessary.

Create C:\\Users\\USERNAME\\.wslconfig

~~~ text
[wsl2]
defaultVhdSize=549755813888
firewall=true
[experimental]
autoMemoryReclaim=disabled
sparseVhd=true
~~~

Copy *.user-data into C:\\Users\\USERNAME\\.cloud-init; the files supply
an initial provisioning for Ubuntu. See the files in this repository for
instructions to download and install.

Shutdown WSL, update WSL, unregister an existing Ubuntu instance, and
install a fresh instance. The fresh instance will terminate itself when
installation and provisioning has been completed.

~~~ batch
wsl.exe --shutdown
wsl.exe --update
wsl.exe --unregister Ubuntu-24.04
wsl.exe --install Ubuntu-24.04
wsl.exe --distribution Ubuntu-24.04
~~~

Close and restart Windows Terminal; run the Ubuntu instance from from
the Windows Terminal and continue with any additional customization.
*Note: Any customization outside of .cloud-init will be lost from an
instance that is unregistered.*

Using .wslconfig and the Windows Task Manager, it is possible to tune
host useage. Recommeded is to modify the number of avalable processors
to the WSL instaces. Memory adjustment to the WSL instance is the
secondary resource which can be managed for performance.

### WSL DISK OPTIMIZATION

Bitbake may emit a warning message about running under WSL.

~~~ text
WARNING: You are running bitbake under WSLv2, this works properly but you should optimize your VHDX file eventually to avoid running out of storage space
~~~

Prepare using PowerShell; terminate WSL and identify the location of the VHXD.
Make note of the path to the filesystem virtual disk.

~~~ text
wsl --shutdown
(Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | Where-Object { $_.GetValue("DistributionName") -eq 'Ubuntu-24.04' }).GetValue("BasePath") + "\ext4.vhdx"
~~~

Using DISKPART

~~~ text
select vdisk file="C:\...\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
~~~

[Microsoft WSL disk space information](https://learn.microsoft.com/en-us/windows/wsl/disk-space)

### GPG KEY SETTINGS

[GitHub GPG settings](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
can be referenced online for additional information.

Check for nominal gpg configuration settings. Insure that a key
is available for the GitHub user.email being used for Git. Record
the value later referenced as GPG-KEY-ID.

~~~ bash
$ gpg --list-secret-keys --keyid-format=long XXXXXX+username@users.noreply.github.com
~~~

The GPG-KEY-ID should be 16 hexdigits in length.

### GIT USER SETTINGS

Check for nominal git configuration settings; replace user.name,
user.email, user.signingkey as needed.

~~~ bash
$ git config --list --show-origin | | grep 'user[.]'
file:/home/user/.config/git/config  user.name=Firstname Surname
file:/home/user/.config/git/config  user.email=XXXXXX+username@users.noreply.github.com
file:/home/user/.config/git/config  user.signingkey=GPG-KEY-ID
~~~

### ENVIRONMENT VARIABLES

Environment variables are utilized to selectivly set specific bitbake
variables in the example build script located at scripts/distro-build.
It is possible to extend the list by use of environment variables as
shown. Other variables can be found in the example CI/CD script
scripts/distro-build.

~~~ bash
additionsadd DISTRO
additionsadd MACHINE
additionsadd BB_NUMBER_THREADS
additionsadd PARALLEL_MAKE
additionsadd DEPLOY_DIR
~~~

### WSL DOES NOT LAUNCH

A corrupted WSL instance may not start; in this case, unregister the
WSL instance and then reinstall. It may be necessary to restart Windows
before WSL will respond and allow the unregister command to function.

### WSL CONVENIENCE SCRIPTS

The convenience scripts can be place in C:\\Users\\USERNAME\\.local\\bin\\
when the WSL instance is provisioned with .cloud-init templates from this
repository.

C:\\Users\\USERNAME\\.local\\bin\\git-commit

~~~ bash
#!/bin/bash
# execute at the root of the layer, adds new commit
git add .
git commit --template ~/.config/git/commit.template --edit --signoff --gpg-sign
git push
~~~

C:\\Users\\USERNAME\\.local\\bin\\git-commit-amend

~~~ bash
#!/bin/bash
# execute at the root of the layer, rewrites branch HEAD commit
git add .
git commit --template ~/.config/git/commit.template --edit --signoff --gpg-sign --amend
git push --force
~~~

C:\\Users\\USERNAME\\.local\\bin\\distro-builds

~~~ bash
#!/bin/bash
# execute at the root of the manifest folder
git -C .repo/manifests checkout $(git -C .repo/manifests rev-parse HEAD)
repo forall -c 'git checkout $REPO_LREV'
repo sync
layers/meta-distro/scripts/distro-build.sh --preserve-build
layers/meta-distro/scripts/distro-build.sh --preserve-build --machine=wsl-amd64
~~~
