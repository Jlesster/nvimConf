" GSC syntax for Call of Duty (T6/BO2, T7/BO3)
" Covers IW engine scripting language variants

if exists("b:current_syntax")
  finish
endif

" ── Control flow ──────────────────────────────────────────────────────────────
syn keyword gscStatement
  \ return break continue
  \ if else for foreach while do switch case default

" ── Threading / event model ───────────────────────────────────────────────────
syn keyword gscThread
  \ thread endon notify waittill waittillmatch waittillframeend
  \ waittilltimeout

" ── Special entity references ─────────────────────────────────────────────────
syn keyword gscEntity
  \ self level game anim

" ── Wait (statement, not a function in GSC) ───────────────────────────────────
syn keyword gscWait
  \ wait

" ── Type / value keywords ─────────────────────────────────────────────────────
syn keyword gscConstant
  \ true false undefined

" ── T7 / BO3 function declaration modifiers ───────────────────────────────────
syn keyword gscFunction
  \ function autoexec private

" ── Preprocessor directives ───────────────────────────────────────────────────
" T6: #include, #define, #precache variants
" T7: #using, #insert, #namespace, #define, #precache variants
syn match gscPreproc
  \ "^\s*#\(include\|using\|insert\|define\|namespace\|using_animtree\)\>"
syn match gscPreproc
  \ "^\s*#precache\s*("

" ── Backslash-separated include paths ─────────────────────────────────────────
" e.g.  #include maps\_utility;
" e.g.  #using scripts\codescripts\struct;
syn match gscIncludePath
  \ +"\(\w\|[\\/]\)*"+ contained containedin=gscPreproc

" ── Numbers ───────────────────────────────────────────────────────────────────
syn match gscNumber "\<\d\+\(\.\d*\)\?\>"
syn match gscNumber "\<\.\d\+\>"
syn match gscNumber "\<0x[0-9a-fA-F]\+\>"

" ── Strings ───────────────────────────────────────────────────────────────────
syn region gscString   start=+"+  skip=+\\"+  end=+"+ contains=gscEscape
syn region gscString   start=+&"+ skip=+\\"+  end=+"+  " localised strings (&"key")
syn match  gscEscape   +\\[ntr\\"]+  contained

" ── Hashed strings (T7) ───────────────────────────────────────────────────────
" #"some_hash_string" — compile-time hashed string literal
syn region gscHashString start=+#"+ end=+"+

" ── Developer blocks ──────────────────────────────────────────────────────────
" /# ... #/  — stripped in non-dev builds
syn region gscDevBlock
  \ start=+/#+  end=+#+/+
  \ contains=TOP
  \ fold

" ── Comments ──────────────────────────────────────────────────────────────────
syn region gscComment  start="/\*"  end="\*/"  contains=gscTodo fold
syn match  gscComment  "//.*$"      contains=gscTodo
syn keyword gscTodo    contained TODO FIXME HACK NOTE WARN

" ── Indirect function call syntax: [[var]]() ──────────────────────────────────
syn match gscIndirectCall "\[\[.\{-}\]\]"

" ── Operators ─────────────────────────────────────────────────────────────────
syn match gscOperator "[+\-*/%&|^~!<>=]=\?"
syn match gscOperator "&&\|||"
syn match gscOperator "::"   " namespace separator / function pointer

" ── Link to highlight groups ──────────────────────────────────────────────────
hi def link gscStatement    Statement
hi def link gscThread       Keyword
hi def link gscWait         Keyword
hi def link gscEntity       Special
hi def link gscConstant     Boolean
hi def link gscFunction     Keyword
hi def link gscPreproc      PreProc
hi def link gscIncludePath  String
hi def link gscNumber       Number
hi def link gscString       String
hi def link gscHashString   String
hi def link gscEscape       SpecialChar
hi def link gscDevBlock     Comment
hi def link gscComment      Comment
hi def link gscTodo         Todo
hi def link gscIndirectCall Macro
hi def link gscOperator     Operator

let b:current_syntax = "gsc"
