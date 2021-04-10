#!/bin/bash
set -o errexit
set -o nounset

echo "Building ."
source $HOME/.cargo/env
cargo build --target=x86_64-pc-windows-gnu --release

echo "Packaging release executables..."
rm -rf package
mkdir -p package
cp target/x86_64-pc-windows-gnu/release/*.exe package

echo "Copying your executables required DLLs..."
export DLLS="$(/usr/bin/peldd package/*.exe -t --ignore-errors)"
for DLL in $DLLS
    do cp --force "$DLL" package
done

mingw-strip package/*.dll
mingw-strip package/*.exe
