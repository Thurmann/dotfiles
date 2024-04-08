-- Load LazyVim
require("config.lazy")

-- Language Server Protocol setup
local lspconfig = require("lspconfig")

-- Kotlin LSP configuration
local on_attach = function(client, bufnr)
    require("lsp_signature").on_attach() -- Optional: Attach lsp_signature for function signature help
end

lspconfig.kotlin_language_server.setup({
    on_attach = on_attach,
    capabilities = vim.lsp.protocol.make_client_capabilities(), -- Use built-in capabilities
})

-- Configure your other plugins and settings below...
