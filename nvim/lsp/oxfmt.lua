local masonOxfmt = vim.fn.stdpath('data') .. '/mason/bin/oxfmt'
local cmd = vim.fn.executable(masonOxfmt) == 1
	and { masonOxfmt, '--lsp' }
	or { 'oxfmt', '--lsp' }

return {
	cmd = cmd,
	filetypes = {
		'javascript',
		'javascriptreact',
		'javascript.jsx',
		'typescript',
		'typescriptreact',
		'typescript.tsx',
		'vue',
		'json'
	},
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, { '.oxlintrc.json', 'package.json', '.git' })
		on_dir(root or vim.fn.getcwd())
	end,
}
