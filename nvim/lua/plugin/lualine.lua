return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	opts = function(_, opts)
		opts.theme = 'kanagawa-wave'
		opts.sections = opts.sections or {}
		opts.sections.lualine_c = { { 'filename', path = 1 } }
		opts.sections.lualine_b = { 'branch', 'diff' }
		opts.sections.lualine_x = {
			{
				'lsp_status',
				icon = '', -- f013
				symbols = {
					-- Standard unicode symbols to cycle through for LSP progress:
					spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
					-- Standard unicode symbol for when LSP is done:
					done = '✓',
					-- Delimiter inserted between LSP names:
					separator = ' ',
				},
				-- List of LSP names to ignore (e.g., `null-ls`):
				ignore_lsp = {

					'null-ls',
					'copilot'
				},
				-- Display the LSP name
				show_name = true,
			},
			{
				function()
					return " "
				end,
				color = function()
					local status = require("sidekick.status").get()
					if status then
						return status.kind == "Error" and "DiagnosticError" or status.busy and "DiagnosticWarn" or
							"Special"
					end
				end,
				cond = function()
					local status = require("sidekick.status")
					return status.get() ~= nil
				end,
			},
			{
				function()
					local status = require("sidekick.status").cli()
					return " " .. (#status > 1 and #status or "")
				end,
				cond = function()
					return #require("sidekick.status").cli() > 0
				end,
				color = function()
					return "Special"
				end,
			},
			'encoding',
			'fileformat',
			'filetype'
		}
	end,
}
