#!/bin/bash
set -eou pipefail

SCRIPT_ROOT=$(realpath $(dirname "${BASH_SOURCE[0]}")/..)
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
pushd $SCRIPT_ROOT

# http://redsymbol.net/articles/bash-exit-traps/
function cleanup() {
    popd
}
trap cleanup EXIT

RELEASE=${RELEASE:-}
RELEASE_TRACKER=${RELEASE_TRACKER:-}
GIT_TAG=${GITHUB_REF#'refs/tags/'}

pr_branch=${GITHUB_REPOSITORY}@${GIT_TAG}
git checkout -b $pr_branch
git add --all

ct_cmd="git commit -a -s -m \"Publish $pr_branch charts\""
ct_cmd="$ct_cmd --message \"Repository: github.com/$GITHUB_REPOSITORY\""
ct_cmd="$ct_cmd --message \"Tag: $GIT_TAG\""
if [ ! -z "$RELEASE" ]; then
    ct_cmd="$ct_cmd --message \"Release: $RELEASE\""
fi
if [ ! -z "$RELEASE_TRACKER" ]; then
    ct_cmd="$ct_cmd --message \"Release-tracker: $RELEASE_TRACKER\""
fi

eval "$ct_cmd"
git push -u origin HEAD -f
hub pull-request \
    --labels automerge \
    --message "$(git show -s --format=%B)" || true
