return {
	cmd = { 'oxlint', '--lsp', '-A', 'no-console' },
	filetypes = {
		'javascript',
		'javascriptreact',
		'javascript.jsx',
		'typescript',
		'typescriptreact',
		'typescript.tsx',
		'vue',
	},
	settings = {
		oxc_language_server = {
			typeAware = true
		},
	}
}
