# nvim/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.neovim.override {
            configure = {
              customRC = ''
                set number relativenumber expandtab tabstop=4 shiftwidth=4 scrolloff=7 shada+=! autoindent smartindent wildmenu showmatch incsearch hlsearch ignorecase smartcase termguicolors
                syntax on
                filetype plugin indent on
                set termguicolors
                colorscheme hybrid
                autocmd FileType python setlocal foldmethod=indent foldlevel=99
                autocmd FileType typescript,typescriptreact,javascript,javascriptreact setlocal tabstop=2 shiftwidth=2
                let g:airline_section_b = '%{FugitiveHead()}%{empty(get(g:, "gh_pr_status", "")) ? "" : " " . g:gh_pr_status}'
                let g:airline_section_c = ""
                let g:airline_section_y = '%{tagbar#currenttag("%s", "", "f")}'
                let g:airline_section_z = '%l:%c'
                set background=dark
                let g:airline_powerline_fonts = 0
                let g:airline_theme = 'hybrid'
                let g:airline_highlighting_cache = 1
                let g:airline_left_sep = ""
                let g:airline_left_alt_sep = ""
                let g:airline_right_sep = ""
                let g:airline_right_alt_sep = ""
                if !exists("g:airline_symbols") | let g:airline_symbols = {} | endif
                let g:airline_symbols.branch = ""
                let g:airline_symbols.readonly = ""
                let g:airline_symbols.linenr = ""
                let g:airline_symbols.maxlinenr = ""
                let g:airline_symbols.colnr = ":"
                let g:airline#extensions#whitespace#enabled = 0
                let g:airline#extensions#nvimlsp#enabled = 0
                let g:airline_theme_patch_func = 'AirlineThemePatch'
                function! AirlineThemePatch(palette)
                  let s:mid  = ['#969896', '#282a2e', 245, 235]
                  let s:dark = ['#707880', '#1d1f21', 243, 234]
                  let s:N = ['#c5c8c6', '#373b41', 250, 237]
                  let a:palette.normal.airline_a = s:N
                  let a:palette.normal.airline_b = s:mid
                  let a:palette.normal.airline_c = s:dark
                  let a:palette.normal.airline_z = s:N
                  let s:I = ['#1d1f21', '#5f819d', 234, 67]
                  let a:palette.insert.airline_a = s:I
                  let a:palette.insert.airline_b = s:mid
                  let a:palette.insert.airline_c = s:dark
                  let a:palette.insert.airline_z = s:I
                  let s:V = ['#1d1f21', '#85678f', 234, 96]
                  let a:palette.visual.airline_a = s:V
                  let a:palette.visual.airline_b = s:mid
                  let a:palette.visual.airline_c = s:dark
                  let a:palette.visual.airline_z = s:V
                  let s:R = ['#1d1f21', '#a54242', 234, 131]
                  let a:palette.replace.airline_a = s:R
                  let a:palette.replace.airline_b = s:mid
                  let a:palette.replace.airline_c = s:dark
                  let a:palette.replace.airline_z = s:R
                endfunction
                nmap <F12> :TagbarToggle<CR>
                let g:tagbar_autofocus = 1
                let g:tagbar_sort = 0
                let g:tagbar_compact = 1
                lua << EOF
                vim.filetype.add({ extension = { Dockerfile = "dockerfile", Containerfile = "dockerfile", heex = "heex", eex = "eex", leex = "leex" } })
                vim.diagnostic.config({
                  float = { border = "rounded", source = "always", focusable = true },
                  virtual_text = {
                    prefix = '■', spacing = 4,
                    format = function(d)
                      local m = d.message
                      local w = vim.api.nvim_win_get_width(0)
                      return #m > w - 20 and (vim.fn.strcharpart(m, 0, w - 23) .. "...") or m
                    end,
                  },
                  signs = true, underline = true, update_in_insert = false, severity_sort = true,
                })
                local venv_path = vim.fn.getcwd() .. '/.venv'
                if vim.fn.isdirectory(venv_path) == 1 then
                  vim.env.VIRTUAL_ENV = venv_path
                  vim.env.PATH = venv_path .. '/bin:' .. vim.env.PATH
                end
                local ok_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
                if ok_cmp_lsp then vim.lsp.config('*', { capabilities = cmp_lsp.default_capabilities() }) end
                local ok_lsp, _ = pcall(require, 'lspconfig')
                if ok_lsp then
                  vim.lsp.config.pyright = {} ; vim.lsp.enable("pyright")
                  vim.lsp.config.ruff = {} ; vim.lsp.enable("ruff")
                  vim.lsp.config.ts_ls = {} ; vim.lsp.enable("ts_ls")
                  vim.lsp.config.elixirls = { cmd = { "elixir-ls" } } ; vim.lsp.enable("elixirls")
                  vim.lsp.config.gopls = {} ; vim.lsp.enable("gopls")
                end
                vim.api.nvim_create_autocmd("BufWritePre", {
                  pattern = "*.py",
                  callback = function(ev)
                    local params = vim.lsp.util.make_range_params()
                    params.context = { only = { "source.organizeImports" }, diagnostics = {} }
                    local result = vim.lsp.buf_request_sync(ev.buf, "textDocument/codeAction", params, 3000)
                    for cid, res in pairs(result or {}) do
                      for _, r in pairs(res.result or {}) do
                        if r.edit then
                          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                          vim.lsp.util.apply_workspace_edit(r.edit, enc)
                        end
                      end
                    end
                    vim.lsp.buf.format({ bufnr = ev.buf, async = false, filter = function(c) return c.name == "ruff" end })
                  end,
                })
                local ok_cmp, cmp = pcall(require, 'cmp')
                if ok_cmp then
                  cmp.setup({
                    sources = cmp.config.sources({ { name = 'nvim_lsp' } }, { { name = 'buffer' } }),
                    mapping = cmp.mapping.preset.insert({
                      ['<C-Space>'] = cmp.mapping.complete(), ['<CR>'] = cmp.mapping.confirm({ select = true }),
                      ['<Tab>'] = cmp.mapping.select_next_item(), ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                      ['<C-n>'] = cmp.mapping.select_next_item(), ['<C-p>'] = cmp.mapping.select_prev_item(), ['<C-e>'] = cmp.mapping.abort(),
                    }),
                  })
                end
                local ok_ts, ts = pcall(require, 'nvim-treesitter.configs')
                if ok_ts then ts.setup({ highlight = { enable = true, additional_vim_regex_highlighting = { "heex", "eex", "leex" } } }) end
                vim.api.nvim_create_autocmd("FileType", { pattern = { "heex", "eex", "leex" }, callback = function(args) pcall(vim.treesitter.start, args.buf) end })
                vim.o.foldmethod = 'expr' ; vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' ; vim.o.foldlevelstart = 99 ; vim.o.foldtext = ""
                local ok_comment, comment = pcall(require, 'Comment') ; if ok_comment then comment.setup() end
                local ok_gs, gitsigns = pcall(require, 'gitsigns')
                if ok_gs then
                  gitsigns.setup()
                  vim.api.nvim_create_user_command('GitBlame', function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'gitsigns-blame' then
                        vim.api.nvim_win_close(win, true) ; return
                      end
                    end
                    gitsigns.blame()
                  end, { desc = "Toggle IDEA-style git blame gutter (commit + author on the left)" })
                end
                local ok_hop, hop = pcall(require, 'hop')
                if ok_hop then
                  hop.setup({ keys = 'etovxqpdygfblzhckisuran' })
                  vim.keymap.set('n', '<leader>;', function() hop.hint_char1() end, { desc = "Hop to char" })
                end
                local ok_tel, telescope = pcall(require, 'telescope')
                if ok_tel then
                  local actions = require('telescope.actions')
                  telescope.setup({
                    defaults = {
                      layout_strategy = 'horizontal', layout_config = { prompt_position = 'top', preview_width = 0.5, width = 0.85, height = 0.8 },
                      sorting_strategy = 'ascending', file_ignore_patterns = { "^%.git/", "node_modules/", "%.venv/", "__pycache__/", "%.pytest_cache/", "_build/", "deps/" },
                      mappings = { i = { ["<C-n>"] = actions.move_selection_next, ["<C-p>"] = actions.move_selection_previous, ["<Esc>"] = actions.close } },
                    },
                    pickers = {
                      find_files = { hidden = true },
                      lsp_document_symbols = {
                        entry_maker = (function()
                          local make_entry = require('telescope.make_entry')
                          return function(entry)
                            local base = make_entry.gen_from_lsp_symbols({})(entry)
                            if not base then return nil end
                            base.display = function(e)
                              local name = e.symbol_name or ""
                              local kind = (e.symbol_type or ""):lower()
                              local width = vim.o.columns
                              for _, win in ipairs(vim.api.nvim_list_wins()) do
                                if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "TelescopeResults" then
                                  width = vim.api.nvim_win_get_width(win) - 4
                                  break
                                end
                              end
                              local pad = math.max(1, width - #name - #kind)
                              return name .. string.rep(" ", pad) .. kind,
                                { { { #name + pad, #name + pad + #kind }, "Comment" } }
                            end
                            return base
                          end
                        end)(),
                      },
                    },
                  })
                  pcall(telescope.load_extension, 'fzf')
                end
                vim.g.gh_pr_status = ""
                local _gh_pr_cache = {}
                local function _refresh_gh_pr()
                  local branch = vim.fn.FugitiveHead()
                  if branch == "" then vim.g.gh_pr_status = "" ; return end
                  if _gh_pr_cache[branch] ~= nil then vim.g.gh_pr_status = _gh_pr_cache[branch] ; return end
                  _gh_pr_cache[branch] = ""
                  vim.fn.jobstart("gh pr view --json number --jq '.number' 2>/dev/null", {
                    stdout_buffered = true,
                    on_stdout = function(_, data)
                      if data and data[1] and data[1] ~= "" then
                        local num = data[1]:match("^%s*(%d+)%s*$")
                        if num then _gh_pr_cache[branch] = "#" .. num ; vim.g.gh_pr_status = _gh_pr_cache[branch] end
                      end
                    end,
                  })
                end
                vim.api.nvim_create_autocmd("BufEnter", { callback = _refresh_gh_pr })
                vim.api.nvim_create_autocmd("FocusGained", { callback = function()
                  local b = vim.fn.FugitiveHead() ; if b ~= "" then _gh_pr_cache[b] = nil end ; _refresh_gh_pr()
                end })
                local opts = { noremap=true, silent=true }
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
                vim.keymap.set('n', '<leader>1', ':NERDTreeToggle<CR>', { silent = true, desc = "Toggle NERDTree" })
                vim.keymap.set('n', '<M-t>', ':NERDTreeFind<CR>', { silent = true, desc = "Find current file in NERDTree" })
                vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', { silent = true, desc = "Find files" })
                vim.keymap.set('n', '<leader>-', '<cmd>Telescope lsp_document_symbols<CR>', { silent = true, desc = "Structure view" })
                vim.keymap.set('n', '<leader>gs', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>', { silent = true, desc = "Go to symbol in workspace" })
                vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { silent = true, desc = "Live grep" })
                vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { silent = true, desc = "Buffers" })
                vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { silent = true, desc = "Help tags" })
                vim.keymap.set('n', '<leader>fo', '<cmd>Telescope oldfiles<CR>', { silent = true, desc = "Recent files" })
                vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', { silent = true, desc = "Grep word under cursor" })
                vim.keymap.set('v', '<leader>fw', function()
                  vim.cmd('noau normal! "vy"')
                  require('telescope.builtin').grep_string({ search = vim.fn.getreg('v') })
                end, { silent = true, desc = "Grep selection" })
                vim.keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>', { silent = true, desc = "Diagnostics" })
                vim.keymap.set('n', '<leader>fc', '<cmd>Telescope git_commits<CR>', { silent = true, desc = "Git commits" })
                vim.keymap.set('n', '<leader>ft', '<cmd>Telescope git_status<CR>', { silent = true, desc = "Git status" })
                vim.keymap.set('n', '<leader>fm', '<cmd>Telescope marks<CR>', { silent = true, desc = "Show marks" })
                vim.keymap.set('n', '<leader>gP', function()
                  local b = vim.fn.FugitiveHead() ; if b ~= "" then _gh_pr_cache[b] = nil end
                  _refresh_gh_pr() ; vim.fn.jobstart("gh pr view --web 2>/dev/null")
                end, { silent = true, desc = "Open PR in browser" })
                vim.keymap.set('n', '<D-/>', 'gcc', { remap = true }) ; vim.keymap.set('v', '<D-/>', 'gc', { remap = true })
                vim.keymap.set('n', '<C-/>', 'gcc', { remap = true }) ; vim.keymap.set('v', '<C-/>', 'gc', { remap = true })
                vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() ; vim.schedule(function() vim.diagnostic.open_float() end) end, opts)
                vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() ; vim.schedule(function() vim.diagnostic.open_float() end) end, opts)
EOF
              '';
              packages.myVimPackage.start = with pkgs.vimPlugins; [
                vim-elixir vim-nix vim-hybrid vim-airline vim-airline-themes vim-fugitive tagbar nvim-lspconfig nvim-cmp cmp-nvim-lsp cmp-buffer nerdtree telescope-nvim plenary-nvim telescope-fzf-native-nvim comment-nvim hop-nvim gitsigns-nvim
                (nvim-treesitter.withPlugins (p: [ p.html p.css p.javascript p.typescript p.tsx p.python p.nix p.yaml p.dockerfile p.json p.toml p.sql p.elixir p.heex p.eex p.go p.gomod p.gosum ]))
              ];
            };
          };
        });
    };
}
