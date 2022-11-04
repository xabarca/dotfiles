#! /bin/sh

# ----- nerd fonts ---------
fonts() {
	mkdir /tmp/nerdfonts
	cd /tmp/nerdfonts || return
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip
#	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
#	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Mononoki.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/VictorMono.zip
	# curl -L -o hack.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
	# curl -L -o awesome-5-15.zip https://github.com/FortAwesome/Font-Awesome/releases/download/5.15.4/fontawesome-free-5.15.4-web.zip 
	# curl -L -o jetbrains.zip https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip?fromGitHub
	unzip "*.zip"
	rm *Windows*
	sudo mkdir -p /usr/share/fonts/truetype/newfonts
	find . -name '*.ttf' >tmp
	while read file
	do
		sudo cp "$file" /usr/share/fonts/truetype/newfonts
	done<tmp
	sudo fc-cache -f -v
}

fonts
