#!/bin/bash

die() {
    echo "Test failed"
    exit 1
}

TMPDIR="$(mktemp -d)"
trap "rm -rf \"$TMPDIR\"" EXIT

pushd "$TMPDIR" >> /dev/null

mkdir REPO

pushd REPO >> /dev/null
git init
mkdir -p d0/d1
echo 'hello' > a.txt
echo 'git' > d0/b.txt
echo 'lock' > d0/d1/b.txt
echo '!' > d0/d1/c.txt
git add .
git commit -m "Initial commit"
popd >> /dev/null

git clone REPO LOCAL0
git clone REPO LOCAL1

pushd LOCAL0 >> /dev/null
git config user.name "Local 0"
git config user.email "local0@git.lock"
if ! git lock acquire a.txt; then die; fi
if ! git lock acquire d0/d1/b.txt; then die; fi
if ! git lock acquire d0/d1/c.txt; then die; fi
popd >> /dev/null

pushd LOCAL1 >> /dev/null
git config user.name "Local 1"
git config user.email "local1@git.lock"
if git lock acquire d0/d1/b.txt; then die; fi
if ! git lock acquire d0/b.txt; then die; fi
popd >> /dev/null

pushd LOCAL0 >> /dev/null
if ! git lock release d0/d1/b.txt; then die; fi
popd >> /dev/null

pushd LOCAL1 >> /dev/null
if ! git lock acquire d0/d1/b.txt; then die; fi
popd >> /dev/null

popd >> /dev/null

echo "Tests succeeded"
