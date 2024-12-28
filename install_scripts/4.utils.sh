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

get_herbe
install_nvim
get_enchive
youtube_downloader

