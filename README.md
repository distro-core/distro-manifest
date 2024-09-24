# Repository distro-manifest

This repository contains repo manifest files for the Distro Core distribution. The
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

# Manifests

Manifests are descriptions of the repositories that are to be included in the build. The
repositories may be from the same organization or from different organizations. The manifest
files are stored in the .repo/manifests path upon initialization by the repo command. The
presence of a repository in layers/* does not automatically add it to the bitbake layers.

## Manifest Descriptions

[Additional manifest information](https://github.com/distro-core/meta-distro/blob/scarthgap/docs/README.manifest.md)

Repository manifests

| Manifest | git refs | LTS | EOL | Description |
| --- | --- | --- | --- | --- |
| default.xml | HEAD | | | Soft link to current manifest |
| distro-head-kirkstone.xml | HEAD | X | 2026-04 | Yocto Kirkstone (4.0), Development |
| distro-head-scarthgap.xml | HEAD | X | 2028-05 | Yocto Scarthgap (5.0), Development |
| distro-refs-kirkstone.xml | commit-id | | | Yocto Kirkstone (4.0), Successful Build |
| distro-refs-scarthgap.xml | commit-id | | | Yocto Scarthgap (5.0), Successful Build |
| remotes-github.xml | - | | | Repo Remotes Definitions, Mirrors |
| remotes-origin.xml | - | | | Repo Remotes Definitions, Upstream |
| upstream-head-kirkstone.xml | HEAD | X | 2026-04 | Yocto Kirkstone (4.0), Upstream Definitions |
| upstream-head-scarthgap.xml | HEAD | X | 2028-05 | Yocto Scarthgap (5.0), Upstream Definitions |
