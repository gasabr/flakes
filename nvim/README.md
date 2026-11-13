# nvim

Personal Neovim configuration, packaged as a Nix flake (`flake.nix`). This file
collects handy shortcuts and commands. `<leader>` is the space key (default).

## Swift / SourceKit (Darwin)

On macOS, SourceKit must be the **Xcode toolchain binary**, not `xcrun` and not
nixpkgs. `nix develop` sets `DEVELOPER_DIR` to the store SDK, which makes
`/usr/bin/sourcekit-lsp` fail with `tool 'sourcekit-lsp' not found`.

This flake’s Darwin build calls that toolchain path directly and does not wrap
nixpkgs `sourcekit-lsp` onto PATH. Xcode apps still need `buildServer.json`
([xcode-build-server](https://github.com/SolaWing/xcode-build-server)).

## Diagnostics

| Keys          | Description                                                        |
| ------------- | ------------------------------------------------------------------ |
| `<leader>sd`  | Toggle diagnostics (inline text, signs, underlines) on/off globally |
| `]d` / `[d`   | Jump to next / previous diagnostic and show it in a float          |

## Git blame (IDEA-style)

| Command     | Description                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| `:GitBlame` | Toggle a scroll-synced left gutter showing the commit ref + author per line. |

Run `:GitBlame` once to open the blame panel on the left (it scrolls together
with your code, like the IntelliJ IDEA annotate view). Run `:GitBlame` again to
close it.

## Window resizing

Neovim's built-in window commands (prefix `<C-w>` = Ctrl+w):

| Keys            | Description                                  |
| --------------- | -------------------------------------------- |
| `<C-w> +`       | Increase height by one line                  |
| `<C-w> -`       | Decrease height by one line                  |
| `<C-w> >`       | Increase width by one column                 |
| `<C-w> <`       | Decrease width by one column                 |
| `<C-w> =`       | Equalize all window sizes                    |
| `<C-w> _`       | Maximize current window height               |
| `<C-w> |`       | Maximize current window width                |

Exact sizing via commands (prefix with a count, e.g. `:resize 20`):

| Command               | Description                          |
| --------------------- | ------------------------------------ |
| `:resize +N` / `-N`   | Grow/shrink current window height    |
| `:vertical resize +N` | Grow/shrink current window width     |
| `:resize N`           | Set current window height to N rows  |
| `:vertical resize N`  | Set current window width to N cols   |

Window movement/splits for reference:

| Keys                       | Description                     |
| -------------------------- | ------------------------------- |
| `<C-w> s` / `<C-w> v`      | Split horizontally / vertically |
| `<C-w> h/j/k/l`            | Move to the left/down/up/right window |
| `<C-w> q`                  | Close current window            |
