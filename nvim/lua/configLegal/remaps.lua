vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "J", function()
  return "mz" .. vim.v.count1 .. "J`z"
end, { expr = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-s>", ":w<Enter>")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v", "l"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v", "l"}, "<leader>d", "\"_d")
vim.keymap.set({"n", "v", "l"}, "<leader>D", [["+D]])

vim.keymap.set({"n", "v", "l"}, "<leader>P", [["+P]])


vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', 'ya', "mpggVGy`p");
vim.keymap.set('n', '<leader>ya', [[mpggVG"+y`p]]);

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>l', vim.diagnostic.setqflist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<C-m>', '<cmd>cnext<Cr>');
vim.keymap.set('n', '<C-n>', '<cmd>cprev<Cr>');

vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set('t', '<leader><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>v', '<C-w><C-v>', { desc = 'Create vertical split' })

-- using pt layout on us keyboard
-- vim.keymap.set({'n', 'v', 'l'}, '\\eo', '|');
-- vim.keymap.set({'n', 'v', 'l'}, '<M-O>', '\\');

--[[
local ns = vim.api.nvim_create_namespace("count_highlight")

local count = ""
vim.on_key(function(key)
    if vim.fn.mode() ~= "n" then return end

    if key:match("%d") then
        count = count .. key
        local n = tonumber(count)
        if n then
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            local target = row + n
            -- vim.api.nvim_buf_add_highlight(0, ns, "Visual", target, 0, -1)
            vim.hl.range(0, ns, "Visual", {target, 0}, {target, -1}, {
                inclusive = true
            })

            -- add virt_text in signcolumn area (near number column)
            -- vim.api.nvim_buf_set_extmark(0, ns, target, 0, {
            --     virt_text = { { tostring(target + 1), "Visual" } }, -- line numbers are 1-based
            --     virt_text_pos = "overlay",
            --     hl_mode = "combine",
            -- })
        end
    else
        -- motion typed -> reset
        count = ""
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end
end, vim.api.nvim_create_namespace("count_listener"))

]]--
