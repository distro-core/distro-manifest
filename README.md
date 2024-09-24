# Repository distro-manifest

This repository contains repo manifest files for the DISTRO Core distribution. The
distribution is based on Yocto tools to create a specialized Linux distro. The current
distribution available with the manifest [default.xml](./default.xml).

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
| distro-head-scarthgap.xml | HEAD | X | 2028-05 | Yocto Scarthgap (5.0), Development |
| distro-refs-kirkstone.xml | commit-id | | | Yocto Kirkstone (4.0), Successful Build |
| distro-refs-scarthgap.xml | commit-id | | | Yocto Scarthgap (5.0), Successful Build |

# Build Artifact Generation

One time host initialization

```bash
# initialization of proxy
# cat >>~/.bashrc <<EOF
# export http_proxy=http://localhost:3128
# EOF

# initialization of WSL2 instance soft links to USERPROFILE
.repo/manifests/scripts/setup-home-links.sh

# initialization of yocto host dependency
.repo/manifests/scripts/setup-host-deps.sh
```

Prerequsite dependency is the creation of ~/.config/s3cmd/config

```bash
mkdir -p ~/.config/s3cmd
s3cmd --config ~/.config/s3cmd/config --configure
```

Generation of build artifacts can be performed by use of the wrapper script to bitbake. The
following table indicates artifacts that have been generated at some point successfully. See
.repo/manifests/scripts/images-build.sh for additional parameters.

-   downloads: all distro, all machine

    ```bash
    distros="distro-core" # distro-core-gui distro-musl distro-musl-gui
    machines="com-cexpress-bt com-cexpress-sl sbc-gene-bt05 sbc-raspberrypi5 sbc-xavier-nx-devkit"
    targets="distro-image" # distro-sdk-image
    export BB_NO_NETWORK="0"
    .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}" --target-flags="--continue" --fetch-downloads --clean-sstate
    ```

-   downloads: update s3://distro-core-downloads

    ```bash
    bucket=distro-core-downloads
	s3cmd --config ~/.config/s3cmd/config setacl s3://$bucket --acl-private
	s3cmd --config ~/.config/s3cmd/config expire s3://$bucket --expiry-days 365
    # s3cmd --config ~/.config/s3cmd/config del --recursive --force s3://$bucket
	s3cmd --config ~/.config/s3cmd/config sync --recursive --acl-public --delete-removed --progress \
		--exclude 'git2/*' --exclude '*.done' --exclude '*.lock' --exclude 'tmp*' --exclude '*tmp' \
		build/downloads/ s3://$bucket/
    ```

-   build: all distro, all machine

    ```bash
    distros="distro-core" # distro-core-gui distro-musl distro-musl-gui
    machines="com-cexpress-bt com-cexpress-sl sbc-gene-bt05 sbc-raspberrypi5 sbc-xavier-nx-devkit"
    targets="distro-image" # distro-sdk-image
    export BB_NO_NETWORK="1"
    .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}"
    ```

-   build: update s3://distro-core-sstate-cache

    ```bash
    bucket=distro-core-sstate-cache
	s3cmd --config ~/.config/s3cmd/config setacl s3://$bucket --acl-private
	s3cmd --config ~/.config/s3cmd/config expire s3://$bucket --expiry-days 365
    # s3cmd --config ~/.config/s3cmd/config del --recursive --force s3://$bucket
	s3cmd --config ~/.config/s3cmd/config sync --recursive --acl-public --delete-removed --progress \
		build/sstate-cache/ s3://$bucket/
    ```

-   ostree: update s3://distro-core-artifacts

    ```bash
    distros="distro-core" # distro-core-gui distro-musl distro-musl-gui
    machines="com-cexpress-bt com-cexpress-sl sbc-gene-bt05 sbc-raspberrypi5 sbc-xavier-nx-devkit"
    targets="distro-image" # distro-sdk-image
    bucket=distro-core-artifacts
	s3cmd --config ~/.config/s3cmd/config expire s3://$bucket
	s3cmd --config ~/.config/s3cmd/config setacl s3://$bucket --acl-private
    for distro in ${distros} ; do
		for machine in ${machines} ; do
            deploy_dir=build/${distro}/tmp-${machine}/deploy
            for dir in ostree_repo ; do
                if [[ -d ${deploy_dir}/${dir} ]]; then
                    # s3cmd --config ~/.config/s3cmd/config del --recursive --force s3://$bucket/${distro}/${machine}/${dir}
                    s3cmd --config ~/.config/s3cmd/config sync --recursive --acl-public --delete-removed --progress \
                        ${deploy_dir}/${dir} s3://$bucket/${distro}/${machine}/${dir}/
                fi
            done
		done
	done
    ```

-   build: distro-core

    ```bash
    distros="distro-core"
    machines="sbc-gene-bt05"
    targets="distro-image" # distro-sdk-image
    .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}"
    ```

-   build: distro-core-gui

    ```bash
    distros="distro-core-gui"
    machines="sbc-gene-bt05"
    targets="distro-image" # distro-sdk-image
    .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}"
    ```

-   build: distro-musl

    ```bash
    distros="distro-musl"
    machines="sbc-gene-bt05"
    targets="distro-image" # distro-sdk-image
    .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}"
    ```

-   build: distro-musl-gui

    ```bash
    distros="distro-musl-gui"
    machines="sbc-gene-bt05"
    targets="distro-image" # distro-sdk-image
    .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}"
    ```
<!--
-   build: distro-tiny (incomplete)

    ```bash
    # distros="distro-tiny"
    # machines="sbc-gene-bt05"
    # targets="distro-image" # distro-sdk-image
    # .repo/manifests/scripts/images-build.sh --distro="${distros}" --machine="${machines}" --target="${targets}"
    ```
-->
