return {
	cmd = { 'oxlint', '--lsp' },
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
