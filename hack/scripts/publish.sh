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

# # ref: https://gist.github.com/joshisa/297b0bc1ec0dcdda0d1625029711fa24
# parse_url() {
#     proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
#     # remove the protocol
#     url="$(echo ${1/$proto/})"

#     IFS='/'                  # / is set as delimiter
#     read -ra PARTS <<<"$url" # str is read into an array as tokens separated by IFS
#     if [ ${PARTS[0]} != 'github.com' ] || [ ${#PARTS[@]} -ne 5 ]; then
#         echo "failed to parse relase-tracker: $url"
#         exit 1
#     fi
#     export RELEASE_TRACKER_OWNER=${PARTS[1]}
#     export RELEASE_TRACKER_REPO=${PARTS[2]}
#     export RELEASE_TRACKER_PR=${PARTS[4]}
# }

REPO_DIR=stable
[ -d "$REPO_DIR" ] || {
    echo "charts not found"
    exit 0
}

# helm repo index $REPO_DIR/ --url https://ci-charts.storage.googleapis.com/$REPO_DIR/

# sync charts
gsutil rsync -d -r $REPO_DIR gs://ci-charts/$REPO_DIR
gsutil acl ch -u AllUsers:R -r gs://ci-charts/$REPO_DIR

# invalidate cache
# sleep 10
# gcloud compute url-maps invalidate-cdn-cache cdn \
#   --project appscode-domains \
#   --host charts.appscode.com \
#   --path "/$REPO_DIR/index.yaml"







# RELEASE_TRACKER=

# while IFS=$': \t' read -r -u9 marker v; do
#     case $marker in
#         Release-tracker)
#             export RELEASE_TRACKER=$v
#             ;;
#         Release)
#             export RELEASE=$v
#             ;;
#     esac
# done 9< <(git show -s --format=%b)

# [ ! -z $RELEASE_TRACKER ] || {
#     echo "Release-tracker url not found."
#     exit 0
# }

# parse_url $RELEASE_TRACKER
# api_url="repos/${RELEASE_TRACKER_OWNER}/${RELEASE_TRACKER_REPO}/issues/${RELEASE_TRACKER_PR}/comments"
# msg="/chart-published $RELEASE"
# hub api "$api_url" -f body="$msg"
