#!/usr/bin/env bash

function import_external_key_with_url() {
  key_objects=($@)

  for key in "${key_objects[@]}"; do
    key_type=$(echo $key | jq -rc '.type')
    key_content=$(echo $key| jq -rc '.key')

    if [ "$key_type" == "url" ]; then
       curl -fsSL $key_content | sudo apt-key add -
    elif [ "$key_type" == "hash" ]; then
      keyserver=$(echo $key| jq -rc '.keyserver')

      if [ "$keyserver" == "null" ]; then
        keyserver='keyserver.ubuntu.com'
      fi

      apt-key adv --keyserver $keyserver --recv-keys $key_content

    else
      echo 'Tipo de chave desconhecida!'
    fi
  done

}

function create_repository_list_file() {
  name=$(echo $@ | jq -rc '.name')
  name_stripped=$(echo $name | sed 's/\s/\-/g' | tr '[:upper:]' '[:lower:]')
  repository=$(echo $@ | jq -rc '.repository')
  repo_distrib=$(echo $@ | jq -rc '.distribution')
  component=$(echo $@ | jq -rc '.component')

  if [ "$repo_distrib" == "null" ]; then
    repo_distrib=$distribution
  fi

  if [ "$component" == "null" ]; then
    component='main'
  fi

  repository_string="deb [arch=$architecture_repository] $repository $repo_distrib $component"
  echo $repository_string > '/etc/apt/sources.list.d/configtool-'$name_stripped'.list'

}

function add_repository() {
  repository_keys=($(echo $@ | jq -rc '. | .keys[]'))

  # Há chaves a serem importadas?
  if [ ${#repository_keys[@]} -gt 0 ]; then
    import_external_key_with_url ${repository_keys[@]};
  fi

  create_repository_list_file $@
}
