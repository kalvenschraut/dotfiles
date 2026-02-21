return {
	"folke/noice.nvim",
	event = "VeryLazy",
	config = function()
		local noice = require('noice');
		noice.setup({
			-- REMOVE THIS once this issue is fixed: https://github.com/yioneko/vtsls/issues/159
			routes = {
				{
					filter = {
						event = "notify",
						find = "Request textDocument/inlayHint failed",
					},
					opts = { skip = true },
				}
			},
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
				hover = { silent = true }
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			views = {
				mini = {
					win_options = {
						winblend = 98,
					},
				},
			},
		})
		vim.keymap.set("n", "<leader>nl", function()
			noice.cmd("last")
		end)

		vim.keymap.set("n", "<leader>nh", function()
			noice.cmd("telescope")
		end)
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		{
			"rcarriga/nvim-notify",
			opts = function()
				local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
				local bg = normal and normal.bg
				-- nvim-notify requires an RGB hex value (or a hl group with bg) for transparency blending.
				local background = type(bg) == "number" and string.format("#%06x", bg) or "#000000"
				return {
					background_colour = background,
				}
			end,
		},
	}
}
