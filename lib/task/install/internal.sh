#!/usr/bin/env bash

function add_repository() {
  repository=$(echo $@ | jq -r '.repository')
  # echo $repository
}
