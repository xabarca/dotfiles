import subprocess

def read_xresources(prefix):
    props = {}
    x = subprocess.run(['xrdb', '-query'], stdout=subprocess.PIPE)
    lines = x.stdout.decode().split('\n')
    for line in filter(lambda l : l.startswith(prefix), lines):
        prop, _, value = line.partition(':\t')
        props[prop] = value
    return props

xresources = read_xresources('*')
# c.colors.statusbar.normal.bg = xresources['*.background']


# color variables
darkgrey = "#030303"
lessdarkgrey = "#3e3e3e"
midgrey = "#808080"

# maybe it is much bright
# white = "#ffffff"
white = "#999999"

# accent color
accentcolor = xresources['*.color10']

# this is too much, this ugly bright magenta !
# magenta = "#ff009e"
magenta = "#b1942b"
magenta = xresources['*.color13']
magenta = accentcolor

# this is magenta even more bright
# cyan = "#FA53FF"
cyan = "#7e4b6b"
cyan = "#73611c"
cyan = "#626664" 
cyan = lessdarkgrey

yellow = "#ffdb00"
red = "#ff0000"



# styling
c.colors.completion.category.bg = darkgrey
c.colors.completion.category.border.bottom = white
c.colors.completion.category.border.top = darkgrey
c.colors.completion.category.fg = white
c.colors.completion.even.bg = darkgrey
c.colors.completion.odd.bg = darkgrey
c.colors.completion.fg = white
c.colors.completion.item.selected.border.bottom = darkgrey
c.colors.completion.item.selected.border.top = darkgrey
c.colors.completion.item.selected.bg = cyan
# c.colors.completion.item.selected.fg = darkgrey
c.colors.completion.item.selected.fg = white
c.colors.completion.item.selected.match.fg = magenta
c.colors.completion.match.fg = magenta 

c.completion.scrollbar.width = 0

c.colors.contextmenu.menu.bg =  darkgrey
c.colors.contextmenu.menu.fg =  white
c.colors.contextmenu.disabled.bg = darkgrey 
c.colors.contextmenu.disabled.fg = midgrey
c.colors.contextmenu.selected.bg = cyan
# c.colors.contextmenu.selected.fg = darkgrey
c.colors.contextmenu.selected.fg = white

c.colors.hints.bg = yellow
c.colors.hints.fg =  darkgrey
c.colors.hints.match.fg = red

c.colors.tabs.bar.bg = darkgrey
c.colors.tabs.even.bg = darkgrey
c.colors.tabs.odd.fg = white 
c.colors.tabs.even.fg = white
c.colors.tabs.odd.bg = darkgrey
c.colors.tabs.selected.even.bg = darkgrey
c.colors.tabs.selected.odd.bg = darkgrey
c.colors.tabs.selected.even.fg = magenta
c.colors.tabs.selected.odd.fg = magenta
# c.colors.tabs.selected.even.fg = xresources['*.color10']
# c.colors.tabs.selected.odd.fg = xresources['*.color10']

c.colors.statusbar.command.bg = darkgrey
c.colors.statusbar.url.success.http.fg = cyan 
c.colors.statusbar.url.success.https.fg = cyan 

c.colors.statusbar.url.success.http.fg = xresources['*.color2'] 
c.colors.statusbar.url.success.https.fg = xresources['*.color2'] 
c.colors.statusbar.url.success.http.fg = xresources['*.color10'] 
c.colors.statusbar.url.success.https.fg = xresources['*.color10'] 

