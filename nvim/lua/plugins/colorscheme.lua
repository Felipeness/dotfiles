-- Solarized Osaka (vivid), same as craftzdog's; transparent so the terminal shows through
return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "vivid",
      transparent = true,
      -- vivid's pink/red match highlights read like errors; keep them subtle
      on_highlights = function(hl, c)
        hl.MatchParen = { fg = c.orange, bold = true, underline = true }
        hl.LspReferenceText = { bg = c.base02 }
        hl.LspReferenceRead = { bg = c.base02 }
        hl.LspReferenceWrite = { bg = c.base02, underline = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "solarized-osaka" },
  },
}
