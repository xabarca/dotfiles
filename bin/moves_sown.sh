#!/bin/sh

resize() { xdotool getwindowfocus windowsize "${1:-0}" "${2:-0}"; }

move() { xdotool getwindowfocus windowmove "${1:-0}" "${2:-0}"; }

snap() {
    eval "$(xdotool getwindowfocus getwindowgeometry --shell | head -n5)"
    W_WIDTH="${WIDTH}"; W_HEIGHT="${HEIGHT}"
    eval "$(xdotool getdisplaygeometry --shell)"
    case "${1:-0}" in
        left)   move 0 y                         ;;
        bottom) move x "$(( HEIGHT - W_HEIGHT ))";;
        top)    move x 0                         ;;
        right)  move "$(( WIDTH - W_WIDTH ))" y  ;;
        *)      move x y                         ;;
    esac
}

pos_layout() {
    eval "$(xdotool getwindowfocus getwindowgeometry --shell | head -n5)"
    W_WIDTH="${WIDTH}"; W_HEIGHT="${HEIGHT}"
    eval "$(xdotool getdisplaygeometry --shell)"
    DR_WIDTH="$(( WIDTH))"; DR_HEIGHT="$(( HEIGHT))"
    case "${1:-0}" in
        1)      move 0 0
                resize "$(( DR_WIDTH / 2))" "$((DR_HEIGHT / 2))"
                ;;
        2)      move "$(( DR_WIDTH / 2))"  0
                resize "$(( DR_WIDTH / 2))" "$((DR_HEIGHT / 2))"
                ;;
        3)      move 0 "$(( DR_HEIGHT / 2))" 
                resize "$(( DR_WIDTH / 2))" "$((DR_HEIGHT / 2))"
                ;;
        4)      move "$(( DR_WIDTH / 2))" "$(( DR_HEIGHT / 2))" 
                resize "$(( DR_WIDTH / 2))" "$((DR_HEIGHT / 2))"
                ;;
        5)      move 0 0
                resize "$(( DR_WIDTH / 2))" "$DR_HEIGHT"
                ;;
        6)      move "$(( DR_WIDTH / 2))"  0
                resize "$(( DR_WIDTH / 2))" "$DR_HEIGHT"
                ;;
        7)      move 0 0
                resize "$DR_WIDTH" "$((DR_HEIGHT / 2))"
                ;;
        8)      move 0 "$(( DR_HEIGHT / 2))" 
                resize "$DR_WIDTH" "$((DR_HEIGHT / 2))"
                ;;
        9)      move "$(( DR_WIDTH / 4))" "$(( DR_HEIGHT / 4))" 
                resize "$((DR_WIDTH / 2))" "$((DR_HEIGHT / 2))"
                ;;
        0)      move 0 0
                resize "$DR_WIDTH" "$DR_HEIGHT"
                ;;
    esac
}


pointer_focus() { xdotool getmouselocation windowfocus; }

select_focus() { xdotool selectwindow windowfocus; }

close() { xdotool getwindowfocus windowclose; }

quit() { xdotool getwindowfocus windowquit;  }

window_kill() { xdotool getwindowfocus windowkill;  }

case "${1}" in
    "")              noargs || exit 1             ;;
    resize)          resize          "${2}" "${3}";;
    move)            move            "${2}" "${3}";;
    pos_layout)      pos_layout      "${2}"       ;;
    snap)            snap            "${2}"       ;;
    pointer_focus)   pointer_focus                ;;
    select_focus)    select_focus                 ;;
    close)           close                        ;;
    quit)            quit                         ;;
    kill)            window_kill                  ;;
    *)               exit 1                       ;;
esac
