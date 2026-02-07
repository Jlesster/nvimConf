return {
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache"
    },
    opts = {
     task_list = { -- the window that shows the results.
        direction = "bottom",
        min_height = 5,
        max_height = 5,
        default_detail = 1,
        border = "rounded",
        win_opts = {
          winblend = 0,
          winhighlight = "Normal:OverseerNormal,FloatBorder:OverseerBorder,NormalFloat:OverseerNormal",
        },
      },
      -- component_aliases = {
      --   default = {
      --     -- Behaviors that will apply to all tasks.
      --     "on_exit_set_status",                   -- don't delete this one.
      --     "on_output_summarize",                  -- show last line on the list.
      --     "display_duration",                     -- display duration.
      --     "on_complete_notify",                   -- notify on task start.
      --     "open_output",                          -- focus last executed task.
      --     { "on_complete_dispose", timeout=300 }, -- dispose old tasks.
      --   },
      -- },
    },
config = function(_, opts)
  require("overseer").setup(opts)

  -- Add colored separator line at top of Overseer window
  vim.api.nvim_create_autocmd({"FileType", "BufEnter", "TermOpen"}, {
    callback = function()
      -- Check if we're in the overseer window (bottom split)
      local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
      if wininfo and wininfo.height <= 10 and wininfo.botline then
        local ft = vim.bo.filetype
        local bufname = vim.api.nvim_buf_get_name(0)

        if ft == "OverseerList" or ft == "OverseerForm" or bufname:match("overseer") then
          if vim.fn.has('nvim-0.8') == 1 then
            vim.opt_local.winbar = "%#OverseerBorder#" .. string.rep("━", 999) .. "%*"
          end
        end
      end
    end,
  })
end,
  },
}
