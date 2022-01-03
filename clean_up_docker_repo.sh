#!/usr/bin/env bash
set -e

if [ "$#" != "1" ]; then
	echo "Usage: $0 repository"
	exit 1
fi

REPOSITORY="$1"

TEMP=$(mktemp -d)
cd $TEMP

function cleanup() {
    cd /
    rm -rf $TEMP
}
trap cleanup EXIT

echo "Fetching data"
az acr repository show-manifests --name leanixacr  --repository "$REPOSITORY"  -ojson > all_manifests
echo "Processing data"
YESTERDAY="$(date --date=yesterday +%Y-%m-%d)" # GNU coreutils date required
cat all_manifests | jq -r ".[] | select(.timestamp < \"$YESTERDAY\").tags | .[]" > old_tags
cat all_manifests | jq -r '.[].tags | .[] | select(startswith("master_20"))' | sort -r | head -n20 > keep_tags # last 20 masters
echo latest >> keep_tags
comm -23 <(sort old_tags) <(sort keep_tags) > delete_tags # delete_tags = old_tags - keep_tags

wc -l keep_tags
wc -l delete_tags

echo "Deleting old tags"

cat delete_tags | xargs -t -n1 -I% az acr repository delete --name leanixacr --image "$REPOSITORY:%" --yes
