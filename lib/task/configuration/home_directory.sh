#!/usr/bin/env bash

function init_configuration() {
  echo 'Creating home symbolic links'

  execute_configuration;
}

function execute_configuration() {
  doc_root_directory=$(echo $application_config | jq -rc '.docs_mount')
  directories=( $(echo $application_config | jq -rc '. | .docs_folders[]?') )


  for directory_name in "${directories[@]}"; do
    compound_directory=$doc_root_directory$directory_name

    if [ -d "$compound_directory" ]; then
      echo ''
    else
      echo 'O diretório '$compound_directory' não existe! Vou criar e atribuí-lo ao usuário'
      mkdir $compound_directory
    fi
    chown $current_user:$current_user -R $compound_directory


    if [ -e /home/$current_user/$directory_name ]; then
      rm -r /home/$current_user/$directory_name
    fi

    ln -s $compound_directory /home/$current_user/
  done
}
