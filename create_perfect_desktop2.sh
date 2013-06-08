#!/bin/bash

declare -A ppa ppa_xfce ppa_keys external_repository_keys external_repository packages packages_purge

#Get the [u|x|k|l]buntu distro id
distro_version=`lsb_release -is`
usuario="fabioluciano"
command="$1"

ppa=(
    ["tweak"]="tualatrix/ppa" #ubuntu-tweak
    ["nodejs"]="chris-lea/node.js" #nodejs
    ["vala"]="vala-team" #vala
    #["gmailwatcher"]="loneowais/gmailwatcher.dev" #gmailwhatcher nor raring
    ["gimp"]="otto-kesselgulasch/gimp" #gimp
    ["shutter"]="shutter/ppa" #shutter
    ["libreoffice"]="libreoffice/ppa" #libreoffice
    ["faenza-icon-theme"]="tiheum/equinox" #faenza-icon-theme
    ["nginx"]="nginx/stable" #nginx
    ["sublime-text"]="webupd8team/sublime-text-2" #sublime-text
    ["puddletag"]="webupd8team/puddletag" #puddletag
    ["yad"]="webupd8team/y-ppa-manager" #yad
    ["cuckoo"]="john.vrbanac/cuckoo" #marlin
    #["polly"]="conscioususer/polly-unstable" #polly
    ["aptfastk"]="apt-fast/stable" #apt-fast
    ["terra-terminal"]="ozcanesen/terra-terminal" #terra
    ["mtpfs"]="langdalepl/gvfs-mtp" #android
    ["tlp"]="linrunner/tlp" #tpl notebook battery
    ["xorg-edgers"]="xorg-edgers/ppa" #fglrx
    #["zram"]="shnatsel/zram" #replace swap not raring
    ["xnoise"]="shkn/xnoise"
    ["faience-theme"]="tiheum/equinox"
)

ppa_xfce=(
    ["xfce10"]="xubuntu-dev/xfce-4.10"
    ["xfce12"]="xubuntu-dev/xfce-4.12"
#    ["fglrx"]="andrikos/ppa"
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
    ["mediubuntu"]="deb http://packages.medibuntu.org/ $(lsb_release -cs) free non-free"
)

packages=(
    ["sysadmin-tools"]="openssh-server htop wireshark filezilla virtualbox-4.2 curl"
    ["productivity"]="cuckoo"
    ["performance-tools"]="preload"
    ["development-tools"]="nodejs valac-0.16 sublime-text mysql-workbench yad nginx git subversion apache2"
    ["php"]="php5 libapache2-mod-php5 php5-dev php5-gd php5-geoip php5-mcrypt php5-memcache php5-memcached php5-pgsql php5-xdebug php5-curl php5-mongo php5-mysql php5-imagick php5-cli php-pear"
    ["databases"]="mysql-server mysql-client postgresql pgadmin3"
    ["graphic-tools"]="gimp dia blender inkscape shutter"
    ["tweaks"]="ncurses-term ubuntu-tweak numlockx lm-sensors screenlets hddtemp terra tlp tlp-rdw tp-smapi-dkms smartmontools ethtool"
    ["browsers"]="opera google-chrome-stable"
    ["visual-related"]="faenza-icon-theme compiz compizconfig-settings-manager compiz-core compiz-plugins compiz-plugins-default compiz-plugins-extra compiz-plugins-main compiz-plugins-main-default faience-theme faience-icon-theme"
    ["codecs"]="non-free-codecs libdvdcss2 faac faad ffmpeg ffmpeg2theora flac icedax id3v2 lame libflac++6 libjpeg-progs libmpeg3-1 mencoder mjpegtools mp3gain mpeg2dec mpeg3-utils mpegdemux mpg123 mpg321 regionset sox uudeview vorbis-tools x264"
    ["multimedia-related"]="flashplugin-installer vlc medibuntu-keyring audacious puddletag xnoise"
    ["archiver"]="arj p7zip p7zip-full p7zip-rar unrar unace-nonfree"
    ["editors"]="vim libreoffice libreoffice-l10n-pt-br"
    ["internet-tools"]="qbittorrent"
    ["amd_make_tools"]="cdbs fakeroot build-essential dh-make debconf debhelper dkms libqtgui4 libstdc++6 libelfg0 execstack dh-modaliases lib32gcc1 libc6-i386"
)

packages_purge=(
    ["apport"]="apport apport-symptoms"
    ["xfce-apps"]="orage onboard abiword gnumeric gnumeric-common gnumeric-doc simple-scan transmission-gtk transmission-common gnome-games-data gmusicbrowser aisleriot parole"
)

# ppa_unity=(
# )

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

    if [ $distro_version == "Ubuntu" ]; then
        echo -e "\nAdicionando ppas \033[32m$distro_version\033[0m";

        for repos in "${ppa_xfce[@]}"; do
            echo -e " \033[32m-\033[0m ppa\t\033[32m$repos\033[0m";
            add-apt-repository ppa:$repos -y
        done
    fi
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
    #sudo apt-get update --fix-missing --fix-broken
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
    # Por algum motivo o bash_history fica com o root como dono
    chown $usuario:$usuario ~/.bash_history

    # Depois de adicionado o pacote, ativar o teclado numérico
    numlockx on

    # Necessário adicionar o usuario ao grupo vboxusers para que dispositivos por usb funcionem na vms
    addgroup $usuario vboxusers

    # Apos instalar o ncurses, ativa mais cores no terminal
    echo "export TERM=xterm-256color" >>  ~/.bashrc

    echo "options snd-hda-intel model=ref" >> /etc/modprobe.d/alsa-base.conf

    gsettings set org.gnome.desktop.wm.preferences theme Greybird
    gsettings set org.gnome.desktop.interface buttons-have-icons true

    # detecta os sensores de temperatura
    sensors-detect
}



function create_directory_structure() {
    # Cuidado com essa opção ela apagará qualquer eventual arquivo dentro de seu home.
    # Em meu desktop funciona perfeitamente, por que como pode ver, uso links simbólicos
    rm -rf /home/$usuario/*

    ln -s /mnt/doc/distros /home/$usuario/Distros
    ln -s /mnt/doc/document /home/$usuario/Documentos
    ln -s /mnt/doc/download /home/$usuario/Downloads
    ln -s /mnt/doc/image /home/$usuario/Imagens
    ln -s /mnt/doc/music /home/$usuario/Música
    ln -s /mnt/doc/photo /home/$usuario/Fotos
    ln -s /mnt/doc/study /home/$usuario/Estudos
}

function show_menu(){
    option=$( dialog --stdout --title 'Adição de repositórios e atualização do sistema.' --menu 'Selecione uma opção.' 0 0 0 \
        1 'Adicionar repositórios' \
        2 'Instalar pacotes' \
        3 'Executar ajustes' \
        4 'Criar estrutura de diretórios' \
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
    esac
}


if [ `id -u` -eq 0 ]; then
    init
else
    echo "Voce deve executar este script como root!"
fi