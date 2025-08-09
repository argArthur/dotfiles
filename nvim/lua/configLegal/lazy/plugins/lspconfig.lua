return {
    "neovim/nvim-lspconfig",
    event="UIEnter",

    dependencies = {
        --"stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        "mfussenegger/nvim-jdtls",
    },

    config = function()
        local cmp = require("cmp")

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-o>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                -- { name = "copilot", group_index = 2 },
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        require("fidget").setup({})

        vim.lsp.config("clangd", {
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=bundled",
                "--cross-file-rename",
                "--header-insertion=iwyu",
                "--compile-commands-dir=~/",
            },
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }
                    }
                }
            }
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()

                require('jdtls').start_or_attach({
                    cmd = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/jdtls/bin/jdtls" },
                    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),

                    init_options = {
                        settings = {
                            java = { imports = { gradle = { wrapper = { checksums = { {
                                sha256 = "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172",
                                allowed = true,
                            } } } } } }
                        }
                    },

                    capabilities = capabilities
                })

            end
        })

        require("mason").setup()

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "clangd",
                "jdtls",
                "csharp_ls",
                "rust_analyzer",
            },
        })

        vim.diagnostic.config({
            -- virtual_text = true,
            update_in_inset = true,
            severity_sort = true,
            underline = false,
            signs = false,

            float = { focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
