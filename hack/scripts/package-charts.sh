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

REPO_DIR=stable
REPO_URL=https://ci-charts.storage.googleapis.com/$REPO_DIR/

INSTALLER_DIR=$1
CHARTS_DIR=${2:-charts}

if [ -z "$INSTALLER_DIR" ]; then
    echo "Missing argument for instller directory."
    echo "Correct usage: $SCRIPT_NAME <path_to_installer_repo> <charts_dir, defaults to charts>."
    exit 1
fi

pushd $1

# http://redsymbol.net/articles/bash-exit-traps/
function cleanup() {
    popd
}
trap cleanup EXIT

find $CHARTS_DIR -maxdepth 1 -mindepth 1 -type d -exec helm package {} -d {} \;
mkdir -p $SCRIPT_ROOT/$REPO_DIR
if [ -f $SCRIPT_ROOT/$REPO_DIR/index.yaml ]; then
    helm repo index --merge $SCRIPT_ROOT/$REPO_DIR/index.yaml --url $REPO_URL $CHARTS_DIR
else
    helm repo index --url $REPO_URL $CHARTS_DIR
fi
mv $CHARTS_DIR/index.yaml $SCRIPT_ROOT/$REPO_DIR/index.yaml
cd $CHARTS_DIR
find . -maxdepth 1 -mindepth 1 -type d -exec mkdir -p $SCRIPT_ROOT/$REPO_DIR/{} \;
find . -path ./$CHARTS_DIR -prune -o -name '*.tgz' -exec mv {} $SCRIPT_ROOT/$REPO_DIR/{} \;
