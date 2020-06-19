#!/bin/bash

# Copyright AppsCode Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
