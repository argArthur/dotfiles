return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- event = "LspAttach",
    priority = 1000,
    config = function()
        require('tiny-inline-diagnostic').setup({
            preset = "ghost",
            transparent_bg = true,
            hi = {
                background = "#000000",
            },
            options = {
                add_messages = false,
                multilines = true,
            },
        })
    end
}
