return {
	-- {{{ LSP Configurations
	{
		'neovim/nvim-lspconfig',
		cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
		},
		config = function()
			-- setup lsp manager/installer
			require('mason').setup({})
			require('mason-lspconfig').setup({
				ensure_installed = {
					'vue_ls',
					'copilot',
					'vtsls',
					'jsonls',
					'lua_ls',
					'bashls',
					'phpactor',
					'oxlint'
				}
			})

			local lspConfig = require('lspconfig')

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
						virtual_lines = {
							current_line = true,
						},
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
					if client:supports_method("textDocument/formatting") then
						buffer_autoformat(event.buf);
					end

					-- if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
					--  vim.lsp.inline_completion.enable(true);
					-- end
				end,
			})

			vim.lsp.enable({ 'vue_ls', 'vtsls', 'lua_ls', 'bashls', 'jsonls', 'phpactor', 'copilot', 'oxlint' });
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
