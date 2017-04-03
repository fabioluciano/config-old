#!/usr/bin/env bash


function check_prerequisites() {
  if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    gksudo
      -D 'Atenção!'
      -m 'Para continuar a execução do aplicação é necessário instalar o programa jq, disponível nos repositórios oficiais do ubuntu. Para prosseguir, digite a seja do usuário corrente e confirme!'
      'apt install -yqq jq'
  fi
}

function render_repositories() {
  repositories=`ls -A1 ./configuration/repository/*.json`;

  for repository in $repositories; do
    repo_json_content=$(cat $repository)

    if [ "$(echo $repo_json_content | jq '.enabled')" == "true" ]; then
      repo_name=$(echo $repo_json_content | jq -r '.ppa')
      repo_desc=$(echo $repo_json_content | jq -r '.description')

      checklist_options=("${checklist_options[@]}" "$repo_name" "$repo_desc" ON )
    fi
  done

  selected_repositories=$(dialog \
    --title "Config Modules State" \
    --stdout \
    --checklist "Choose modules to activate" 14 100 10 \
    "${checklist_options[@]}")
}

function init() {
  check_prerequisites;
  render_repositories
}

init
