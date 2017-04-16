#!/usr/bin/env bash

function add_repository() {
  regex=$(echo $@ | jq -r '.regex')
  repository=$(echo $@ | jq -r '.repository')
  url=$(curl -sS http://astah.net/download | grep -oP  '<p class="linux prorpm.*?href="\K(?<link>.*?.deb)"' | sed 's/"//g' | head -1)
  package=$(basename $url)

  if curl --output /dev/null --silent --head --fail "$url"; then
    curl -O $url
    dpkg -i $package
    apt install -f
  fi
}
