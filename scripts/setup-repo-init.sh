#!/bin/bash

DISTRO_CODENAME=scarthgap

install -d -m 0755 /srv/repo/distro-core && cd /srv/repo/distro-core || exit 0

printf "\n\ny\n\n" | repo init -u https://github.com/distro-core/distro-manifest.git -b main -m distro-head-$DISTRO_CODENAME.xml --no-clone-bundle --groups default,workflows
repo sync --force-sync --force-checkout --force-remove-dirty --no-repo-verify

# checkout repo manifest branches
repo forall -c 'echo $REPO_PATH $REPO_RREV; git checkout --track $(git remote)/$REPO_RREV'
repo status
