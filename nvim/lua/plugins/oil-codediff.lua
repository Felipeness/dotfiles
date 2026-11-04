return {
  -- Edit directories like buffers; "-" opens the parent dir
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { view_options = { show_hidden = true } },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" } },
  },

  -- VSCode-style diff to review the agent's changes
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    keys = { { "<leader>gD", "<cmd>CodeDiff<cr>", desc = "Code diff (review changes)" } },
  },
}
