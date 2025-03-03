#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && pwd )
SCRIPT_NAME=$(basename $0)

git_config=~/.config/git/config

install -d $(dirname $git_config)
touch $git_config

cp -f ${SCRIPT_DIR}/commit.template $(dirname $git_config)/commit.template

[[ $(git config --get user.name) ]] || git config --file $git_config user.name "Firstname Surname"
[[ $(git config --get user.email) ]] || git config --file $git_config user.email "username@users.noreply.github.com"
[[ $(git config --get user.signingkey) ]] || git config --file $git_config user.signingkey "GPG-KEY-ID"

echo "Edit $git_config and set appropriate values for the user, aka GPG-KEY-ID"

git config --file $git_config commit.gpgsign "true"
git config --file $git_config commit.template "$(dirname $git_config)/commit.template"

git config --file $git_config core.autocrlf "false"

git config --file $git_config http.sslVerify "true"
git config --file $git_config --unset http.version
git config --file $git_config --unset http.sslVersion
git config --file $git_config --unset http.lowSpeedLimit
git config --file $git_config --unset http.lowSpeedTime

git config --file $git_config init.defaultBranch "main"

git config --file $git_config trailer.sign.key "Signed-off-by"

git config --file $git_config url.'https://'.insteadOf git://

git config --file $git_config core.editor 'code --wait'

git config --file $git_config difftool.vscode.cmd 'code --wait --diff "$LOCAL" "$REMOTE"'
git config --file $git_config diff.tool vscode

git config --file $git_config mergetool.vscode.cmd 'code --wait "$MERGED"'
git config --file $git_config merge.tool vscode

# git config --file $git_config --remove-section difftool.sourcetree || true
# git config --file $git_config --remove-section mergetool.sourcetree || true

# git config --file $git_config includeif.'gitdir:**/github/'.path ~/.config/git/config-github
# git config --file ~/.config/git/config includeii.'gitdir:**/gitlab/'.path ~/.config/git/config-gitlab

# git config --file $git_config --unset alias.repo-lol
# git config --file $git_config --unset alias.repo-rrev
# git config --file $git_config --unset alias.repo-status
git config --file $git_config alias.repo-lol  "!repo forall -c 'echo \$REPO_PROJECT \$REPO_RREV && git log --graph --pretty=format:%C\(auto\)%h%d%Creset\ %C\(cyan\)\(%cr\)%Creset\ %C\(green\)%cn\ \<%ce\>%Creset\ %s'"
git config --file $git_config alias.repo-rrev "!repo forall -c 'echo \$REPO_PROJECT \$REPO_RREV && git checkout --track \$(git remote)/\$REPO_RREV'"
# git config --file $git_config alias.repo-status '!repo status'

git config --list --show-origin

exit 0
