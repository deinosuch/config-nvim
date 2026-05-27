-- Most general options set by mini.basics


-- Indenting options
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Backup options
vim.o.swapfile = false
vim.o.undofile = true

-- Other visual options
vim.o.scrolloff = 10
vim.o.relativenumber = true

-- Package managing

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  { src = gh('folke/tokyonight.nvim'), },
  { src = gh('neovim/nvim-lspconfig'), },
  { src = gh('alexghergh/nvim-tmux-navigation'), },
  { src = gh('nvim-mini/mini.nvim'), },
  {
    src = gh('nvim-treesitter/nvim-treesitter'),
    version = 'main',
  }
})

-- Colorscheme setup
vim.cmd.colorscheme('tokyonight-storm')

-- Tmux-nvim navigation setup
require('nvim-tmux-navigation').setup({
  disable_when_zoomed = true,
  keybindings = {
    left = '<C-h>',
    down = '<C-j>',
    up = '<C-k>',
    right = '<C-l>',
    last_active = '<C-\\>',
    next = '<C-Space>',
  },
})

-- LSPs
vim.lsp.enable('lua_ls')

-- Lua_ls settings for nvim configuring
--  NOTE: With these settings lua_ls works ONLY on nvim settings

-- lua language server is super confused when editing lua files in the config
-- and raises a lot of [duplicate-doc-field] warnings
local runtime_files = vim.api.nvim_get_runtime_file('', true)
for k, v in ipairs(runtime_files) do
  if v == '/home/adam/.config/nvim' then
    table.remove(runtime_files, k)
  end
end

---@type vim.lsp.Config
local lua_ls_config = {
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua' },
      },
      workspace = {
        checkThirdParty = false,
        library = runtime_files
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
}
vim.lsp.config('lua_ls', lua_ls_config)

------------------------- MINI.NVIM SETUPS ------------------------
-- TODO: mini.icons, mini.pick, vim.snippet/mini.snippets

-- Around/inside motions
require('mini.ai').setup()

-- Basic options and keymaps
require('mini.basics').setup({
  options = {
    extra_ui = true,
  },
  mappings = {
    windows = true,
  },
})

-- Autocompletion
require('mini.completion').setup()

-- Word under cursor highlighting
require('mini.cursorword').setup()

-- Git diff
require('mini.diff').setup()

-- Pattern highlighting
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    fixme     = { pattern = 'FIXME', group = 'MiniHipatternsFixme' },
    hack      = { pattern = 'HACK', group = 'MiniHipatternsHack' },
    todo      = { pattern = 'TODO', group = 'MiniHipatternsTodo' },
    note      = { pattern = 'NOTE', group = 'MiniHipatternsNote' },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  }
})

-- Indent lines NOTE: maybe remove?, too slow
require('mini.indentscope').setup()

-- Auto pairing of brackets, quotes, etc.
require('mini.pairs').setup()

-- Trailspace removal functions vis. autoformat
require('mini.trailspace').setup()
-- Disable trailspace highlight since they delete on write
vim.g.minitrailspace_disable = true

------------------------ KEYMAPS ------------------------

vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

------------------------ AUTOFORMAT SETUP ------------------------

local autoformat_group = vim.api.nvim_create_augroup('autoformat', { clear = true })

-- Remove trailspaces and empty last lines
vim.api.nvim_create_autocmd('BufWritePre', {
  group = autoformat_group,
  callback = function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
  end,
})

-- LSP format
vim.api.nvim_create_autocmd('LspAttach', {
  group = autoformat_group,
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

------------------------ TREESITTER SETUP ------------------------

-- Update parsers after treesitter update
local function treesitter_hook(ev)
  local name, kind = ev.data.spec.name, ev.data.kind

  if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
    if not ev.data.active then
      vim.cmd.packadd("nvim-treesitter")
    end

    vim.cmd("TSUpdate")
  end
end

vim.api.nvim_create_autocmd("PackChanged", { callback = treesitter_hook })

local treesitter = require('nvim-treesitter')
treesitter.install({
  'lua'
})
