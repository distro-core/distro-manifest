# Repository distro-manifest

This repository contains repo manifest files for the DISTRO Core distribution. The
distribution is based on Yocto tools to create a specialized Linux distro. The current
distribution available with the manifest [default.xml](./default.xml).

*   [DISTRO Core](https://github.com/distro-core)
*   [DISTRO Core Curated Mirrors](https://github.com/distro-core-curated-mirrors)

## Yocto Poky

*   [Yocto Releases](https://wiki.yoctoproject.org/wiki/Releases)

The development tasks manual is a invaluable resource to understanding the intricacies of using
the project for creation of specialized Linux distributions.

*   [Yocto Project Development Tasks](https://docs.yoctoproject.org/dev-manual/index.html)

Repo is a tool built on top of Git. Repo helps manage many Git repositories, does the uploads to
revision control systems, and automates parts of the development workflow. Repo is not meant to
replace Git, only to make it easier to work with Git. Git projects are captured into XML files
for use by the repo tool. This allows for many different configurations and revisions to be
captured into one location.

*   [Repo Tool information](https://android.googlesource.com/tools/repo)

# LICENSE Information

Copyright (c) 2024 brainhoard.com

For all original content supplied with this layer, unless otherwise specified, is licensed
as [LICENSE](./LICENSE).

Editorial discretion is asserted on specific inclusion of layers that may referenced. All
upstream packages and their source code come with their respective licenses. Individual packages
license terms are to be respected.

# Manifests

Manifests are descriptions of the repositories that are to be included in the build. The
repositories may be from the same organization or from different organizations. The manifest
files are stored in the .repo/manifests path upon initialization by the repo command. The
presence of a repository in layers/* does not automatically add it to the bitbake layers.

## Manifest Descriptions

Repository manifests

| Manifest | git refs | LTS | EOL | Description |
| --- | --- | --- | --- | --- |
| default.xml | HEAD | | | Stub manifest to force repo error in sync |
| distro-head-kirkstone.xml | HEAD | X | 2026-04 | Yocto Kirkstone (4.0), Development |
| distro-refs-kirkstone.xml | commit-id | | | Yocto Kirkstone (4.0), Successful Build |
| distro-head-scarthgap.xml | HEAD | X | 2028-05 | Yocto Scarthgap (5.0), Development |
| distro-refs-scarthgap.xml | commit-id | | | Yocto Scarthgap (5.0), Successful Build |

# CI/CD Github Actions

The path .github/workflows/ contains reusable Github Actions reusable workflows that
facilitate per MACHINE repositories to build and manage artifacts from the common
source scripting.

# Setup WSL

- Install Ubuntu 24.04
- Initialize WSL Instance
- Update WSL Instance
  ~~~
  cd /srv/repo
  git clone https://github.com/distro-core/distro-manifest.git
  pushd distro-manifest
  scripts/setup-home-links.sh
  scripts/setup-host-deps.sh
  popd
  rm -fr distro-manifest
  ~~~
- Restart WSL Instance
  - Close all terminals
  - Wait for default timeout to expire OR wsl.exe --shutdown
  - Open terminal session to WSL instance
- Initialize and perform first build
  ~~~
  scripts/setup-repo-init.sh
  layers/meta-distro/scripts/distro-build.sh --fetch-downloads
  layers/meta-distro/scripts/distro-build.sh
  ~~~

# Changes to .repo/manifests

The path .repo/manifests starts on a branch named default which is a reference to
the branch main. In order to checkout the main branch use the command to insure
git internal refs match the expected branch.

~~~
git -C .repo/manifests checkout --track origin/main
git -C .repo/manifests checkout -b issue-branch-slug
~~~

It is then possible to create a specific branch at this point which can be used
to submit work details.

~~~
git -C .repo/manifests checkout -b issue-branch-slug
~~~
