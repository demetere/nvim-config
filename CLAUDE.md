# Neovim Configuration

Personal modular Neovim config using lazy.nvim as the plugin manager.

## Critical Instructions

- **NEVER** add `Co-Authored-By` lines to git commits.
- After making changes, check if CLAUDE.md is invalidated and update it.

## Project Structure

```
init.lua                    → Entry point: loads core, lazy, lsp
lua/demetere/
  core/
    init.lua                → Requires options.lua and keymaps.lua
    options.lua             → Editor settings (indent, numbers, clipboard, etc.)
    keymaps.lua             → Global keybindings (splits, tabs, misc)
  lazy.lua                  → Bootstraps lazy.nvim, imports plugin specs
  lsp.lua                   → LSP keymaps (gd, gR, K, etc.) and diagnostic config
  plugins/
    init.lua                → Base plugins (plenary, tmux-navigator)
    lsp/
      mason.lua             → Mason server/tool installation lists
      lsp.lua               → LSP capabilities (cmp integration)
    nvim-cmp.lua            → Completion engine config
    conform.lua             → Formatting (format-on-save)
    nvim-lint.lua           → Linting (mypy for Python)
    telescope.lua           → Fuzzy finder
    treesitter.lua          → Syntax highlighting/parsing
    nvim-tree.lua           → File explorer
    copilot.lua             → GitHub Copilot
    avante.lua              → AI assistant (OpenAI)
    nvim-dap.lua            → DAP plugin spec (loads demetere.dap)
    gitsigns.lua            → Git signs + hunk operations
    lazygit.lua             → LazyGit integration
    ...                     → One file per plugin
  dap/
    init.lua                → DAP UI, signs, keymaps, loads language configs
    languages/
      python.lua            → debugpy + FastAPI config
      go.lua                → delve config
after/lsp/                  → Per-server LSP overrides (new native Neovim pattern)
  pyright.lua               → Disables import org (defers to Ruff)
  ruff.lua                  → Disables hover (defers to Pyright)
  gopls.lua                 → Enables placeholders + function call completion
```

## Loading Order

`init.lua` requires three modules in order:
1. `demetere.core` — editor options and global keymaps
2. `demetere.lazy` — bootstraps lazy.nvim, which auto-discovers plugin specs from `demetere.plugins` and `demetere.plugins.lsp`
3. `demetere.lsp` — LSP keymaps and diagnostic configuration

## Plugin Organization

Each plugin lives in its own file under `lua/demetere/plugins/` and returns a lazy.nvim spec table:

```lua
return {
  "author/plugin-name",
  dependencies = { ... },
  event = { "BufReadPre", "BufNewFile" },  -- lazy loading
  config = function()
    require("plugin").setup({ ... })
  end,
}
```

LSP plugins are in `lua/demetere/plugins/lsp/` (sub-imported by lazy.lua).

### Adding a New Plugin

1. Create `lua/demetere/plugins/<plugin-name>.lua`
2. Return a lazy.nvim spec table
3. Restart Neovim — lazy.nvim auto-discovers new files

## LSP

### Architecture
- **mason.nvim** installs LSP servers and tools
- **mason-lspconfig** bridges Mason → nvim-lspconfig
- Server list is in `lua/demetere/plugins/lsp/mason.lua` (`ensure_installed`)
- `lua/demetere/plugins/lsp/lsp.lua` sets cmp capabilities on all servers
- Per-server overrides go in `after/lsp/<server>.lua` (native Neovim 0.11+ pattern)

### Installed Servers
`ts_ls`, `html`, `cssls`, `tailwindcss`, `lua_ls`, `pyright`, `ruff`, `eslint`, `gopls`

### Adding a New LSP Server
1. Add the server name to `ensure_installed` in `lua/demetere/plugins/lsp/mason.lua`
2. (Optional) Create `after/lsp/<server>.lua` for custom settings
3. Restart Neovim; Mason installs it automatically

### LSP Keymaps (defined in `lua/demetere/lsp.lua`)
| Key | Action |
|-----|--------|
| `gd` | Go to definition (new tab) |
| `gD` | Go to declaration (new tab) |
| `gR` | Show references (Telescope) |
| `gi` | Show implementations (new tab) |
| `gt` | Show type definitions |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>d` | Line diagnostics |
| `<leader>D` | Buffer diagnostics (Telescope) |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>rs` | Restart LSP |

## DAP (Debugging)

### Architecture
- `lua/demetere/dap/init.lua` — UI setup, keymaps, breakpoint signs
- `lua/demetere/dap/languages/<lang>.lua` — each exports a `setup(dap)` function
- Mason auto-installs `debugpy` and `delve`

### Adding a New Debug Language
1. Create `lua/demetere/dap/languages/<lang>.lua`
2. Export `M.setup(dap)` that sets `dap.adapters.<lang>` and `dap.configurations.<lang>`
3. Require and call it from `lua/demetere/dap/init.lua`

### DAP Keymaps
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dq` | Terminate |
| `<leader>du` | Toggle DAP UI |
| `<leader>ds` | Select debug config |

## Formatting & Linting

### Formatting (conform.nvim) — `lua/demetere/plugins/conform.lua`
- **Format-on-save** enabled (1s timeout, async=false, LSP fallback)
- `<leader>mp` to manually format file or visual selection
- Formatters: `prettier` (JS/TS/CSS/HTML/JSON/YAML/MD), `stylua` (Lua), `ruff_fix`/`ruff_format`/`ruff_organize_imports` (Python), `goimports`/`gofumpt` (Go)

### Linting (nvim-lint) — `lua/demetere/plugins/nvim-lint.lua`
- Python: `mypy` (venv-aware — looks for `.venv/bin/mypy`)
- Auto-triggers on `BufEnter`, `BufWritePost`, `InsertLeave`

## Completion (nvim-cmp) — `lua/demetere/plugins/nvim-cmp.lua`

Sources (priority order): LSP → LuaSnip → buffer → path

| Key | Action |
|-----|--------|
| `<C-j>` / `<C-k>` | Next / previous suggestion |
| `<C-b>` / `<C-f>` | Scroll docs |
| `<C-Space>` | Show completion menu |
| `<C-e>` | Close menu |
| `<CR>` | Confirm (no auto-select) |

## Keybinding Conventions

**Leader**: `<Space>`

### Prefix Groups
| Prefix | Domain |
|--------|--------|
| `<leader>f` | Find (Telescope) |
| `<leader>e` | Explorer (nvim-tree) |
| `<leader>s` | Splits (`sv`, `sh`, `se`, `sx`, `sm`) |
| `<leader>t` | Tabs (`to`, `tx`, `tn`, `tp`, `tf`) |
| `<leader>d` | Debug / diagnostics |
| `<leader>h` | Git hunks (gitsigns) |
| `<leader>c` | Code actions |
| `<leader>r` | Rename / restart |
| `<leader>w` | Sessions (workspace) |
| `<leader>l` | LazyGit |
| `<leader>m` | Format (make pretty) |

### Other Keymaps
- `jk` — exit insert mode
- `<leader>nh` — clear search highlights
- `<leader>+` / `<leader>-` — increment / decrement
- `<S-Tab>` — accept Copilot suggestion
- `[h` / `]h` — previous / next git hunk
- `[t` / `]t` — previous / next TODO comment

## AI Plugins

- **Copilot** (`copilot.lua`): auto-trigger enabled, manual accept with `<S-Tab>`, panel disabled
- **Avante** (`avante.lua`): OpenAI provider, `gpt-4o-mini` model, reads project instructions from `avante.md`

## General Settings (`lua/demetere/core/options.lua`)

- 2-space indentation (spaces, not tabs)
- Relative line numbers with absolute current line
- No line wrapping
- System clipboard (`unnamedplus`)
- Case-insensitive search (smart-case when uppercase used)
- Cursor line highlighting
- Dark background, true colors (tokyonight theme)
- No swapfile
- Sign column always visible
- Splits open right / below

## File Naming

- Plugin files: `lua/demetere/plugins/<plugin-name>.lua` (kebab-case matching the plugin)
- LSP overrides: `after/lsp/<server-name>.lua`
- DAP languages: `lua/demetere/dap/languages/<language>.lua`
- All Lua modules namespaced under `demetere`
