#!/bin/bash
set -xeou pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

RELEASE=${RELEASE:-}
RELEASE_TRACKER=${RELEASE_TRACKER:-}
GIT_TAG=${GITHUB_REF#'refs/tags/'}

pushd $SCRIPT_ROOT

pr_branch=${GITHUB_REPOSITORY}/${GITHUB_RUN_ID}
git checkout -b $pr_branch
git add --all

ct_cmd="git commit -a -s -m \"Publish ${GITHUB_REPOSITORY}@${GIT_TAG} charts\""
if [ ! -z  "$RELEASE" ]; then
	ct_cmd="$ct_cmd --message \"Release: $RELEASE\""
fi
if [ ! -z  "$RELEASE_TRACKER" ]; then
	ct_cmd="$ct_cmd --message \"Release-tracker: $RELEASE_TRACKER\""
fi

eval "$ct_cmd"
git push -u origin HEAD -f
hub pull-request \
  --labels automerge \
  --message "$(git show -s --format=%B)"

popd
