if exists("b:current_syntax")
  finish
endif

syntax keyword gscConditional if else switch case default
syntax keyword gscRepeat for while foreach in
syntax keyword gscStatement return break continue thread childthread
syntax keyword gscKeyword self level game world anim
syntax keyword gscControlFlow waittill waittill_any waittillmatch
      \ waittillframeend endon notify wait waitframe
syntax keyword gscBoolean true false undefined

syntax match gscFunction /\<\h\w*\ze\s*(/
syntax match gscNamespace /\h\w*::/
syntax match gscComment "//.*$"
syntax region gscBlockComment start="/\*" end="\*/"
syntax region gscString start=/"/ skip=/\\"/ end=/"/
syntax match gscNumber /\<\d\+\(\.\d\+\)\?\>/
syntax match gscInclude /^#include\>/

highlight default link gscConditional Conditional
highlight default link gscRepeat Repeat
highlight default link gscStatement Statement
highlight default link gscKeyword Keyword
highlight default link gscControlFlow Special
highlight default link gscBoolean Boolean
highlight default link gscFunction Function
highlight default link gscNamespace Type
highlight default link gscComment Comment
highlight default link gscBlockComment Comment
highlight default link gscString String
highlight default link gscNumber Number
highlight default link gscInclude PreProc

let b:current_syntax = "gsc"
