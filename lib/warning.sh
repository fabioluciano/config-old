#!/usr/bin/env bash

dialog \
  --backtitle "Gerenciador pós-instalação do Xubuntu" \
  --title 'Aviso' \
  --clear \
  --yesno 'O programa que você acabou de iniciar possui diversas funcionalidades que ao autor são interessantes, mas isso não quer dizer que elas serão adequadas a você.\nEm todos os casos em que operações perigosas foram executadas, será solicitada sua confirmação.\n\nAs ações aqui tomadas foram otimizadas para utilização em conjunto com o sistema operacional Linux, utilizando o Xubuntu como distribuição e o XFCE como Desktop Environment\n\nCaso você tenha passado a opção --skip, você não será notificado para confirmações!\n\nDeseja continuar?' \
   14 100

if [ $? = 0 ]; then
  source ./lib/menu.sh
  render_application_menu
else
  echo 'Até a próxima!'
fi
