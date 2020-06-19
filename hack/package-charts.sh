#!/bin/bash
set -xeou pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")/..

REPO_URL=https://ci-charts.storage.googleapis.com/stable/

INSTALLER_DIR=$1
CHARTS_DIR=${2:-charts}

if [ -z "$INSTALLER_DIR" ]; then
	echo "Missing argument for instller directory."
	echo "Correct usage: $SCRIPT_NAME <path_to_installer_repo>."
	exit 1
fi

pushd $1

find $CHARTS_DIR -maxdepth 1 -mindepth 1 -type d -exec helm package {} -d {} \;
mkdir -p $SCRIPT_ROOT/stable
if [ -f $SCRIPT_ROOT/stable/index.yaml ]; then
	helm repo index --merge $SCRIPT_ROOT/stable/index.yaml --url $REPO_URL $CHARTS_DIR
else
	helm repo index --url $REPO_URL $CHARTS_DIR
fi
mv $CHARTS_DIR/index.yaml $SCRIPT_ROOT/stable/index.yaml
cd $CHARTS_DIR
find . -maxdepth 1 -mindepth 1 -type d -exec mkdir -p $SCRIPT_ROOT/stable/{} \;

pwd

find . -path ./$CHARTS_DIR -prune -o -name '*.tgz' -exec mv {} $SCRIPT_ROOT/stable/{} \;

popd
