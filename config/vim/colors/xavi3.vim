hi clear

"  POSSIBLES COLORS:  *cterm-colors*
"  
"  NR-16   NR-8    COLOR NAME 
"  0       0       Black
"  1       4       DarkBlue
"  2       2       DarkGreen
"  3       6       DarkCyan
"  4       1       DarkRed
"  5       5       DarkMagenta
"  6       3       Brown, DarkYellow
"  7       7       LightGray, LightGrey, Gray, Grey
"  8       0*      DarkGray, DarkGrey
"  9       4*      Blue, LightBlue
"  10      2*      Green, LightGreen
"  11      6*      Cyan, LightCyan
"  12      1*      Red, LightRed
"  13      5*      Magenta, LightMagenta
"  14      3*      Yellow, LightYellow
"  15      7*      WhiteP

syntax reset
let g:colors_name="xavi3"

hi ColorColumn        cterm=none       ctermfg=none       ctermbg=DarkGray

hi Visual             cterm=none       ctermfg=Black      ctermbg=White
hi Search             cterm=bold       ctermfg=Black      ctermbg=Yellow
hi LineNr             cterm=none       ctermfg=Gray       ctermbg=none
hi Folded             cterm=none       ctermfg=Gray       ctermbg=Black
hi Pmenu              cterm=none       ctermfg=White      ctermbg=Gray
hi PmenuSel           cterm=none       ctermfg=Yellow     ctermbg=Black

hi Normal             cterm=none       ctermfg=White      ctermbg=none
hi NonText            cterm=none       ctermfg=Red        ctermbg=none

hi Comment            cterm=none       ctermfg=DarkGreen  ctermbg=none
hi Constant           cterm=none       ctermfg=Red        ctermbg=none
hi String             cterm=none       ctermfg=Cyan       ctermbg=none
hi Character          cterm=none       ctermfg=Red        ctermbg=none
hi Number             cterm=none       ctermfg=Red        ctermbg=none
hi Boolean            cterm=none       ctermfg=Red        ctermbg=none
hi Float              cterm=none       ctermfg=Red        ctermbg=none
hi Identifier         cterm=bold       ctermfg=Yellow     ctermbg=none
hi Function           cterm=bold       ctermfg=Yellow     ctermbg=none
hi Statement          cterm=bold       ctermfg=Blue       ctermbg=none
hi Conditional        cterm=bold       ctermfg=Blue       ctermbg=none
hi Repeat             cterm=bold       ctermfg=Blue       ctermbg=none
hi Label              cterm=bold       ctermfg=Blue       ctermbg=none
hi Operator           cterm=bold       ctermfg=Blue       ctermbg=none
hi Keyword            cterm=bold       ctermfg=Blue       ctermbg=none
hi Exception          cterm=bold       ctermfg=Blue       ctermbg=none

hi PreProc            cterm=bold       ctermfg=Blue       ctermbg=none
hi Type               cterm=bold       ctermfg=Yellow     ctermbg=none
hi StorageClass       cterm=bold       ctermfg=Yellow     ctermbg=none
"hi Structure          cterm=bold       ctermfg=Yellow     ctermbg=none
hi Structure          cterm=bold       ctermfg=Brown      ctermbg=none
hi Typedef            cterm=bold       ctermfg=Yellow     ctermbg=none

hi Special            cterm=none       ctermfg=Magenta    ctermbg=none
hi SpecialChar        cterm=none       ctermfg=Magenta    ctermbg=none
hi Tag                cterm=none       ctermfg=DarkMagenta    ctermbg=none
hi Delimiter          cterm=none       ctermfg=Magenta    ctermbg=none
hi SpecialComment     cterm=none       ctermfg=Magenta    ctermbg=none
hi Debug              cterm=bold       ctermfg=Black      ctermbg=Red
hi Error              cterm=none       ctermfg=Yellow     ctermbg=Red
hi Ignore             cterm=underline  ctermfg=none       ctermbg=none
hi Todo               cterm=bold       ctermfg=Black      ctermbg=Yellow
hi SpellBad           cterm=underline  ctermfg=Yellow     ctermbg=Red
hi SpellLocal         cterm=none       ctermfg=White      ctermbg=Black

hi Underlined         cterm=underline  ctermfg=none       ctermbg=none
hi MatchParen         cterm=underline  ctermfg=Black      ctermbg=Red

hi cFormat            cterm=none       ctermfg=Magenta    ctermbg=none

hi javaScript         cterm=none       ctermfg=White      ctermbg=none
hi htmlH1             cterm=bold       ctermfg=Yellow     ctermbg=none
hi htmlH2             cterm=bold       ctermfg=Yellow     ctermbg=none
hi htmlH3             cterm=bold       ctermfg=Yellow     ctermbg=none
hi htmlH4             cterm=bold       ctermfg=Yellow     ctermbg=none
hi htmlH5             cterm=bold       ctermfg=Yellow     ctermbg=none
hi htmlH6             cterm=bold       ctermfg=Yellow     ctermbg=none
hi mkdDelimiter       cterm=none       ctermfg=Yellow     ctermbg=none

hi DiffAdd            cterm=bold       ctermfg=Green      ctermbg=none
hi DiffDelete         cterm=bold       ctermfg=Red        ctermbg=none
hi DiffChange         cterm=bold       ctermfg=Yellow     ctermbg=DarkGray
hi DiffText           cterm=bold       ctermfg=White      ctermbg=DarkGray

syntax enable
