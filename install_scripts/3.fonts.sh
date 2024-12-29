#! /bin/sh

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# ----- nerd fonts ---------
_fonts() {
	VERSION=3.2.1
	BASE=https://github.com/ryanoasis/nerd-fonts/releases/download
    list='Hack Ubuntu UbuntuMono UbuntuSans JetBrainsMono Inconsolata'
	
	mkdir /tmp/nerdfonts
	cd /tmp/nerdfonts || return
	for font in $list; do
	    # curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
        curl -L -O "$BASE/v${VERSION}/$font"".zip"
    done
    
	yes | unzip "*.zip"
	rm *Windows*
	$ld mkdir -p /usr/share/fonts/truetype/newfonts
	find . -name '*.ttf' >tmp
	while read file
	do
		$ld cp "$file" /usr/share/fonts/truetype/newfonts
	done<tmp
	$ld fc-cache -f -v
}

_fonts

