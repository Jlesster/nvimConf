local opt = vim.opt

vim.o.wildmenu = false

vim.g.smart_splits_multiplexer_integration = 'tmux'
vim.g.luasnip_no_default_keymaps = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.colorcolumn = '95'
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.scrolloff = 99
opt.sidescrolloff = 8

opt.mouse = 'a'

opt.termguicolors = true
opt.cursorline = true
opt.relativenumber = true
opt.number = true
opt.showmode = false
opt.winminwidth = 5

opt.listchars = { tab = '  ', trail = ' ', nbsp = ' ', lead = ' ' }
opt.fillchars = { eob = '~' }
opt.showbreak = '↪ '
opt.list = true

opt.concealcursor = ''
opt.conceallevel = 0

opt.cmdheight = 0
opt.laststatus = 3
opt.pumheight = 10
opt.numberwidth = 1
opt.splitkeep = 'screen'
opt.signcolumn = 'yes:1'
opt.statuscolumn = '%=%{v:relnum?v:relnum:v:lnum} %s '
opt.guicursor =
  'n-v-c-sm:block-Cursor,i-ci-ve:hor20-iCursor-blinkon200,r-cr-o:hor20-vCursor'

opt.clipboard = 'unnamedplus'
opt.undofile = true

opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldenable = false
opt.foldlevelstart = 99

opt.diffopt:append('algorithm:patience')
opt.diffopt:append('indent-heuristic')

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.wildmode = 'longest:full,full'
opt.wildignore = '*.o,*.obj,*.pyc,*.swp,*.bak'
opt.path:append('**')

opt.splitright = true
opt.splitbelow = true
opt.equalalways = false

opt.updatetime = 200
opt.timeoutlen = 300
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undolevels = 10000
opt.shada = { "'100", '<50', 's10', 'h' }

opt.completeopt = 'menu,menuone,noselect'
opt.shortmess = 'filnxtToOCFWAsw'
opt.shell = 'zsh'

opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'

vim.g.diagnostics_mode = 3
vim.g.big_file = { size = 1024 * 1024, lines = 10000 }

opt.grepprg = 'rg --vimgrep'
opt.grepformat = '%f:%l:%c:%m'

vim.g.markdown_recommended_style = 0
vim.g.autoformat = true
vim.g.root_lsp_ignore = { 'copilot' }

local disabled_built_ins = {
  'gzip',
  'zip',
  'zipPlugin',
  'tar',
  'tarPlugin',
  'getscript',
  'getscriptPlugin',
  'vimball',
  'vimballPlugin',
  '2html_plugin',
  'logipat',
  'rrhelper',
  'spellfile_plugin',
  'matchit',
}
for _, p in pairs(disabled_built_ins) do
  vim.g['loaded_' .. p] = 1
end

vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('silent! checktime')
    end
  end,
})
