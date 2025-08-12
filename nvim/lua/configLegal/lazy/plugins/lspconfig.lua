return {
    "neovim/nvim-lspconfig",
    event="UIEnter",

    dependencies = {
        --"stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "j-hui/fidget.nvim",
        "mfussenegger/nvim-jdtls",
    },

    config = function()
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
