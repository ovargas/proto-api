#!/usr/bin/env bash

printf '\e[1;36m%s\e[0m\n' "Getting all files and merging..."

INPUT=./gen/docs/openapi.json

# shellcheck disable=SC2046
./bin/swagger mixin ./akorda/openapi/akorda.json \
  $(find ./gen/swagger/akorda -type f -name "*.swagger.json" | sort) -o $INPUT

# there is no way to remove the default 200 responses so we remove them manually
jq del\('.paths[].post.responses."200"'\) >openapi.tmp <$INPUT && mv openapi.tmp $INPUT
jq del\('.paths[].post.responses."default"'\) >openapi.tmp <$INPUT && mv openapi.tmp $INPUT
