#!/usr/bin/env bash

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
  [[ $EUID != 0 ]] && exec gksudo "$0" $*
  main $*
fi
