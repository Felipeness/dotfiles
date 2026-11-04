-- Editor enhancements and overrides
return {
  -- No buffer tabs on top (like craftzdog); switch buffers with <leader>, or the picker
  { "akinsho/bufferline.nvim", enabled = false },

  -- Better diagnostics display (like Error Lens in VS Code)
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
 ███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗
 ████╗  ██║ ██║   ██║ ██║ ████╗ ████║
 ██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║
 ██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
 ██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║
 ╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
        },
      },
    },
  },

  -- Highlight TODO/FIXME/HACK comments
  {
    "folke/todo-comments.nvim",
    opts = {
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*:]],
      },
    },
  },

  -- Better quickfix
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
    },
  },
}
