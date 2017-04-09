#!/usr/bin/env bash

function render_application_menu() {
  selected_option=$( dialog \
    --stdout \
    $default_dialog_options \
    --title 'Adição de repositórios e atualização do sistema.' \
    --menu 'Selecione uma opção.' 0 100 0 \
    1 'Gerenciar repositórios e pacotes'
  )

  case $selected_option in
    1)
      source ./lib/task/install.sh
    ;;
  esac

  init;
}
