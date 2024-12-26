#!/bin/sh


# ----- configure Xresources -------------------------
xresources() {
    cp -r ../config/Xresources $HOME/.config/
	xrdb ~/.config/Xresources/Xresources
}

xresources
