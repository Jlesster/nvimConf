vim.filetype.add({
  extension = {
    gsc = 'gsc',
    csc = 'gsc',
  },
})

-- Piggyback on the C treesitter parser/highlight queries
vim.treesitter.language.register('c', 'gsc')
