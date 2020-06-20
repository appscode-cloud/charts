#!/bin/bash

GCP_PROJECT=
BUCKET=ci-charts

REPO_DOMAIN=ci-charts.storage.googleapis.com
REPO_DIR=stable
REPO_URL=https://${REPO_DOMAIN}/${REPO_DIR}/

# ref: https://gist.github.com/joshisa/297b0bc1ec0dcdda0d1625029711fa24
parse_url() {
    proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    # remove the protocol
    url="$(echo ${1/$proto/})"

    IFS='/'                  # / is set as delimiter
    read -ra PARTS <<<"$url" # str is read into an array as tokens separated by IFS
    if [ ${PARTS[0]} != 'github.com' ] || [ ${#PARTS[@]} -ne 5 ]; then
        echo "failed to parse relase-tracker: $url"
        exit 1
    fi
    export RELEASE_TRACKER_OWNER=${PARTS[1]}
    export RELEASE_TRACKER_REPO=${PARTS[2]}
    export RELEASE_TRACKER_PR=${PARTS[4]}
}
