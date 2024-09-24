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

- SPDX-License-Identifier: [GPL-2.0-or-later](https://spdx.org/licenses/GPL-2.0-or-later.html)
- SPDX-License-Identifier: [MIT](https://spdx.org/licenses/MIT.html)

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
| default.xml | HEAD | | | Soft link to current manifest |
| distro-head-kirkstone.xml | HEAD | X | 2026-04 | Yocto Kirkstone (4.0), Development |
| distro-refs-kirkstone.xml | commit-id | | | Yocto Kirkstone (4.0), Successful Build |
| distro-head-scarthgap.xml | HEAD | X | 2028-05 | Yocto Scarthgap (5.0), Development |
| distro-refs-scarthgap.xml | commit-id | | | Yocto Scarthgap (5.0), Successful Build |

# Common Scripting

The path scripts/ contains scripts that are leveraged in different manners including
CI/CD descriptions.

# CI/CD Github Actions

The path .github/workflows/ contains reusable Github Actions reusable workflows that
facilitate per MACHINE repositories to build and manage artifacts from the common
source scripting.
