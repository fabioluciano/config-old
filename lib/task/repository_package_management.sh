#!/usr/bin/env bash

repository_directory='./configuration/repository/'

function check_prerequisites() {
  if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    gksudo
      -D 'Atenção!'
      -m 'Para continuar a execução do aplicação é necessário instalar o programa jq, disponível nos repositórios oficiais do ubuntu. Para prosseguir, digite a seja do usuário corrente e confirme!'
      'apt install -yqq jq'
  fi

  render_repositories
}

function render_repositories() {
  repositories=`ls -A1 $repository_directory*.json`;

  for repository in $repositories; do
    repo_json_content=$(cat $repository)

    if [ "$(echo $repo_json_content | jq '.enabled')" == "true" ]; then
      repo_name=$(echo $repo_json_content | jq -r '.ppa')
      repo_desc=$(echo $repo_json_content | jq -r '.description')

      checklist_options=("${checklist_options[@]}" "$repo_name" "$repo_desc" ON )
    fi
  done

  selected_repositories=$(dialog \
    --title "Gerenciador de repositórios e pacotes" \
    --clear \
    --stdout \
    --checklist "Selecione os repositórios que devem ser ativados" 14 100 10 \
    "${checklist_options[@]}")

  clear;
  show_packages $selected_repositories
}

function show_packages() {
  repositories=("$@")

  dialog \
    --title "Gerenciador de repositórios e pacotes" \
    --clear \
    --stdout \
    --textbox /dev/stdin 14 100 \
    --and-widget \
    --yesno '\nVocê aceita os Termos da Licença?' 8 30 <<< "$(ls -l)"

  for repository in "${repositories[@]}"; do
    filename='./configuration/repository/'$(echo $repository | sed 's/\//@/g')'.json'
    repo_content=$(cat $filename)
    packages=$(echo $repo_content | jq -r '.packages[]')

    for package in $packages; do
      echo $package
    done
  done
}

function init() {
  check_prerequisites;
}

init
