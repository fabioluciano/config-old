#!/usr/bin/env bash

repository_directory='./configuration/repository/'
packages=""

function check_prerequisites() {
  if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    gksudo \
      -D 'Atenção!' \
      -m 'Para continuar a execução do aplicação é necessário instalar o programa jq, disponível nos repositórios oficiais do ubuntu. Para prosseguir, digite a seja do usuário corrente e confirme!' \
      'apt install -yqq jq'
  fi

  render_repositories
}

function render_repositories() {
  repositories=`ls -A1 $repository_directory*.json`;

  for repository in $repositories; do
    repo_json_content=$(cat $repository)

    if [ "$(echo $repo_json_content | jq '.enabled')" == "true" ]; then
      repo_name=$(basename $repository | sed 's/\.json//g')
      repo_desc=$(echo $repo_json_content | jq -r '.description')

      checklist_options=("${checklist_options[@]}" "$repo_name" "$repo_desc" ON )
    fi
  done

  selected_repositories=$(dialog \
    --backtitle "Gerenciador pós-instalação do Xubuntu" \
    --title "Gerenciador de repositórios e pacotes" \
    --clear \
    --stdout \
    --checklist "Selecione os repositórios que devem ser ativados" 14 100 10 \
    "${checklist_options[@]}")

  install_repository $selected_repositories
}

function install_repository() {
  repositories=("$@")

  for repository in "${repositories[@]}"; do
    repository_configuration=$( cat './configuration/repository/'$repository'.json')
    repository_type=$(echo $repository_configuration | jq -r '.type')

    if [ "$repository_type" == "ppa" ]; then
      source ./lib/task/install/ppa.sh
    elif [ "$repository_type" == "external" ]; then
      source ./lib/task/install/external.sh
    elif [ "$repository_type" == "internal" ]; then
      source ./lib/task/install/internal.sh
    elif [ "$repository_type" == "standalone" ]; then
      source ./lib/task/install/standalone.sh
    else
      echo 'Tipo de repositório desconhecido! Arquivo: '$repository
    fi

    add_repository $repository_configuration
  done

  sudo apt update --fix-missing
}

function install_package() {
  echo $1
  # repo_content=$(cat $filename)
  # packages=$(echo $repo_content | jq -r '.packages[]')
}

function init() {
  check_prerequisites;
}
