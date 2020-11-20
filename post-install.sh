#! /bin/sh

# ----- default packages ---------
sudo apt update
sudo apt install -y git vim xorg xserver-xorg gcc make xdo
sudo apt install -y libx11-dev lifxft-dev libxinerama-dev 
sudo apt install -y libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
sudo apt install -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev
sudo apt install -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
sudo apt install -y compton feh fonts-font-awesome curl vifm
#sudo apt install -y pcmanfm lxappearance mpv cmus


# ----- folders in HOME ---------
mkdir downloads music bin pictures pictures/walls tmp videos


# ----- wallpapers --------------
cd pictures/walls
curl -O http://static.simpledesktops.com/uploads/desktops/2012/01/25/enso3.png
curl -O http://static.simpledesktops.com/uploads/desktops/2018/07/29/night.png
curl -O http://static.simpledesktops.com/uploads/desktops/2014/09/02/pulsarmap.png
curl -O http://static.simpledesktops.com/uploads/desktops/2014/10/15/tetons-at-night.png
curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/21/coffee-pixels.png
curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/02/mountains-on-mars.png
curl -O http://static.simpledesktops.com/uploads/desktops/2015/02/20/zentree_1.png
curl -O http://static.simpledesktops.com/uploads/desktops/2013/09/18/wallpaper.png


# ----- git ----------------------
mkdir ~/git ~/git/protesilaos ~/git/linuxdabbler ~/git/lukesmith
cd ~/git/protesilaos
git clone https://gitlab.com/protesilaos/lemonbar-xft.git
git clone https://gitlab.com/protesilaos/st
git clone https://gitlab.com/protesilaos/cpdfd
cd ~/git/linuxdabbler
git clone https://github.com/linuxdabbler/suckless
cd ~/git/lukesmith
git clone https://github.com/LukeSmithxyz/st
cd ~/git
git clone https://github.com/drscream/lemonbar-xft
git clone https://github.com/baskerville/bspwm
git clone https://github.com/baskerville/sxhkd
git clone https://github.com/xabarca/dotfiles


# ----- git compile+installs ----------------------
cd ~/git/protesilaos/lemonbar-xft
sudo make install
cd ~/git/lukesmith/st
sudo make install
cd ~/git/linuxdabbler/suckless/dmenu
sudo make install
cd ~/git/bspwm
make
sudo make install
cd ~/git/sxhkd
make
sudo make install


# ----- configure default bspwm -------------------
mkdir ~/.config ~/.config/bspwm ~/.config/sxhkd
cp ~/git/bspwm/examples/bspwmrc ~/.config/bspwm/
cp ~/git/bspwm/examples/sxhkdrc ~/.config/sxhkd/
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/sxhkd/sxhkdrc
sed -i 's/urxvt/st/' ~/.config/sxhkdrc
sed -i 's/super + @space/super + p/' ~/.config/sxhkdrc
echo "feh --bg-scale ~/pictures/walls/night.png &" >> ~/.config/bspwm/bspwmrc


# ----- lemonbar panel ----------------------------
cp ~/git/dotfiles/panel ~/bin
cp ~/git/dotfiles/panel_bar ~/bin
cp ~/git/dotfiles/panel_colors ~/bin
cp ~/bin/launch-bar.sh ~/bin
chmod +x ~/bin/panel
chmod +x ~/bin/panel_bar
chmod +x ~/bin/panel_colors
chmod +x ~/bin/launch-bar.sh
echo "~/bin/launch-bar.sh &" >> ~/.config/bspwm/bspwmrc


# ----- xinit -------------------
echo "exec bspwm" >> ~/.xinitrc


