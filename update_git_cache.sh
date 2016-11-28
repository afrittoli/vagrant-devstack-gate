#!/bin/bash
# Update the local git cache

BASE_DIR=$(cd $(dirname $0); pwd)
echo $BASE_DIR

function update_git {
    local repo=$1

    pushd $repo
    git checkout master
    git reset --hard
    if ! git clean -x -f -d -q ; then
        sleep 1
        git clean -x -f -d -q
    fi
    git pull
    popd
}

echo -e "$(date) Updating git repos\n" > $BASE_DIR/update_git_cache.log
printf "Updating repos: "
for repo in $(find ./git -type d -maxdepth 2 -mindepth 2); do
    update_git $BASE_DIR/$repo >> $BASE_DIR/update_git_cache.log 2>&1
    printf " $(basename $repo)"
done
