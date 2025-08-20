function applyColor(color)
    vim.cmd.colorscheme(color)
end

return {{
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
        require('rose-pine').setup({
            variant = 'moon',
            disable_background = true,
            styles = {
                italic = false,
                transparency = true,
            },
        })

        applyColor("rose-pine-moon")
    end
}}
