return {
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr,
			{ 'oxlint.config.ts', '.oxlintrc.json', '.oxlintrc.jsonc', 'package.json', '.git' })
		on_dir(root or vim.fn.getcwd())
	end,
	cmd = function(dispatchers, config)
		return vim.lsp.rpc.start({ 'pnpm', 'exec', 'oxlint', '--lsp' }, dispatchers, {
			cwd = config.root_dir
		})
	end
}
