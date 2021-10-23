#!/usr/bin/env bash

printf '\e[1;36m%s\e[0m\n' "Installing swagger cli..."
mkdir ./bin
download_url=$(
  curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest |
    jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' \
      '[:lower:]')"'_amd64")) | .browser_download_url'
)

curl -o ./bin/swagger -L'#' "$download_url"
chmod +x ./bin/swagger