# Neovim Config

A small and minimal Neovim setup.

## Supported Languages

Currently supported:

- `lua`

## Adding a Language

To add support for a new language, configure both of these parts:

1. Enable the language server (LSP).
2. Add the corresponding Tree-sitter parser.

## Dependencies

### Required Programs

Install these tools before using the config:

```bash
lua-language-server
tree-sitter-cli
```

### Required in PATH

Make sure these executables are available in your `PATH`:

```bash
lua-language-server
node
gcc
```
