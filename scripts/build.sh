set -e

ORG_NAME=noxhalley
REPO_PREFIX=contracts
SUPPORTED_LANGUAGES=("go")

enterDir() {
    echo "Entering $1"
    pushd $1 >/dev/null
}

leaveDir() {
    echo "Leaving $(pwd)"
    popd >/dev/null
}

publish() {
    repository=$1
    version=$2

    enterDir "repositories/${repository}"

    git add -null
    if ! git diff --exit-code >/dev/null; then
        git add .
        git stash
        git rm -r
        git stash pop || true
        git add .
        git commit \
            -m "Add generated version ${version} [CI]" \
            -m "${GENERATED_BY}"
        git tag -a $version -m "Version $version"
        git push --follow-tags origin HEAD
    else
        echo "No changes detected for $repository"
    fi

    leaveDir
}

build_go() {
    go mod init github.com/${ORG_NAME}/${REPO_PREFIX}-go
    go mod tidy
}

mkdir repositories
for lang in "${SUPPORTED_LANGUAGES[@]}"; do
    repository="${REPO_PREFIX}-${lang}"

    enterDir repositories
    git clone "https://${GH_TOKEN}@github.com/${ORG_NAME}/${repository}.git"

    enterDir $repository
    if [ "$lang" = "go" ]; then
        build_go
    fi
    leaveDir

    leaveDir
    sudo cp -R "gen/${lang}/." "repositories/${repository}"
    publish $repository $VERSION
done
