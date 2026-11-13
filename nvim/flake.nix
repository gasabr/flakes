{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.symlinkJoin {
            name = "neovim";
            paths = [
              (pkgs.neovim.override {
                configure = {
                  customRC = ''
                    set number relativenumber expandtab tabstop=4 shiftwidth=4 scrolloff=7 shada+=! autoindent smartindent wildmenu showmatch incsearch hlsearch ignorecase smartcase termguicolors
                    syntax on
                    filetype plugin indent on
                    set termguicolors
                    colorscheme hybrid
                    autocmd FileType python setlocal foldmethod=indent foldlevel=99
                    autocmd FileType json,jsonc setlocal foldenable foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr() foldlevel=99 | lua pcall(vim.treesitter.start, 0, 'json')
                    autocmd FileType swift setlocal tabstop=4 shiftwidth=4
                    let g:airline_section_b = '%{FugitiveHead()}%{empty(get(g:, "gh_pr_status", "")) ? "" : " " . g:gh_pr_status}'
                    let g:airline_section_c = ""
                    let g:airline_section_x = '%t'
                    let g:airline_section_y = '%{tagbar#currenttag("%s", "", "f")}'
                    let g:airline_section_z = '%l:%c'
                    set background=dark
                    let g:airline_powerline_fonts = 0
                    let g:airline_theme = 'hybrid'
                    let g:NERDTreeWinSize = 44
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
                      let a:palette.normal.airline_x = s:mid
                      let a:palette.normal.airline_z = s:N
                      let s:I = ['#1d1f21', '#5f819d', 234, 67]
                      let a:palette.insert.airline_a = s:I
                      let a:palette.insert.airline_b = s:mid
                      let a:palette.insert.airline_c = s:dark
                      let a:palette.insert.airline_x = s:mid
                      let a:palette.insert.airline_z = s:I
                      let s:V = ['#1d1f21', '#85678f', 234, 96]
                      let a:palette.visual.airline_a = s:V
                      let a:palette.visual.airline_b = s:mid
                      let a:palette.visual.airline_c = s:dark
                      let a:palette.visual.airline_x = s:mid
                      let a:palette.visual.airline_z = s:V
                      let s:R = ['#1d1f21', '#a54242', 234, 131]
                      let a:palette.replace.airline_a = s:R
                      let a:palette.replace.airline_b = s:mid
                      let a:palette.replace.airline_c = s:dark
                      let a:palette.replace.airline_x = s:mid
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
                      vim.lsp.config.clangd = {} ; vim.lsp.enable("clangd")
                      vim.lsp.config.ruff = {} ; vim.lsp.enable("ruff")
                      -- Repos that ship TS 7 (@typescript/native) get its own LSP (`tsc --lsp`);
                      -- everything else keeps ts_ls.
                      local js_root_markers = { { "pnpm-lock.yaml", "package-lock.json", "yarn.lock", "bun.lock", "bun.lockb" }, ".git" }
                      local function ts7_root(bufnr)
                        local root = vim.fs.root(bufnr, js_root_markers)
                        if root and vim.uv.fs_stat(root .. "/node_modules/@typescript/native/bin/tsc") then return root end
                      end
                      vim.lsp.config.tsgo = {
                        cmd = function(dispatchers, config)
                          return vim.lsp.rpc.start({ "node", config.root_dir .. "/node_modules/@typescript/native/bin/tsc", "--lsp", "--stdio" }, dispatchers, { cwd = config.root_dir })
                        end,
                        root_dir = function(bufnr, on_dir) local root = ts7_root(bufnr) ; if root then on_dir(root) end end,
                      }
                      vim.lsp.enable("tsgo")
                      vim.lsp.config.ts_ls = {
                        root_dir = function(bufnr, on_dir)
                          if ts7_root(bufnr) then return end
                          on_dir(vim.fs.root(bufnr, js_root_markers) or vim.fn.getcwd())
                        end,
                      }
                      vim.lsp.enable("ts_ls")
                      -- Uses the project's own eslint + flat config.
                      vim.lsp.config.eslint = {} ; vim.lsp.enable("eslint")
                      vim.lsp.config('expert', {
                        cmd = { 'expert', '--stdio' },
                        root_markers = { 'mix.exs', '.git' },
                        filetypes = { 'elixir', 'eelixir', 'heex' },
                      }); vim.lsp.enable("expert")
                      vim.lsp.config.gopls = {} ; vim.lsp.enable("gopls")
                      vim.lsp.config('rust_analyzer', {
                        settings = { ["rust-analyzer"] = {
                          check = { command = "clippy" },
                          cargo = { allFeatures = true },
                        } },
                      }); vim.lsp.enable("rust_analyzer")
                      -- Darwin + nix develop: DEVELOPER_DIR points at the store
                      -- SDK, so `xcrun`/`/usr/bin/sourcekit-lsp` fail. Call the
                      -- Xcode toolchain binary directly.
                      vim.lsp.config.sourcekit = {
                        cmd = ${
                          if pkgs.stdenv.isDarwin
                          then ''{ "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp" }''
                          else ''{ "sourcekit-lsp" }''
                        },
                        filetypes = { "swift" },
                        capabilities = {
                          workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
                          textDocument = { diagnostic = { dynamicRegistration = true, relatedDocumentSupport = true } },
                        },
                      }
                      vim.lsp.enable("sourcekit")
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
                    -- JS/TS: project's prettier (node_modules/.bin, its config + plugins), only where a
                    -- prettier config exists; eslint --fix first when the eslint LSP is attached.
                    local ok_conform, conform = pcall(require, "conform")
                    if ok_conform then
                      local prettier_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "yaml", "markdown", "css", "scss", "html" }
                      local formatters_by_ft = {}
                      for _, ft in ipairs(prettier_fts) do formatters_by_ft[ft] = { "prettier" } end
                      conform.setup({ formatters_by_ft = formatters_by_ft, formatters = { prettier = { require_cwd = true } } })
                      vim.api.nvim_create_autocmd("BufWritePre", {
                        callback = function(ev)
                          if not formatters_by_ft[vim.bo[ev.buf].filetype] then return end
                          if #vim.lsp.get_clients({ bufnr = ev.buf, name = "eslint" }) > 0 then
                            vim.api.nvim_buf_call(ev.buf, function() vim.cmd("silent! LspEslintFixAll") end)
                          end
                          conform.format({ bufnr = ev.buf, timeout_ms = 5000 })
                        end,
                      })
                    end
                    local ok_pairs, autopairs = pcall(require, 'nvim-autopairs')
                    if ok_pairs then autopairs.setup({}) end
                    -- Live templates: type the key at line start, press <Tab>; <Tab>/<S-Tab> then jump between placeholders.
                    local js_templates = { ['if'] = 'if (''${1}) {\n\t''${0}\n}' }
                    local templates = { javascript = js_templates, typescript = js_templates, javascriptreact = js_templates, typescriptreact = js_templates }
                    local function expand_template(before_expand)
                      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                      local before = vim.api.nvim_get_current_line():sub(1, col)
                      local word = before:match('(%w+)$')
                      local body = word and (templates[vim.bo.filetype] or {})[word]
                      if not body or not before:sub(1, col - #word):match('^%s*$') then return false end
                      before_expand()
                      vim.api.nvim_buf_set_text(0, row - 1, col - #word, row - 1, col, {})
                      vim.api.nvim_win_set_cursor(0, { row, col - #word })
                      vim.snippet.expand(body)
                      return true
                    end
                    vim.api.nvim_create_autocmd("BufWritePre", {
                      pattern = "*.rs",
                      callback = function(ev) vim.lsp.buf.format({ bufnr = ev.buf, async = false, filter = function(c) return c.name == "rust_analyzer" end }) end,
                    })
                    local ok_cmp, cmp = pcall(require, 'cmp')
                    if ok_cmp then
                      cmp.setup({
                        sources = cmp.config.sources({ { name = 'nvim_lsp' } }, { { name = 'buffer' } }),
                        mapping = cmp.mapping.preset.insert({
                          ['<C-Space>'] = cmp.mapping.complete(), ['<CR>'] = cmp.mapping.confirm({ select = true }),
                          ['<Tab>'] = cmp.mapping(function(fallback)
                            if expand_template(function() cmp.close() end) then return end
                            if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1)
                            elseif cmp.visible() then cmp.select_next_item()
                            else fallback() end
                          end, { 'i', 's' }),
                          ['<S-Tab>'] = cmp.mapping(function(fallback)
                            if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1)
                            elseif cmp.visible() then cmp.select_prev_item()
                            else fallback() end
                          end, { 'i', 's' }),
                          ['<C-n>'] = cmp.mapping.select_next_item(), ['<C-p>'] = cmp.mapping.select_prev_item(), ['<C-e>'] = cmp.mapping.abort(),
                        }),
                      })
                    end
                    local ok_ts, ts = pcall(require, 'nvim-treesitter.configs')
                    if ok_ts then ts.setup({ highlight = { enable = true, additional_vim_regex_highlighting = { "heex", "eex", "leex" } } }) end
                    vim.api.nvim_create_autocmd("FileType", { pattern = { "heex", "eex", "leex" }, callback = function(args) pcall(vim.treesitter.start, args.buf) end })
                    vim.o.foldmethod = 'expr' ; vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' ; vim.o.foldlevelstart = 99 ; vim.o.foldtext = "" ; vim.opt.fillchars:append({ fold = ' ' })
                    -- IDEA-style sticky header: enclosing function/class lines pinned on top when scrolled past.
                    local ok_tsc, tsc = pcall(require, 'treesitter-context')
                    if ok_tsc then
                      local tsc_fts = { javascript = true, javascriptreact = true, typescript = true, typescriptreact = true }
                      tsc.setup({ max_lines = 3, trim_scope = 'outer', on_attach = function(buf) return tsc_fts[vim.bo[buf].filetype] or false end })
                    end
                    local ok_comment, comment = pcall(require, 'Comment') ; if ok_comment then comment.setup() end
                    local ok_gs, gitsigns = pcall(require, 'gitsigns')
                    if ok_gs then
                      gitsigns.setup()
                      -- ]c / [c: jump across uncommitted hunks (staged + unstaged); keep native behaviour in diff mode
                      vim.keymap.set('n', ']c', function()
                        if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gitsigns.nav_hunk('next', { target = 'all' }) end
                      end, { desc = "Next uncommitted change" })
                      vim.keymap.set('n', '[c', function()
                        if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gitsigns.nav_hunk('prev', { target = 'all' }) end
                      end, { desc = "Prev uncommitted change" })
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
                          path_display = { "filename_first", shorten = { len = 1, exclude = { -2, -1 } } },
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
                      -- Full path of the previewed file in a line under the picker; results show shortened dirs.
                      local path_win, path_buf
                      vim.api.nvim_create_autocmd('User', { pattern = 'TelescopePreviewerLoaded', callback = function(ev)
                        local name = ev.data and ev.data.bufname
                        if not name or name == "" then return end
                        local prompt_buf
                        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                          local b = vim.api.nvim_win_get_buf(w)
                          if vim.bo[b].filetype == 'TelescopePrompt' then prompt_buf = b ; break end
                        end
                        if not prompt_buf then return end
                        local layout = require('telescope.actions.state').get_current_picker(prompt_buf).layout
                        local top, left, right = 0, math.huge, 0
                        for _, part in ipairs({ layout.results, layout.preview, layout.prompt }) do
                          for _, w in ipairs({ part and part.winid, part and part.border and part.border.winid }) do
                            if w and vim.api.nvim_win_is_valid(w) then
                              local pos = vim.api.nvim_win_get_position(w)
                              top = math.max(top, pos[1] + vim.api.nvim_win_get_height(w))
                              left = math.min(left, pos[2]) ; right = math.max(right, pos[2] + vim.api.nvim_win_get_width(w))
                            end
                          end
                        end
                        if left == math.huge then return end
                        if not (path_buf and vim.api.nvim_buf_is_valid(path_buf)) then path_buf = vim.api.nvim_create_buf(false, true) end
                        vim.api.nvim_buf_set_lines(path_buf, 0, -1, false, { " " .. vim.fn.fnamemodify(name, ':.') })
                        local cfg = { relative = 'editor', row = top, col = left, width = right - left, height = 1, style = 'minimal', focusable = false, zindex = 200 }
                        if path_win and vim.api.nvim_win_is_valid(path_win) then
                          vim.api.nvim_win_set_config(path_win, cfg)
                        else
                          path_win = vim.api.nvim_open_win(path_buf, false, cfg)
                          vim.wo[path_win].winhl = 'Normal:TelescopeNormal'
                          vim.api.nvim_create_autocmd('BufWipeout', { buffer = prompt_buf, once = true, callback = function()
                            if path_win and vim.api.nvim_win_is_valid(path_win) then vim.api.nvim_win_close(path_win, true) end
                            path_win = nil
                          end })
                        end
                      end })
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
                    vim.keymap.set('n', '<space>f', function() if ok_conform then conform.format({ async = true, lsp_format = "fallback" }) else vim.lsp.buf.format { async = true } end end, opts)
                    vim.keymap.set('n', '<leader>1', ':NERDTreeToggle<CR>', { silent = true, desc = "Toggle NERDTree" })
                    vim.keymap.set('n', '<M-t>', ':NERDTreeFind<CR>', { silent = true, desc = "Find current file in NERDTree" })
                    vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', { silent = true, desc = "Find files" })
                    vim.keymap.set('n', '<leader>-', '<cmd>Telescope lsp_document_symbols<CR>', { silent = true, desc = "Structure view" })
                    vim.keymap.set('n', '<leader>fs', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>', { silent = true, desc = "Go to symbol in workspace" })
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
                    -- \nc: toggle folding away every whole-line comment (treesitter comment nodes, else 'commentstring' prefix).
                    -- Comment rows are collected once per changedtick; parser is fetched directly since nvim-treesitter no longer attaches one.
                    local _comment_rows = {}
                    local function comment_rows(buf)
                      local tick = vim.b[buf].changedtick
                      local c = _comment_rows[buf]
                      if c and c.tick == tick then return c.rows end
                      local rows
                      local parser = vim.treesitter.get_parser(buf, nil, { error = false })
                      if parser then
                        rows = {}
                        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                        local function walk(node)
                          if node:type():find('comment') then
                            local sr, sc, er, ec = node:range()
                            if lines[sr + 1]:sub(1, sc):match('^%s*$') and (lines[er + 1] or ""):sub(ec + 1):match('^%s*$') then
                              for r = sr + 1, (ec == 0 and er or er + 1) do rows[r] = true end
                            end
                            return
                          end
                          for child in node:iter_children() do if child:named() then walk(child) end end
                        end
                        for _, tree in ipairs(parser:parse()) do walk(tree:root()) end
                      end
                      _comment_rows[buf] = { tick = tick, rows = rows }
                      return rows
                    end
                    function _G.CommentFoldExpr(lnum)
                      local line = vim.fn.getline(lnum)
                      if not line:find('%S') then return '=' end
                      local rows = comment_rows(vim.api.nvim_get_current_buf())
                      if rows then return rows[lnum] and '1' or '0' end
                      local prefix = vim.trim((vim.bo.commentstring:match('^(.-)%%s') or ""))
                      return (prefix ~= "" and vim.startswith(vim.trim(line), prefix)) and '1' or '0'
                    end
                    -- Local scope only: a global foldminlines change makes treesitter refresh every cached buffer, incl. wiped ones.
                    local fold_opts = { 'foldmethod', 'foldexpr', 'foldlevel', 'foldminlines' }
                    local function set_fold_opts(vals)
                      for i, name in ipairs(fold_opts) do vim.api.nvim_set_option_value(name, vals[i], { scope = 'local' }) end
                    end
                    vim.keymap.set('n', '<leader>nc', function()
                      local saved = vim.w.comment_fold_saved
                      if saved then
                        set_fold_opts(saved)
                        vim.w.comment_fold_saved = nil
                      else
                        vim.w.comment_fold_saved = vim.tbl_map(function(name) return vim.api.nvim_get_option_value(name, { scope = 'local' }) end, fold_opts)
                        set_fold_opts({ 'expr', 'v:lua.CommentFoldExpr(v:lnum)', 0, 0 })
                      end
                      vim.cmd('normal! zX')
                    end, { silent = true, desc = "Toggle hiding comment lines" })
                    vim.keymap.set('n', '<leader>sd', function()
                      local on = not vim.diagnostic.is_enabled()
                      vim.diagnostic.enable(on)
                      vim.notify("Diagnostics " .. (on and "on" or "off"))
                    end, { silent = true, desc = "Toggle diagnostics" })
                    local saved_virtual_text
                    vim.keymap.set('n', '<leader>sv', function()
                      local vt = vim.diagnostic.config().virtual_text
                      if vt then
                        saved_virtual_text = vt
                        vim.diagnostic.config({ virtual_text = false })
                      else
                        vim.diagnostic.config({ virtual_text = saved_virtual_text or true })
                      end
                      vim.notify("Diagnostic messages " .. (vt and "off" or "on"))
                    end, { silent = true, desc = "Toggle diagnostic messages (keep signs)" })
                    vim.keymap.set('n', '<leader>sl', function()
                      local on = not vim.diagnostic.config().signs
                      vim.diagnostic.config({ signs = on, underline = on })
                      vim.notify("Diagnostic signs/underlines " .. (on and "on" or "off"))
                    end, { silent = true, desc = "Toggle diagnostic signs and underlines" })
                    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() ; vim.schedule(function() vim.diagnostic.open_float() end) end, opts)
                    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() ; vim.schedule(function() vim.diagnostic.open_float() end) end, opts)
                  EOF
                  '';
                  packages.myVimPackage.start = with pkgs.vimPlugins; [
                    vim-elixir vim-nix vim-hybrid vim-airline vim-airline-themes vim-fugitive tagbar nvim-lspconfig nvim-cmp cmp-nvim-lsp cmp-buffer nerdtree nvim-autopairs telescope-nvim plenary-nvim telescope-fzf-native-nvim comment-nvim hop-nvim gitsigns-nvim nvim-treesitter-context
                    nvim-nio conform-nvim
                    (nvim-treesitter.withPlugins (p: [ p.html p.xml p.css p.javascript p.typescript p.tsx p.python p.nix p.yaml p.dockerfile p.json p.toml p.sql p.elixir p.heex p.eex p.go p.gomod p.gosum p.swift p.rust ]))
                  ];
                };
              })
            ];
            buildInputs = [ pkgs.makeWrapper ];
            # Linux: ship nixpkgs sourcekit-lsp on PATH for SwiftPM projects.
            # Darwin: do not wrap — Apple's xcrun sourcekit-lsp must win (Xcode SDK).
            postBuild = pkgs.lib.optionalString (!pkgs.stdenv.isDarwin) ''
              wrapProgram $out/bin/nvim --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.sourcekit-lsp ]}
            '';
          };
        });
    };
}
