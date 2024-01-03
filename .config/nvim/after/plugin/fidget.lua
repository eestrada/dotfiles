require("fidget").setup({
  -- Options related to LSP progress subsystem
  progress = {
    -- Options related to how LSP progress messages are displayed as notifications
    display = {
      skip_history = false, -- Whether progress notifications should be omitted from history
    },
  },
})
