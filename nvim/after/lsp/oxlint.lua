-- Helper function to find workspace root with .oxlintrc.json from a given buffer path
local function find_workspace_root(buffer_path)
	local root = vim.fs.find('.oxlintrc.json', {
		path = buffer_path,
		upward = true,
		type = 'file'
	})[1]

	if root then
		return vim.fn.fnamemodify(root, ':h')
	end

	return nil
end

-- Helper function to find tsconfig.json relative to workspace root
local function find_tsconfig(buffer_path)
	local workspace_root = find_workspace_root(buffer_path)

	if not workspace_root then
		return nil
	end

	local tsconfig_path = workspace_root .. '/tsconfig.json'

	if vim.fn.filereadable(tsconfig_path) == 1 then
		return tsconfig_path
	end

	return nil
end

return {
	cmd = { 'oxc --lsp' },
	on_attach = function(client, bufnr)
		-- Get the buffer's file path
		local buffer_path = vim.api.nvim_buf_get_name(bufnr)

		-- Find tsconfig relative to this buffer's workspace root
		local tsconfig = find_tsconfig(buffer_path)

		if tsconfig then
			-- Update the client's settings with the found tsconfig
			client.config.settings.oxc_language_server = client.config.settings.oxc_language_server or {}
			client.config.settings.oxc_language_server.tsconfig = tsconfig

			-- Notify the language server of the updated settings
			client.notify('workspace/didChangeConfiguration', {
				settings = client.config.settings
			})
		end
	end,
	settings = {
		oxc_language_server = {
			-- see the below, anything under "options" object is to be passed in here
			-- https://github.com/oxc-project/oxc/blob/main/crates/oxc_language_server/README.md#workspace
			typeAware = true,
		}
	}
}
