#!/usr/bin/env bash

function render_application_menu() {
  selected_option=$( dialog \
    --backtitle "Gerenciador pós-instalação do Xubuntu" \
    --stdout \
    --title 'Adição de repositórios e atualização do sistema.' \
    --menu 'Selecione uma opção.' 0 100 0 \
    software 'Gerenciar repositórios e pacotes' \
    configure 'Configurar sistema e aplicativos' \
    clean 'Limpar sistema'
  )

  case $selected_option in
    software)
      source ./lib/task/install.sh
    ;;
    configure)
      source ./lib/task/configure.sh
    ;;
    clean)
      source ./lib/task/configure.sh
    ;;
  esac

  init;
}
