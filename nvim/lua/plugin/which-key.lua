return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ loop = true })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
