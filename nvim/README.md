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
| `<leader>sv`  | Toggle inline diagnostic messages; signs (W/H) and underlines stay |
| `<leader>sl`  | Toggle diagnostic signs (W/H letters) and underlines               |
| `]d` / `[d`   | Jump to next / previous diagnostic and show it in a float          |

## Git blame (IDEA-style)

| Command     | Description                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| `:GitBlame` | Toggle a scroll-synced left gutter showing the commit ref + author per line. |

Run `:GitBlame` once to open the blame panel on the left (it scrolls together
with your code, like the IntelliJ IDEA annotate view). Run `:GitBlame` again to
close it.

## Branch review

Review mode makes gitsigns compare every buffer against the branch's
merge-base with a ref (default `origin/HEAD`, else `main`/`master`). Signs,
`]c` / `[c` and hunk previews then cover everything the branch changed,
uncommitted work included, while you edit the real files with LSP. The
statusline shows `review:<ref>` while it is on.

| Command / Keys            | Description                                                              |
| ------------------------- | ------------------------------------------------------------------------ |
| `:Review [ref]`           | Start review vs merge-base with `ref` (tab-completes branches)           |
| `:Review off`             | Back to normal (uncommitted-only) signs                                  |
| `<leader>rr`              | Toggle review mode vs the default branch                                 |
| `<leader>rf`              | Telescope: files changed in the branch (status + diff preview); opens at first hunk, deleted files open the old version |
| `]c` / `[c`               | Next / previous change                                                   |
| `<leader>rp`              | Show the previous version of the hunk inline                             |
| `<leader>rd`              | Toggle a left split with the previous version of the file (diff mode)    |
| `<leader>rt`              | Toggle diffview: file tree + side-by-side; right side is the real file (`--imply-local`), so LSP works. `q` closes |
| `<leader>rh`              | Diffview history of the current file                                     |
| `:ReviewWorktree <x>`     | Check out branch/commit `x` (or PR number `123`) into a sibling `<repo>-review-<x>` worktree, open it in a new tab and start review |

Note: the review base is global to gitsigns, so it applies to all tabs. Remove
review worktrees with `git worktree remove <dir>`.

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
