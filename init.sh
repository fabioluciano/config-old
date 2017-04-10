#!/usr/bin/env bash

source ./lib/application.sh

# Chaca se o pacote dialog está instalado, senão o instala
if [ $(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  sudo apt install -yqq dialog gksu
fi

source ./lib/warning.sh
