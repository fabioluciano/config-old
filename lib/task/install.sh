#!/usr/bin/env bash

repository_directory='./configuration/repository/'
packages=""

function check_prerequisites() {
  if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    gksudo \
      -D 'Atenção!' \
      -m 'Para continuar a execução do aplicação é necessário instalar o programa jq, disponível nos repositórios oficiais do ubuntu. Para prosseguir, digite a seja do usuário corrente e confirme!' \
      'apt install -yqq jq apt-transport-https curl'
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
    --checklist "Selecione os repositórios que devem ser ativados" 25 100 20 \
    "${checklist_options[@]}")

  install_repository $selected_repositories
}

function install_repository() {
  repositories=("$@")

  for repository in "${repositories[@]}"; do
    repository_configuration=$(cat './configuration/repository/'$repository'.json' | jq -rc '.')
    repository_type=$(echo $repository_configuration | jq -r '.type')


    if [ "$repository_type" == "ppa" ]; then
      source ./lib/task/install/ppa.sh
    elif [ "$repository_type" == "external" ]; then
      source ./lib/task/install/external.sh
    elif [ "$repository_type" == "standalone" ]; then
      source ./lib/task/install/standalone.sh
    elif [ "$repository_type" == "internal" ]; then
      source ./lib/task/install/internal.sh
    fi

    #add_repository $repository_configuration
    collect_packages $repository_configuration
  done

  apt update --fix-missing
  install_package_collection $packages
}

function install_package_collection() {
  apt install -y $packages
}

function collect_packages() {
  packages_collection=($(echo $@ | jq -rc '. | .packages[]?'))

  for package in "${packages_collection[@]}"; do
    packages="$packages $package"
  done
}

function init() {
  check_prerequisites;
}
