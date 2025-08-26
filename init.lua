require('config.options')
require('config.keybinds')
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})


vim.api.nvim_set_keymap('n', '<Up>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Down>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Left>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Right>', '<Nop>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<Up>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<Down>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<Left>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<Right>', '<Nop>', { noremap = true, silent = true })


-- LSP config
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "clangd", "pyright", "ts_ls" }, -- choose what you need
})

local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
local servers = { "lua_ls", "pyright", "ts_ls" }

-- Completion config
-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
		{ name = "path" },
	}),
})



-- Function that runs when LSP attaches to a buffer
local on_attach = function(_, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	-- Hover info
	vim.keymap.set("n", "m", vim.lsp.buf.hover, opts)
	-- Go to definition
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	-- Go to references
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	-- Go to implementation
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	-- Show signature help
	vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
	-- Show diagnostics (errors, warnings, info)
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
	-- Jump to next diagnostic
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	-- Jump to previous diagnostic
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	-- Show all diagnostics in a list
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
end


for _, server in ipairs(servers) do
	lspconfig[server].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

-- Set up clangd separately with query-driver
lspconfig.clangd.setup {
	cmd = {
		"clangd",
		"--header-insertion=never",
		"--query-driver=C:/Users/Asus/scoop/apps/gcc/current/bin/*",
		"--extra-arg=-isystemC:/Users/Asus/scoop/apps/gcc/current/include",
		"--extra-arg=-isystemC:/Users/Asus/scoop/apps/gcc/current/lib/gcc/x86_64-w64-mingw32/13.2.0/include",
		"--extra-arg=-isystemC:/Users/Asus/scoop/apps/gcc/current/x86_64-w64-mingw32/include"
	},


	on_attach = on_attach,
	capabilities = capabilities,
}

-- vim.diagnostic.disable()


-- Autoformat on save
vim.api.nvim_create_augroup("AutoFormatting", {})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = "AutoFormatting",
	callback = function()
		vim.lsp.buf.format({ async = false }) -- sync format before save
	end,
})

-- Tab spacing
vim.opt.tabstop = 4    -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4 -- Number of spaces used for autoindent
