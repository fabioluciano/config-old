#!/bin/bash

declare -A ppa ppa_xfce ppa_keys external_repository_keys external_repository packages packages_purge

usuario=$SUDO_USER
diretorio=$(dirname $0)
command="$1"


packages=(
  ["archiver"]="arj p7zip p7zip-full p7zip-rar unrar unace-nonfree p7zip-rar p7zip-full unace unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller"
)

# Pacotes a serem removidos
packages_purge=(
  ["xfce-apps"]="orage onboard abiword gnumeric gnumeric-common gnumeric-doc simple-scan gnome-games-data gmusicbrowser aisleriot parole gnome-mines gnome-sudoku transmission transmission-gtk"
)

startup_apps=( guake plank )

# Lista de daemons para não serem executados no startup
daemons=( apache2 nginx mysql postgresql mongodb minidlna php7.0-fpm )

function purge_packages() {
  for pkg in "${packages_purge[@]}"; do
    apt remove -y $pkg -y
  done

  apt autoremove -y --purge
}

function do_fixes() {
  # Corrige o dono do arquivo de histórico do bash
  chown $SUDO_USER.$SUDO_USER ~/.bash_history

  # Adiciona o usuário ao grupo do virtualbox, possibilitando a utilização de periféricos por USB
  addgroup $usuario vboxusers

  # Apos instalar o ncurses, ativa mais cores no terminal
  echo "export TERM=xterm-256color" >>  ~/.bashrc

  xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -t string -s compiz -s ccp

  gsettings set org.gnome.desktop.wm.preferences theme Greybird
  gsettings set org.gnome.desktop.interface buttons-have-icons true
  gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font false
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Bold 9'
  gconftool-2 --set --type string /desktop/gnome/interface/gtk_theme greybird
  gconftool-2 --set --type string /desktop/gnome/interface/icon_theme Faenza-Dar

  # detecta os sensores de temperatura
  sensors-detect

  echo allow-guest=false | sudo tee -a /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
  #curl -kL https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh | bash

  remove_daemons
}

function remove_daemons() {
  for daemon in "${daemons[@]}"; do
    update-rc.d -f $daemon remove
  done
}

function add_to_startup() {
  for application in "${startup_apps[@]}"; do
    echo "[Desktop Entry]
  Encoding=UTF-8
  Version=0.9.4
  Type=Application
  Name=$application
  Comment=
  Exec=$(which $application)
  OnlyShowIn=XFCE;
  StartupNotify=false
  Terminal=false
  Hidden=false" > ~/.config/autostart/$application.desktop
  done
}

function create_directory_structure() {
  # Cuidado com essa opção ela apagará qualquer eventual arquivo dentro de seu home.
  # Em meu desktop funciona perfeitamente, por que como pode ver, uso links simbólicos

  ln -s /mnt/doc/document /home/$usuario/Documentos
  ln -s /mnt/doc/download /home/$usuario/Downloads
  ln -s /mnt/doc/image /home/$usuario/Imagens
  ln -s /mnt/doc/photo /home/$usuario/Fotos
  ln -s /mnt/doc/study /home/$usuario/Estudos
}

function development() {
  #PHP
  if [ ! -d /home/$usuario/.composer ]; then
      mkdir /home/$usuario/.composer
  fi


  echo '{
    "require": {
      "halleck45/phpmetrics": "@dev",
      "squizlabs/php_codesniffer": "*",
      "phpunit/phpunit": "*",
      "sebastian/phpcpd": "*",
      "sebastian/phpdcd": "*",
      "phpmd/phpmd" : "@stable",
      "pdepend/pdepend" : "@stable",
      "phploc/phploc": "*",
      "sebastian/hhvm-wrapper": "*",
      "theseer/phpdox": "*",
      "producer/producer": "@stable"
    }
  }' > /home/$usuario/.composer/composer.json

  curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
  chown -R $SUDO_USER.$SUDO_USER ~/.composer
  $(whereis composer | awk '{print $2}') global install

  #Node
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
  chown -R $SUDO_USER.$SUDO_USER ~/.nvm
}

function configure_ides() {
  # Sublime Text 3
  cp $diretorio/configs/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/
  cp $diretorio/configs/Package\ Control.sublime-settings ~/.config/sublime-text-3/Packages/User/
  chown -R $SUDO_USER.$SUDO_USER ~/.config/sublime-text-3/Packages/User/

  #Git
  cp $diretorio/configs/gitconfig /etc/
}

function show_menu(){
  option=$( dialog --stdout --title 'Adição de repositórios e atualização do sistema.' --menu 'Selecione uma opção.' 0 0 0 \
    1 'Adicionar repositórios' \
    2 'Instalar pacotes' \
    3 'Executar ajustes' \
    4 'Criar estrutura de diretórios' \
    5 'Criar estrutura de Desenvolvimento' \
    6 'Configurar aplicativos' \
  )

  case $option in
    1)
    add_ppas;
    add_external_keys;
    ;;
    2)
    add_packages;
    purge_packages;
    ;;
    3)
    do_fixes;
    ;;
    4)
    create_directory_structure;
    ;;
    5)
    development;
    ;;
    6)
    configure_ides;
    add_to_startup;
    ;;
  esac
}


if [ `id -u` -eq 0 ]; then
  init
else
  echo "Voce deve executar este script como root!"
fi
