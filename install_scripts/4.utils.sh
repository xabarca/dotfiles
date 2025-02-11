!/bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"


# ----- Enchive - archiver/extractor of encypted backups -------------------
get_enchive() {
	git clone --depth 1  https://github.com/skeeto/enchive /opt/git/enchive
	cd /opt/git/enchive || return
	sed -i 's/.enchive/.encx/' "/opt/git/enchive/config.h"
	$ld make install
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] enchive installed" >> $LOG_FILE
}

# ----- configure neovim and vim-plug -------------------------
install_nvim() {
	mkdir -p $HOME/.config/nvim/colors
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    cp ../config/vim/init.vim $HOME/.config/nvim/init.vim
    cp ../config/vim/colors/*.vim $HOME/.config/nvim/colors
    echo "[$(date '+%Y-%m-%d %H:%M.%S')] neovim config done" >> $LOG_FILE
}


# ----- Daemon-less notifications without D-Bus. Minimal and lightweight. -------------------
get_herbe() {
	git clone --depth 1  https://github.com/dudik/herbe /opt/git/herbe
	cd /opt/git/herbe || return
	git apply "../patches/herbe-xresources-critical.diff"
	make && strip herbe
	$ld ln -fs "$PWD/herbe" /usr/local/bin
}


# ----- download and install youtube-dl from github ---------
youtube_downloader () {
	$ld curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
	$ld chmod a+rx /usr/local/bin/yt-dlp
	mkdir -p $HOME/.config/mpv
	echo "input-ipc-server=/tmp/mpvsocket" >> $HOME/.config/mpv/mpv.conf
	echo "script-opts=ytdl_hook-ytdl_path=yt-dlp" >> $HOME/.config/mpv/mpv.conf
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] yt-dlp ready" >> $LOG_FILE
}

# ----- brosers (qutebrowser & LibreWolf) ---------
browsers () {
	# https://github.com/qutebrowser/qutebrowser/blob/master/doc/help/configuring.asciidoc
	# https://github.com/Linuus/nord-qutebrowser/blob/master/nord-qutebrowser.py
	
	# https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.139-1/ungoogled-chromium_131.0.6778.139-1.AppImage
	
	# sudo apt install -y qutebrowser
	# mkdir -p "$HOME/.config/qutebrowser/themes"
	# cp $ACTUAL_DIR/qutebrowser/config.py  "$HOME/.config/qutebrowser/"
	# cp $ACTUAL_DIR/qutebrowser/xavi.py $ACTUAL_DIR/qutebrowser/nord.py  "$HOME/.config/qutebrowser/themes/"

    curl -fLo /opt/AppImage/LibreWolf.x86_64.AppImage 'https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/135.0-1/LibreWolf.x86_64.AppImage'
	chmod +x /opt/AppImage/LibreWolf.x86_64.AppImage
	$ld ln -fs /opt/AppImage/LibreWolf.x86_64.AppImage /usr/local/bin/LibreWolf
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] LibreWolf" >> $LOG_FILE	

    curl -fLo /opt/AppImage/ungoogled-chromium_131.0.6778.139-1.AppImage 'https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/133.0.6943.53-1/ungoogled-chromium_133.0.6943.53-1.AppImage'
	chmod +x /opt/AppImage/ungoogled-chromium_131.0.6778.139-1.AppImage
	$ld ln -fs /opt/AppImage/ungoogled-chromium_131.0.6778.139-1.AppImage /usr/local/bin/ungoogled-chromium
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] Ungoogled-chromium" >> $LOG_FILE
}

get_herbe
install_nvim
get_enchive
youtube_downloader
browsers

