local hex = function(n)
    return string.format("#%06x", n)
end

local bold = {fg=hex(vim.api.nvim_get_hl_by_name('Label', true).foreground), bg=nil, gui="bold",}
local normal = {fg=hex(vim.api.nvim_get_hl_by_name('Label', true).foreground), bg=nil}
local dj = {a = normal, b = normal, c = normal}

local clear = {normal = dj, visual = dj, inactive = dj, replace = dj, insert = dj, command = dj}

return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
       require('lualine').setup {
          options = {
            icons_enabled = true,
            theme = clear, --'rose-pine',
            component_separators = {},
            section_separators = {},
            disabled_filetypes = {
              statusline = {},
              winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = false,
            always_show_tabline = false,
            globalstatus = false,
            refresh = {
              statusline = 1000,
              tabline = 1000,
              winbar = 1000,
              refresh_time = 16, -- ~60fps
              events = {
                'WinEnter',
                'BufEnter',
                'BufWritePost',
                'SessionLoadPost',
                'FileChangedShellPost',
                'VimResized',
                'Filetype',
                'CursorMoved',
                'CursorMovedI',
                'ModeChanged',
              },
            }
          },
          sections = {
            lualine_a = {{
                'mode',
                color=bold,
            }},
            lualine_b = {{
                'branch',
                icon= '󰣘',
            }, {
                'diagnostics',
                color=normal,

                sections={'error', 'warn'},
                symbols={'', ''},
                diagnostics_color = {
                    error = normal,
                    warn = normal,
                },
                update_in_insert = false, -- Update diagnostics in insert mode.
            }},
            lualine_c = {{'filename', color = normal}},
            lualine_x = {},
            lualine_y = {{'progress', color = normal}},
            lualine_z = {{'location', color = normal}},
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {},
          winbar = {},
          inactive_winbar = {},
          extensions = {}
         } 

    end,
} 
