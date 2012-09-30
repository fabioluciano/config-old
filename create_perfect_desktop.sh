#!/bin/bash

# #######################################################
# @Author: Fábio Luciano								#
# @Email pessoal: omega.df@gmail.com 					#
# @Date: 03/09/2012  16:54:00 PM 						#
# @Description: Script criado com o intuito de criar 	#
# o perfeito desktop para desenvolvimento				#
# #######################################################

# Usuário a qual ficará responsável por alguns diretórios
usuario='fabioluciano'

# Ativa os arrays associativos. Coloquei todos como associativos... Vai que uma hora eu preciso
declare -A chaves_avulsas repos_ppa repos_avulsos packages_to_install packages_to_purge

# Definição de repositórios utilizando ppas a serem instalados
repos_ppa=(
	["tweak"]="tualatrix"
	["nodejs"]="chris-lea/node.js" #nodejs
	["vala"]="vala-team" #vala
	["gmailwatcher"]="loneowais/gmailwatcher.dev" #gmailwhatcher
	["gimp"]="otto-kesselgulasch/gimp" #gimp
	["shutter"]="shutter/ppa" #shutter
	["weather"]="weather-indicator-team/ppa" #weather-indicator
	["libreoffice"]="libreoffice/ppa" #libreoffice
	["faenza-icon-theme"]="tiheum/equinox" #faenza-icon-theme
	["geany"]="geany-dev/ppa" #geany
	["mysql-workbench"]="olivier-berten/misc" #mysql-workbench
	["nginx"]="nginx/stable" #nginx
	["qbittorent"]="hydr0g3n/ppa" #qbittorent
	["sublime-text"]="webupd8team/sublime-text-2" #sublime-text
	["puddletag"]="webupd8team/puddletag" #puddletag
	["jupiter"]="webupd8team/jupiter" #jupiter
	["indicator-shutter"]="nilarimogard/webupd8" #indicator-shutter
	["grub-customizer"]="danielrichter2007/grub-customizer" #grub-customizer
	["greybird"]="shimmerproject/ppa" #greybird - new
	["yad"]="webupd8team/y-ppa-manager" #yad
	["caffeine"]="caffeine-developers/ppa" #caffeine
	["xnoise"]="shkn/xnoise" #xnouise
	["xorg-edgers"]="xorg-edgers/ppa"
	["yorba"]="yorba/ppa" #shotwell
	["php54"]="ondrej/php5" #php5.4
	["marlin"]="marlin-devs/marlin-daily" #marlin
)

# Repositórios fora do ppa
repos_avulsos=(
	["google-chrome"]="deb http://dl.google.com/linux/chrome/deb/ stable main"
	["virtualbox"]="deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
	["opera"]="deb http://deb.opera.com/opera/ stable non-free"
	["mediubuntu"]="deb http://packages.medibuntu.org/ precise free non-free"
	["getdeb"]="deb http://archive.getdeb.net/ubuntu precise-getdeb apps"
)

# Chaves dos repositórios avulsos
chaves_avulsas=(
	["google-chrome"]="https://dl-ssl.google.com/linux/linux_signing_key.pub" #google-chrome
	["virtualbox"]="http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc" #virtualbox
	["opera"]="http://deb.opera.com/archive.key" #opera
	["getdeb"]="http://archive.getdeb.net/getdeb-archive.key" #getdeb
)

packages_to_install=(
	["sysadmin-tools"]="openssh-server htop pac wireshark filezilla virtualbox-4.2 ddclient"
	["productivity"]="cuckoo gmailwatcher caffeine"
	["performance-tools"]="preload"
	["development-tools"]="nodejs valac-0.16 geany sublime-text mysql-workbench yad nginx git subversion "
	["php54"]="php5 libapache2-mod-php5 php5-dev php5-gd php5-geoip php5-mcrypt php5-memcache php5-memcached php5-pgsql php5-xdebug"
	["databases"]="mysql-server mysql-client apache2"
	["graphic-tools"]="gimp dia blender inkscape shutter shotwell"
	["tweaks"]="ncurses-term ubuntu-tweak jupiter numlockx lm-sensors grub-customizer marlin"
	["indicators"]="indicator-shutter indicator-weather indicator-multiload"
	["browsers"]="opera google-chrome-stable"
	["visual-related"]="faenza-icon-theme shimmer-themes-greybird compiz compizconfig-settings-manager compiz-core compiz-fusion-plugins-extra compiz-fusion-plugins-main compiz-gnome compiz-plugins compiz-plugins-default compiz-plugins-extra compiz-plugins-main compiz-plugins-main-default"
	["codecs"]="non-free-codecs libdvdcss2 faac faad ffmpeg ffmpeg2theora flac icedax id3v2 lame libflac++6 libjpeg-progs libmpeg3-1 mencoder mjpegtools mp3gain mpeg2dec mpeg3-utils mpegdemux mpg123 mpg321 regionset sox uudeview vorbis-tools x264"
	["multimedia-related"]="flashplugin-installer vlc medibuntu-keyring audacious puddletag xfce4-mixer xnoise"
	["archiver"]="arj lha p7zip p7zip-full p7zip-rar unrar unace-nonfree"
	["editors"]="vim libreoffice"
	["internet-tools"]="qbittorrent"
)

packages_to_purge=(
	["apport"]="apport apport-symptoms"
	["xfce-apps"]="orage onboard abiword gnumeric gnumeric-common gnumeric-doc simple-scan transmission-gtk transmission-common gnome-games-data gmusicbrowser aisleriot parole"
)

add_repo() {
	add_repos_por_ppa #chamando função para adição de repositórios por ppa
	add_repos_avulsos #chamando função para adição de repositórios por ppa

	# Atualizar a lista local de pacotes
	apt-get update --fix-missing --fix-broken

	# Faz upgrade dos pacotes obsoletos
	apt-get dist-upgrade -u -y
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
			wget -q -O - ${chaves_avulsas[$chave]} | sudo apt-key add -
		fi

		#Agora criamos configuramos os repositórios
		if [ ! -s "/etc/apt/sources.list.d/$chave.list" ]; then
			echo "${repos_avulsos[$chave]}" >> /etc/apt/sources.list.d/$chave.list
		fi
	done
}

install_packages() {
	for pkg in "${packages_to_install[@]}"; do
		apt-get install $pkg --allow-unauthenticated --force-yes -y
	done
	
}

purge_packages() {
	for pkg in "${packages_to_purge[@]}"; do
		apt-get remove -y $pkg --force-yes -y
	done

	apt-get autoremove --force-yes -y --purge
}

clean_packages () {
	apt-get autoremove -y
	apt-get autoclean -y
}

do_fixes() {
	# Por algum motivo o bash_history fica com o root como dono
	chown $usuario:$usuario ~/.bash_history

	# Depois de adicionado o pacote, ativar o teclado numérico
	numlockx on

	# Apos instalar o ncurses, ativa mais cores no terminal
	echo "export TERM=xterm-256color" >>  ~/.bashrc

	# detecta os sensores de temperatura
	sensors-detect
}

add_pathogen() {
	mkdir -p /home/$usuario/.vim/autoload /home/$usuario/.vim/bundle; \
	curl -Sso /home/$usuario/.vim/autoload/pathogen.vim \
	    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

	echo "call pathogen#infect()" > /etc/vim/vimrc.local
}

create_directory_structure() {

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
	#add_repo
	#install_packages
	#purge_packages
	#clean_packages
	#create_directory_structure
	#do_fixes
	add_pathogen
else
	echo "Voce deve executar este script como root!"
fi
