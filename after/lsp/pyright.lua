return {
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to let Ruff handle linting
        -- Pyright will still provide type checking and intellisense
        ignore = { "*" },
      },
    },
  },
}
