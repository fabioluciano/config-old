#!/bin/bash

declare -A ppa ppa_xfce ppa_keys external_repository_keys external_repository packages packages_purge

#Get the [u|x|k|l]buntu distro id
distro_version=`lsb_release -is`
usuario="fabioluciano"
command="$1"

ppa=(
    ["vala"]="vala-team/ppa" #vala
    ["gimp"]="otto-kesselgulasch/gimp" #gimp
    ["shutter"]="shutter/ppa" #shutter
    ["libreoffice"]="libreoffice/libreoffice-4-4" #libreoffice
    ["sublime-text"]="webupd8team/sublime-text-3" #sublime-text
    ["tlp"]="linrunner/tlp" #tpl notebook battery
    ["vlc"]="videolan/stable-daily" #vlc
    ["faenza"]="noobslab/icons" #icons-and-apps
    ["synapse"]="synapse-core/testing" #synapse
    ["xfceextras"]="xubuntu-dev/extras" #extra packages for xfce
    ["java"]="webupd8team/java" #java8 installer
    ["synapse"]="synapse-core/testing" #synapse
    ["plank"]="ricotz/docky" #docky
    ["whisker"]="gottcode/gcppa" #whisker menu
    ["apps"]="noobslab/apps" #applications
    ["ssr"]="maarten-baert/simplescreenrecorder" #simplescreenrecorder
    ["atareao"]="atareao/atareao" #indicators
    ["webupd8"]="nilarimogard/webupd8" #applications
    ["qbt"]="qbittorrent-team/qbittorrent-stable" #qbt
)

external_repository_keys=(
    ["google-chrome"]="https://dl-ssl.google.com/linux/linux_signing_key.pub" #google-chrome
    ["virtualbox"]="http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc" #virtualbox
    ["opera"]="http://deb.opera.com/archive.key" #opera
)

external_repository=(
    ["google-chrome"]="deb http://dl.google.com/linux/chrome/deb/ stable main"
    ["virtualbox"]="deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
    ["opera"]="deb http://deb.opera.com/opera/ stable non-free"
    ["canonical-partner"]="deb http://archive.canonical.com/ubuntu/ utopic partner"
)

packages=(
    ["network-tools"]="openssh-server wireshark curl"
    ["sysadmin-tools"]=" htop  filezilla virtualbox-4.3 "
    ["performance-tools"]="preload"
    ["development-tools"]="valac sublime-text-installer git subversion apache2"
    ["php"]="php5 libapache2-mod-php5 php5-dev php5-gd php5-geoip php5-mcrypt php5-memcache php5-memcached php5-pgsql php5-xdebug php5-curl php5-mongo php5-mysql php5-imagick php5-cli php-pear"
    ["databases"]="mysql-server mysql-client mysql-workbench postgresql pgadmin3"
    ["graphic-tools"]="gimp dia blender inkscape shutter"
    ["tweaks"]="telegram-purple qbittorrent pcmanfm plank thunar-dropbox-plugin guake oracle-java9-installer oracle-java9-set-default synapse ncurses-term lm-sensors hddtemp tlp tlp-rdw tp-smapi-dkms smartmontools ethtool skype"
    ["browsers"]="opera google-chrome-stable"
    ["visual-related"]="faenza-icon-theme compiz compizconfig-settings-manager compiz-core compiz-plugins compiz-plugins-default compiz-plugins-extra compiz-plugins-main compiz-plugins-main-default"
    ["codecs"]="gstreamer0.10-plugins-ugly libdvdread4 icedax tagtool easytag id3tool lame libmad0 mpg321 faac faad ffmpeg2theora flac icedax id3v2 lame libflac++6 libjpeg-progs mjpegtools mpeg2dec mpeg3-utils mpegdemux mpg123 mpg321 regionset sox uudeview vorbis-tools x264"
    ["multimedia-related"]="flashplugin-installer font-manager vlc audacious ubuntu-restricted-extras clementine camorama simplescreenrecorder"
    ["archiver"]="arj p7zip p7zip-full p7zip-rar unrar unace-nonfree p7zip-rar p7zip-full unace unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller"
    ["editors"]="vim libreoffice libreoffice-l10n-pt-br libreoffice-style-sifr"
    ["indicators"]="pidgin-indicator youtube-indicator touchpad-indicator pomodoro-indicator calendar-indicator"
    )

packages_purge=(
    ["xfce-apps"]="orage onboard abiword gnumeric gnumeric-common gnumeric-doc simple-scan gnome-games-data gmusicbrowser aisleriot parole gnome-mines gnome-sudoku transmission transmission-gtk"
)

# Lista de daemons para não serem executados no startup
daemons=( apache2 nginx mysql postgresql mongodb )

function init() {
    case $command in
        addppa)
            echo -e "\nAdicionando PPAs";
            add_ppas;
            add_external_keys;
        ;;
        *)
            show_menu;
            exit 1;
    esac
}

function add_ppas() {
    for repos in "${ppa[@]}"; do
        echo -e " \033[32m-\033[0m ppa\t\033[32m$repos\033[0m";
        add-apt-repository ppa:$repos -y
    done

    apt-get update --fix-missing
}

function add_external_keys() {
    echo -e "\nAdicionando Repositórios externos";

    for chave in ${!external_repository[@]}; do
        echo -e " \033[32m-\033[0m key\t\033[32m$chave\033[0m";

        if [ -n "${external_repository_keys[$chave]}" ]; then
            wget -q -O - ${external_repository_keys[$chave]} | apt-key add -
        fi

        if [ ! -s "/etc/apt/sources.list.d/$chave.list" ]; then
            echo "${external_repository[$chave]}" >> /etc/apt/sources.list.d/$chave.list
        fi
    done
}

function add_packages() {
    echo -e "\nAdicionando pacotes";

    for pkg in "${packages[@]}"; do
        echo -e " \033[32m-\033[0m pkgs\t\033[32m$pkg\033[0m";
        apt-get install $pkg --allow-unauthenticated --force-yes -y
    done
}

function purge_packages() {
    for pkg in "${packages_purge[@]}"; do
        apt-get remove -y $pkg --force-yes -y
    done

    apt-get autoremove --force-yes -y --purge
}

function do_fixes() {

    # Corrige o dono do arquivo de histórico do bash
    chown $usuario:$usuario ~/.bash_history

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


    curl -kL https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh | bash

    remove_daemons
}

function remove_daemons() {
    for daemon in "${daemons[@]}"; do
        update-rc.d -f $daemon remove
    done
}

function create_directory_structure() {
    # Cuidado com essa opção ela apagará qualquer eventual arquivo dentro de seu home.
    # Em meu desktop funciona perfeitamente, por que como pode ver, uso links simbólicos

    ln -s /mnt/doc/document /home/$usuario/Documentos
    ln -s /mnt/doc/download /home/$usuario/Downloads
    ln -s /mnt/doc/image /home/$usuario/Imagens
    ln -s /mnt/doc/music /home/$usuario/Música
    ln -s /mnt/doc/photo /home/$usuario/Fotos
    ln -s /mnt/doc/study /home/$usuario/Estudos
}

function install_composer() {
	echo 'no no no';
}

function show_menu(){
    option=$( dialog --stdout --title 'Adição de repositórios e atualização do sistema.' --menu 'Selecione uma opção.' 0 0 0 \
        1 'Adicionar repositórios' \
        2 'Instalar pacotes' \
        3 'Executar ajustes' \
        4 'Criar estrutura de diretórios' \
        5 'Criar estrutura PHP' \
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
            install_composer;
        ;;
    esac
}


if [ `id -u` -eq 0 ]; then
    init
else
    echo "Voce deve executar este script como root!"
fi