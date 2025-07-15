local typescriptConfig = {
	importModuleSpecifier = 'non-relative',
	importModuleSpecifierEnding = 'js',
	inlayHints = {
		parameterNames = {
			enabled = 'all',
		},
		parameterTypes = {
			enabled = true,
		},
		variableTypes = {
			enabled = true,
		},
		propertyDeclarationTypes = {
			enabled = true,
		},
		functionLikeReturnTypes = {
			enabled = true,
		},
	},
	format = {
		insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true
	},
	experimental = {
		-- useTsgo = true,
	},
}
local vueLanguageServerPath = vim.fn.expand('$MASON/packages')
	.. '/vue-language-server'
	.. '/node_modules/@vue/language-server';
return {
	on_init = function(_client, bufnr)
		vim.lsp.inlay_hint.enable(true, { bufnr })
		vim.keymap.set('n', '<leader>R', function()
			vim.cmd('LspRestart tsserver');
		end, {})
	end,
	settings = {
		typescript = typescriptConfig,
		javascript = typescriptConfig,
		vtsls = {
			tsserver = {
				globalPlugins = {
					{
						name = '@vue/typescript-plugin',
						location = vueLanguageServerPath,
						languages = { 'vue' },
						configNamespace = 'typescript',
					}
				},
			},
		},
	},
	filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}
