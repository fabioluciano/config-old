#!/usr/bin/env bash

function import_external_key_with_url() {
  key_objects=($@)

  for key in "${key_objects[@]}"; do
    key_type=$(echo $key | jq -rc '.type')
    key_content=$(echo $key| jq -rc '.key')

    if [ "$key_type" == "url" ]; then
      echo 'curl -fsSL '$key_content' | sudo apt-key add -'
    elif [ "$key_type" == "string" ]; then
      echo $key_type
    else
      echo 'Tipo de chave desconhecida!'
    fi

  done
}

function create_repository_list_file() {
  name=$(echo $@ | jq -rc '.name')
  repository=$(echo $@ | jq -rc '.repository')
  repo_distrib=$(echo $@ | jq -rc '.distribution')
  component=$(echo $@ | jq -rc '.component')

  if [ "$repo_distrib" == "null" ]; then
    repo_distrib=$distribution
  fi

  if [ "$component" == "null" ]; then
    component='main'
  fi

  repository_string="deb "
  repository_string="$repository_string [arch=$architecture_repository] "
  repository_string="$repository_string $repository "
  repository_string="$repository_string $repo "
  repository_string="$repository_string $repo_distrib "
  repository_string="$repository_string $component "

  echo $repository_string

  echo ${name/ /-} | tr '[:upper:]' '[:lower:]'
  # echo "${external_repository[$chave]}" >> /etc/apt/sources.list.d/$chave.list

}

function add_repository() {
  repository_keys=($(echo $@ | jq -rc '. | .keys[]'))
  import_external_key_with_url ${repository_keys[@]};
  create_repository_list_file $@
}
