#!/bin/bash

repo forall -g workflows -c '
echo $REPO_PATH
cd $REPO_PATH
gh workflow run self-hosted-fetch.yml -f chosen_os=ubuntu-24.04 -f EXTRA_USER_CLASSES=none
gh workflow run self-hosted-build.yml -f chosen_os=ubuntu-24.04 -f EXTRA_USER_CLASSES=none
gh workflow run github-hosted-parse.yml
gh workflow run github-hosted-fetch.yml -f chosen_os=ubuntu-24.04 -f EXTRA_USER_CLASSES=none
gh workflow run github-hosted-build.yml -f chosen_os=ubuntu-24.04 -f EXTRA_USER_CLASSES=none

'

# for i in workflows/workflows-* ; do
# pushd $i
# gh workflow run self-hosted-fetch.yml -f chosen_os=ubuntu-24.04 -f EXTRA_USER_CLASSES=none
# gh workflow run self-hosted-build.yml -f chosen_os=ubuntu-24.04 -f EXTRA_USER_CLASSES=none
# popd
# done
