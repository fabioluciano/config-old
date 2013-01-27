#!/bin/bash

# #######################################################
# @Author: Fábio Luciano				#
# @Email pessoal: omega.df@gmail.com			#
# @Date: 03/09/2012  16:54:00 PM			#
# @Description: Script criado com o intuito de criar	#
# o perfeito desktop para desenvolvimento		#
# #######################################################

# Usuário a qual ficará responsável por alguns diretórios
usuario='fabioluciano'

# Ativa os arrays associativos. Coloquei todos como associativos... Vai que uma hora eu preciso
declare -A chaves_avulsas repos_ppa repos_avulsos packages_to_install packages_to_purge

# Definição de repositórios utilizando ppas a serem instalados
repos_ppa=(
	["tweak"]				="tualatrix/ppa"
	["nodejs"]				="chris-lea/node.js" #nodejs
	["vala"]				="vala-team" #vala
	["gmailwatcher"]		="loneowais/gmailwatcher.dev" #gmailwhatcher
	["gimp"]				="otto-kesselgulasch/gimp" #gimp
	["shutter"]				="shutter/ppa" #shutter
	["libreoffice"]			="libreoffice/ppa" #libreoffice
	["faenza-icon-theme"]	="tiheum/equinox" #faenza-icon-theme
	["nginx"]				="nginx/stable" #nginx
	["qbittorent"]			="hydr0g3n/ppa" #qbittorent
	["sublime-text"]		="webupd8team/sublime-text-2" #sublime-text
	["puddletag"]			="webupd8team/puddletag" #puddletag
	["yad"]					="webupd8team/y-ppa-manager" #yad
	["beatbox"]				="sgringwe/beatbox"
	["marlin"]				="marlin-devs/marlin-daily" #marlin
	["cuckoo"]				="john.vrbanac/cuckoo" #marlin
	["plank"]				="ricotz/docky" #plank
	["polly"]				="conscioususer/polly-unstable" #polly
	["aptfast"]				="apt-fast/stable"
)

# Repositórios fora do ppa
repos_avulsos=(
	["google-chrome"] ="deb http://dl.google.com/linux/chrome/deb/ stable main"
	["virtualbox"]    ="deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
	["opera"]         ="deb http://deb.opera.com/opera/ stable non-free"
	["mediubuntu"]    ="deb http://packages.medibuntu.org/ $(lsb_release -cs) free non-free"
)

# Chaves dos repositórios avulsos
chaves_avulsas=(
	["google-chrome"] ="https://dl-ssl.google.com/linux/linux_signing_key.pub" #google-chrome
	["virtualbox"]    ="http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc" #virtualbox
	["opera"]         ="http://deb.opera.com/archive.key" #opera
)

# Pacotes adicionais. Alguns estão associados diretamente a alguma ppa
packages_to_install=(
	["sysadmin-tools"]     ="openssh-server htop wireshark filezilla virtualbox-4.2 curl"
	["productivity"]       ="gmailwatcher cuckoo"
	["performance-tools"]  ="preload"
	["development-tools"]  ="nodejs valac-0.16 sublime-text mysql-workbench yad nginx git subversion apache2"
	["php"]                ="php5 libapache2-mod-php5 php5-dev php5-gd php5-geoip php5-mcrypt php5-memcache php5-memcached php5-pgsql php5-xdebug php5-curl php5-mongo php5-mysql php5-imagick php5-cli"
	["databases"]          ="mysql-server mysql-client postgresql pgadmin3"
	["graphic-tools"]      ="gimp dia blender inkscape shutter"
	["tweaks"]             ="ncurses-term ubuntu-tweak numlockx lm-sensors marlin screenlets hddtemp plank"
	["indicators"]         ="indicator-multiload"
	["browsers"]           ="opera google-chrome-stable"
	["visual-related"]     =" faenza-icon-theme compiz compizconfig-settings-manager compiz-core compiz-plugins compiz-plugins-default compiz-plugins-extra compiz-plugins-main compiz-plugins-main-default"
	["codecs"]             ="non-free-codecs libdvdcss2 faac faad ffmpeg ffmpeg2theora flac icedax id3v2 lame libflac++6 libjpeg-progs libmpeg3-1 mencoder mjpegtools mp3gain mpeg2dec mpeg3-utils mpegdemux mpg123 mpg321 regionset sox uudeview vorbis-tools x264"
	["multimedia-related"] ="flashplugin-installer vlc medibuntu-keyring audacious puddletag beatbox"
	["archiver"]           ="arj lha p7zip p7zip-full p7zip-rar unrar unace-nonfree"
	["editors"]            ="vim libreoffice libreoffice-l10n-pt-br"
	["internet-tools"]     ="qbittorrent polly"
	["amd_make_tools"]     ="cdbs fakeroot build-essential dh-make debconf debhelper dkms libqtgui4 libstdc++6 libelfg0 execstack dh-modaliases ia32-libs-multiarch i386 lib32gcc1 ia32-libs libc6-i386 ia32-libs"
)

# Pacotes desnecessários para meu uso
packages_to_purge=(
	["apport"]="apport apport-symptoms"
	["xfce-apps"]="orage onboard abiword gnumeric gnumeric-common gnumeric-doc simple-scan transmission-gtk transmission-common gnome-games-data gmusicbrowser aisleriot parole"
)

# Lista de daemons para não serem executados no startup
daemons_not_start_automatically=( apache2 nginx mysql postgresql mongodb )

add_repo() {
	add_repos_por_ppa #chamando função para adição de repositórios por ppa
	add_repos_avulsos #chamando função para adição de repositórios por repos avulsos
	
	# Atualizar a lista local de pacotes
	apt-fast update --fix-missing --fix-broken
	
	# Faz upgrade dos pacotes obsoletos
	apt-fast dist-upgrade -u -y
}

# Adiciona repositórios provindor por PPA
add_repos_por_ppa() {
	for repos in "${repos_ppa[@]}"; do
	    add-apt-repository ppa:$repos -y
	done
}

add_repos_avulsos() {
	for chave in ${!repos_avulsos[@]}; do

		#Primeiro adicionamos a chave do repositório
		if [ -n "${chaves_avulsas[$chave]}" ]; then
			wget -q -O - ${chaves_avulsas[$chave]} | apt-key add -
		fi

		#Agora criamos configuramos os repositórios
		if [ ! -s "/etc/apt/sources.list.d/$chave.list" ]; then
			echo "${repos_avulsos[$chave]}" >> /etc/apt/sources.list.d/$chave.list
		fi
	done
}

install_packages() {
	for pkg in "${packages_to_install[@]}"; do
		apt-fast install $pkg --allow-unauthenticated --force-yes -y
	done
}

purge_packages() {
	for pkg in "${packages_to_purge[@]}"; do
		apt-get remove -y $pkg --force-yes -y
	done

	apt-fast autoremove --force-yes -y --purge
}

clean_packages () {
	apt-fast autoremove -y
	apt-fast autoclean -y
}

do_fixes() {
	# Por algum motivo o bash_history fica com o root como dono
	chown $usuario:$usuario ~/.bash_history

	# Depois de adicionado o pacote, ativar o teclado numérico
	numlockx on

	# Necessário adicionar o usuario ao grupo vboxusers para que dispositivos por usb funcionem na vms
	addgroup $usuario vboxusers

	# Apos instalar o ncurses, ativa mais cores no terminal
	echo "export TERM=xterm-256color" >>  ~/.bashrc

	echo "options snd-hda-intel model=ref" >> /etc/modprobe.d/alsa-base.conf

	# detecta os sensores de temperatura
	sensors-detect
}

add_pathogen() {
	mkdir -p /home/$usuario/.vim/autoload /home/$usuario/.vim/bundle; \
	curl -Sso /home/$usuario/.vim/autoload/pathogen.vim \
	    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

	echo "call pathogen#infect()" > /etc/vim/vimrc.local
}

remove_daemons() {
	for daemon in "${daemons_not_start_automatically[@]}"; do
		update-rc.d -f $daemon remove
	done
}

create_directory_structure() {
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

if [ `id -u` -eq 0 ]; then
	add_repo
	install_packages
	purge_packages
	clean_packages
	create_directory_structure
	do_fixes
	add_pathogen
	remove_daemons
else
	echo "Voce deve executar este script como root!"
fi
