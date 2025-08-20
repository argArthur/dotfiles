return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    event = 'VeryLazy',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },

    config = function ()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        -- default to find file if not in repo
        vim.keymap.set('n', '<leader>gf', function()
            local git_dir = vim.fn.systemlist('git rev-parse --is-inside-work-tree')

            if git_dir[1] == "true" then
                builtin.git_files()
            else
                builtin.find_files()
            end
        end)

        vim.keymap.set('n', '<leader>ff', builtin.find_files)
        vim.keymap.set('n', '<leader>F', builtin.find_files)
        vim.keymap.set('n', '<leader>fg', builtin.live_grep)
        vim.keymap.set('n', '<leader>fb', builtin.buffers)

        local image = require("image")

        telescope.setup({
            extensions = {
                fzf = {}
            },
            defaults = {
                preview = {
                    hooks = function (filepath, bufnr, opts)
                        if filepath:match("%.png$") ~= nil then 
                           image.show(filepath, {
                                buffer = bufnr,
                                window = opts.winid,
                          }) 
                        end
                    end
                },
            },
            pickers = {
                find_files = { disable_devicons = true, },
                git_files = { disable_devicons = true, },
                live_grep = { disable_devicons = true, },
                buffer = { disable_devicons = true, },
            },
        })

        telescope.load_extension('fzf')

        local image_previewer = require("telescope.previewers").new_buffer_previewer {
          define_preview = function(self, entry, status)

            local Path = require("plenary.path")
            local filepath = entry.path or entry.value
            if not filepath or not Path:new(filepath):exists() then
              return
            end

            -- Limpa o buffer
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {})

            -- Mostra imagem com image.nvim
            local imageApi = require("image")

            vim.schedule(function ()
                local pos = vim.api.nvim_win_get_position(self.state.winid)

                local image = imageApi.from_file(entry.path, {
                    windown = self.state.winid,
                    buffer = self.state.bufnr,
                    --x = pos[1],
                    --y = pos[2],
                })

                imageApi.clear()
                image:render() --ainda ta fora do buffer
            end)
          end,

          teardown = function (self)
            local imageApi = require("image")
            imageApi.clear()
          end,
        }


        local image_files = function()
          return vim.fn.glob("**/*.{png,jpg,jpeg,gif}", false, true)
        end

        local image_picker = function()
          require("telescope.pickers").new({}, {
            prompt_title = "Image Picker",
            finder = require("telescope.finders").new_table {
              results = image_files(),
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry,
                  ordinal = entry,
                  path = entry,
                }
              end
            },
            previewer = image_previewer, -- ou in-line
            sorter = require("telescope.config").values.generic_sorter({}),
          }):find()
        end

        vim.api.nvim_create_user_command("ImagePicker", image_picker, {})

        vim.keymap.set('n', '<leader>fi', image_picker)
    end
}
