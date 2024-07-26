return {
	'nvim-telescope/telescope.nvim',
	version = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'BurntSushi/ripgrep'
	},
	config = function()
		local telescope = require('telescope')

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
		vim.keymap.set('n', '<C-p>', builtin.git_files, {})
		vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>pw', builtin.grep_string, {})
		vim.keymap.set('n', '<leader>ps', function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") });
		end)


		local actions = require('telescope.actions');
		telescope.load_extension("noice");
		telescope.setup({
			defaults = {
				mappings = {
					i = {
						['<C-j>'] = 'move_selection_next',
						['<C-k>'] = 'move_selection_previous',
						['<C-o>'] = function(prompt_buffer)
							vim.cmd('cexpr []');
							actions.send_to_qflist(prompt_buffer);
							vim.cmd([[
						if !empty(getqflist())
							let s:prev_val = ""
							for d in getqflist()
								let s:curr_val = bufname(d.bufnr)
								if (s:curr_val != s:prev_val)
									exec "edit " . s:curr_val
								endif
								let s:prev_val = s:curr_val
							endfor
						endif
					]])
						end
					}
				}
			}
		})
	end
}
