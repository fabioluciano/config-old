#!/usr/bin/env bash

configuration_directory='./lib/task/configuration/'

function check_prerequisites() {
  if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    gksudo \
      -D 'Atenção!' \
      -m 'Para continuar a execução do aplicação é necessário instalar o programa jq, disponível nos repositórios oficiais do ubuntu. Para prosseguir, digite a seja do usuário corrente e confirme!' \
      'apt install -yqq jq apt-transport-https curl'
  fi

  render_configuration_options;
}

function render_configuration_options() {
  configuration_options=`ls -A1 $configuration_directory*.sh`;

  for option in $configuration_options; do
    name=$(basename $option | sed 's/\.sh//g')
    description=$(basename $option)

    checklist_options=("${checklist_options[@]}" "$name" "$description" ON )
  done

  selected_configurations=$(dialog \
    --backtitle "Gerenciador pós-instalação do Xubuntu" \
    --title "Gerenciador de configurações" \
    --clear \
    --stdout \
    --checklist "Selecione as configurações que devem ser aplicadas" 25 100 10 \
    "${checklist_options[@]}")

  execute_configurations $selected_configurations;
}

function execute_configurations() {
  configurations=("$@")

  for configuration in "${configurations[@]}"; do
    source $configuration_directory$configuration'.sh'

    init_configuration;
  done
}



function init() {
  check_prerequisites;
}
