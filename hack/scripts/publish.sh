#!/bin/bash
set -eou pipefail

SCRIPT_ROOT=$(realpath $(dirname "${BASH_SOURCE[0]}")/..)
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")/..

REPO_DIR=stable

pushd $SCRIPT_ROOT

[ -d "$REPO_DIR" ] || {
	echo "charts not found";
	exit 0;
}

# helm repo index $REPO_DIR/ --url https://ci-charts.storage.googleapis.com/$REPO_DIR/

gsutil rsync -d -r $REPO_DIR gs://ci-charts/$REPO_DIR
gsutil acl ch -u AllUsers:R -r gs://ci-charts/$REPO_DIR

# sleep 10

# gcloud compute url-maps invalidate-cdn-cache cdn \
#   --project appscode-domains \
#   --host charts.appscode.com \
#   --path "/$REPO_DIR/index.yaml"

popd
