return {
	-- {{{ Autocompletion
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			'onsails/lspkind.nvim',
			'L3MON4D3/LuaSnip',
			{
				"zbirenbaum/copilot-cmp",
				autostart = false,
				dependencies = {
					"zbirenbaum/copilot.lua",
					config = function()
						require("copilot").setup()
					end
				},
				config = function()
					require("copilot_cmp").setup()
				end,
			}
		},
		config = function()
			local cmp = require('cmp')

			local lspkind = require('lspkind')
			lspkind.init({
				symbol_map = {
					Copilot = "",
				},
			})
			vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

			vim.g.copilot_no_tab_map = true;
			vim.g.copilot_assume_mapped = true;

			-- check if in start tag for vue components
			local function is_in_start_tag()
				local ts_utils = require('nvim-treesitter.ts_utils')
				local node = ts_utils.get_node_at_cursor()
				if not node then
					return false
				end
				local node_to_check = { 'start_tag', 'self_closing_tag', 'directive_attribute' }
				return vim.tbl_contains(node_to_check, node:type())
			end

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					['<C-y>'] = cmp.mapping.confirm({ select = true }),
					['<CR>'] = cmp.mapping.confirm({ select = false }),
					['<C-Space>'] = cmp.mapping.complete(),
					['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
				}),
				sources = cmp.config.sources({
					{ name = "copilot", group_index = 2 },
					{
						name = 'nvim_lsp',
						---@param entry cmp.Entry
						---@param ctx cmp.Context
						entry_filter = function(entry, ctx)
							if ctx.filetype ~= 'vue' then
								return true
							end
							-- Use a buffer-local variable to cache the result of the Treesitter check
							local bufnr = ctx.bufnr
							local cached_is_in_start_tag = vim.b[bufnr]._vue_ts_cached_is_in_start_tag
							if cached_is_in_start_tag == nil then
								vim.b[bufnr]._vue_ts_cached_is_in_start_tag = is_in_start_tag()
							end
							-- If not in start tag, return true
							if vim.b[bufnr]._vue_ts_cached_is_in_start_tag == false then
								return true
							end
							local cursor_before_line = ctx.cursor_before_line
							-- For events
							if cursor_before_line:sub(-1) == '@' then
								return entry.completion_item.label:match('^@')
								-- For props also exclude events with `:on-` prefix
							elseif cursor_before_line:sub(-1) == ':' then
								return entry.completion_item.label:match('^:') and
									not entry.completion_item.label:match('^:on%-')
							else
								return true
							end
						end,
						group_index = 2
					},
					{ name = "path",    group_index = 2 },
					{ name = "luasnip", group_index = 2 },
				}),
				formatting = {
					format = lspkind.cmp_format({
						maxwidth = 100, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
					})
				},
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			});
			cmp.event:on('menu_closed', function()
				local bufnr = vim.api.nvim_get_current_buf()
				vim.b[bufnr]._vue_ts_cached_is_in_start_tag = nil
			end)
		end
	},
	--- }}}
	-- {{{ LSP Configurations
	{
		'neovim/nvim-lspconfig',
		cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'hrsh7th/cmp-nvim-lsp'
		},
		config = function()
			-- setup lsp manager/installer
			require('mason').setup({})
			require('mason-lspconfig').setup({
				ensure_installed = {
					'vue_ls',
					'vtsls',
					'jsonls',
					'lua_ls',
					'bashls'
				}
			})

			local lspConfig = require('lspconfig')
			-- Add cmp_nvim_lsp capabilities settings to lspconfig
			-- This should be executed before you configure any language server
			lspConfig.util.default_config.capabilities = vim.tbl_deep_extend(
				'force',
				lspConfig.util.default_config.capabilities,
				require('cmp_nvim_lsp').default_capabilities()
			)

			-- LspAttach is where you enable features that only work
			-- if there is a language server active in the file
			vim.api.nvim_create_autocmd('LspAttach', {
				desc = 'LSP actions',
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set('n', 'K', vim.lsp.buf.hover,
						{ buffer = event.buf, desc = 'Show type information on currently hovered text' })
					vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
						{ buffer = event.buf, desc = 'Go to definition on currently hovered text' })
					vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition,
						{ buffer = event.buf, desc = 'Go to type definition on currently hovered text' })
					vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
					vim.keymap.set('n', 'gr', vim.lsp.buf.references,
						{ buffer = event.buf, desc = 'Show what is using the currently hovered text' })
					vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
					vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
					vim.keymap.set({ 'n', 'x' }, '<F3>', function()
						vim.lsp.buf.format({ async = true })
					end, opts)
					vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action,
						{ buffer = event.buf, desc = 'Show code actions for the currently hovered text' })
					vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
					vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float,
						{ buffer = event.buf, desc = 'Show diagnostics for the currently hovered text' })
					vim.keymap.set('n', '[d', vim.diagnostic.goto_next,
						{ buffer = event.buf, desc = 'Go to next diagnostic' })
					vim.keymap.set('n', ']d', vim.diagnostic.goto_prev,
						{ buffer = event.buf, desc = 'Go to previous diagnostic' })
					vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action,
						{ buffer = event.buf, desc = 'Show code actions for the currently hovered text' })
					vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
					vim.keymap.set('n', '<leader>lf', '<cmd>LspEslintFixAll<CR>',
						{ buffer = event.buf, desc = 'Run eslint fix on current file' })
					vim.keymap.set("n", '<leader>i', function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
							{ bufnr = event.buf })
					end, { buffer = event.buf, desc = 'Toggle inlay hints' })
					vim.diagnostic.config({
						virtual_lines = true
					})

					-- setup formatting cmds
					local id = vim.tbl_get(event, 'data', 'client_id')
					local client = id and vim.lsp.get_client_by_id(id)
					if client == nil then
						return
					end
					local allowedFormatters = {
						lua_ls = true,
						['null-ls'] = true,
						['rust-analyzer'] = true
					}
					local lspFormatting = function()
						vim.lsp.buf.format({
							filter = function(currentClient)
								return allowedFormatters[currentClient.name]
							end,
							async = false,
							timeout_ms = 10000
						})
					end

					local buffer_autoformat = function(bufnr)
						local group = 'lsp_autoformat'
						vim.api.nvim_create_augroup(group, { clear = false })
						vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

						vim.api.nvim_create_autocmd('BufWritePre', {
							buffer = bufnr,
							group = group,
							desc = 'LSP format on save',
							callback = lspFormatting
						})
					end

					vim.keymap.set('n', '<leader>f', lspFormatting,
						{ buffer = event.buf, desc = 'Format current buffer' })
					if client.supports_method("textDocument/formatting") then
						buffer_autoformat(event.buf);
					end
				end,
			})

			vim.lsp.enable({ 'vue_ls', 'vtsls', 'lua_ls', 'bashls', 'jsonls' });
		end
	},
	-- }}}
	-- {{{ Formatters and Linters
	{
		'nvimtools/none-ls.nvim',
		dependencies = {
			{
				'davidmh/cspell.nvim',
				dependencies = {
					'nvim-lua/plenary.nvim'
				}
			}
		},
		config = function()
			local cSpell = require('cspell')
			local cSpellConfig = {
				find_json = function(cwd)
					return os.getenv("HOME") .. '/.spellings.json'
				end,
			}

			local nullLs = require('null-ls')
			nullLs.setup({
				sources = {
					nullLs.builtins.formatting.prettierd,
					nullLs.builtins.formatting.terraform_fmt,
					nullLs.builtins.formatting.shfmt.with({
						filetypes = { 'sh', 'bash' }
					}),
					cSpell.diagnostics.with({
						config = cSpellConfig,
						diagnostics_postprocess = function(diagnostic)
							diagnostic.severity = diagnostic.message:find("really") and
								vim.diagnostic.severity["ERROR"]
								or vim.diagnostic.severity["WARN"]
						end,
					}),
					cSpell.code_actions.with({ config = cSpellConfig }),
				}
			})
		end
	},
	-- }}}
	-- {{{ Rust specific LSP setup
	-- this rust plugin is more than just LSP so add it separately than the normal lsp setup
	{
		'mrcjkb/rustaceanvim',
		version = '^5', -- Recommended
		ft = { 'rust' },
		lazy = false,
		config = function()
			local target = nil;
			if string.find(vim.loop.cwd(), 'windows') then
				target = 'x86_64-pc-windows-gnu';
			end
			vim.g.rustaceanvim = {
				server = {
					settings = {
						['rust-analyzer'] = {
							cargo = {
								target = target,
							}
						}
					},
					on_attach = function(client, bufnr)
						vim.fn.setenv('RUSTFLAGS', "-C target-feature=-crt-static");

						vim.keymap.set('n', '<leader>r', function()
							vim.cmd.RustLsp('runnables');
						end)
						vim.keymap.set('n', '<leader>rr', function()
							vim.cmd.RustLsp({ 'runnables', bang = true });
						end)
						vim.keymap.set('n', '<leader>rd', function()
							vim.cmd.RustLsp({ 'debuggables', bang = true });
						end)
						vim.keymap.set('n', '<leader>rt', function()
							vim.cmd.RustLsp('testables');
						end)
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
				},
			}
		end,
	}
	-- }}}
}
