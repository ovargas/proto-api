#!/usr/bin/env bash

ARCH=$(uname -m)
OS=""
PLATFORM=$(uname -s)
PB_VERSION="v3.18.1"

WORK_DIR=$(mktemp -d)
# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

if [ "$PLATFORM" == "Darwin" ]; then
  OS="osx"

  if [ "$(command -v brew)" != "" ]; then
    brew install protobuf
    exit 0
  fi

elif [ "$PLATFORM" == "Linux" ]; then
  OS="linux"
else
  printf '\e[1;36m%s\e[0m\n' "Invalid platform $PLATFORM...bye!"
  exit 1
fi

printf '\e[1;36m%s\e[0m\n' "Installing protoc for $OS-$ARCH"

download_url=$(
  curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases |
    jq -r --arg OS "$OS" --arg ARCH "$ARCH" --arg PB_VERSION "$PB_VERSION" \
      '.[] | select(.tag_name | contains($PB_VERSION)) | .assets[] | select(.name | contains($OS)) |
  select(.name | contains($ARCH)) |  .browser_download_url'
)

curl -o "$WORK_DIR"/protoc.zip -L'#' "$download_url"

unzip "$WORK_DIR"/protoc.zip -d "$WORK_DIR"
mv "$WORK_DIR"/bin/protoc /usr/local/bin/protoc
chmod +x /usr/local/bin/protoc

protoc --version
