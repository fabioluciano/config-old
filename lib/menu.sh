#!/usr/bin/env bash

function render_application_menu() {
  selected_option=$( dialog \
    --stdout \
    --clear \
    --title 'Adição de repositórios e atualização do sistema.' \
    --menu 'Selecione uma opção.' 0 100 0 \
    1 'Gerenciar repositórios e pacotes'
  )

  case $selected_option in
    1)
      source ./lib/task/repository_package_management.sh
    ;;
  esac

  init;
}
