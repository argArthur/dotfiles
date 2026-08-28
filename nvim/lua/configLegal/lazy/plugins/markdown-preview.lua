return {
    dir = vim.fn.stdpath("config") .. "/lua/configLegal/vendor/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    build = "cd app && npx --yes yarn install",
    init = function()
        if vim.fn.has("wsl") == 1 then
            function _G.open_markdown_preview(url)
                if vim.fn.executable("wslview") == 1 then
                    vim.fn.jobstart({ "wslview", url }, { detach = true })
                    return
                end

                if vim.fn.executable("cmd.exe") == 1 then
                    vim.fn.jobstart({ "cmd.exe", "/c", "start", "", url }, { detach = true })
                    return
                end

                if vim.fn.executable("powershell.exe") == 1 then
                    vim.fn.jobstart({
                        "powershell.exe",
                        "-NoProfile",
                        "-Command",
                        "Start-Process",
                        url,
                    }, { detach = true })
                    return
                end

                vim.fn.jobstart({ "xdg-open", url }, { detach = true })
            end

            vim.cmd([[
                function! OpenMarkdownPreview(url) abort
                    call v:lua.open_markdown_preview(a:url)
                endfunction
            ]])
            vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
        end

        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
        vim.g.mkdp_filetypes = { "markdown" }
        vim.g.mkdp_echo_preview_url = 1

        vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<Enter>', { desc = 'open MarkdownPreview' })
    end,
}
