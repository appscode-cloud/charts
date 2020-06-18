#!/bin/bash
set -xeou pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

pushd $SCRIPT_ROOT

# helm repo index stable/ --url https://ci-charts.storage.googleapis.com/stable/

gsutil rsync -d -r stable gs://ci-charts/stable
gsutil acl ch -u AllUsers:R -r gs://ci-charts/stable

# sleep 10

# gcloud compute url-maps invalidate-cdn-cache cdn \
#   --project appscode-domains \
#   --host charts.appscode.com \
#   --path "/stable/index.yaml"

popd
