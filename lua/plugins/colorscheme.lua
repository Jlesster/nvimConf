return {
  {
    name = 'crust_mocha',
    dir = vim.fn.stdpath('config'),
    lazy = true,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('crust_mocha')
    end,
  },
  {
    name = 'sakura',
    dir = vim.fn.stdpath('config'),
    lazy = true,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('sakura')
    end,
  },
  {
    name = 'Dankula',
    dir = vim.fn.stdpath('config'),
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('dankula')
    end,
  },
}
