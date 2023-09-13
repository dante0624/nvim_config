-- Installs packing in the correct location
-- Returns true if this is the first time (bootstrapping)
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
		return false
end

local packer_bootstrap = ensure_packer()
if packer_bootstrap then
	return false -- This indicates that plugins are not ready
end

local packer = require("packer")

-- Have packer use a popup window
packer.init({
    display = {
		open_fn = function()
        return require('packer.util').float({ border = 'single' })
		end
	}
})


-- Install your plugins here
return packer.startup(function(use)
	use 'wbthomason/packer.nvim'

	use {'nvim-tree/nvim-tree.lua',
		tag = 'f5804ce', -- Windows bug was fixed at this commit, then broken later
		requires = {
			'nvim-tree/nvim-web-devicons',
		},
		config = function()
			-- NvimTree: disable netrw at the very start of your init.lua (strongly advised)
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			require('myKeymaps.fileTree')

			require("nvim-tree").setup({
				on_attach = Tree_On_Attach,
				sync_root_with_cwd = true,
				git = {
					ignore = false, -- Starts off by not ignoring gitignored files
					timeout = 1000, -- Increase from 400ms (default) to 1s
				},
			})
		end,
	}
	-- use {'akinsho/bufferline.nvim',
	-- 	tag = "*",
	-- 	requires = 'nvim-tree/nvim-web-devicons',
	-- 	config = function()
	-- 		require("bufferline").setup({
	-- 			options = {
	-- 				move_wraps_at_ends = true,
	-- 			},
	-- 		})
	-- 		require("myKeymaps.tabline")
	-- 	end,
	-- }
	use {'romgrk/barbar.nvim',
		requires = {
			'nvim-tree/nvim-web-devicons',
			'lewis6991/gitsigns.nvim',
		},
		config = function()
			require('barbar').setup({
				animation = false,
				insert_at_end = true,
  				focus_on_close = 'left',
				no_name_title = '[No Name]',
			})
			require("myKeymaps.tabline")
		end,

	}
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'nvim-tree/nvim-web-devicons', opt = true },
		config = function()
			require('lualine').setup({
				sections = {
					lualine_a = {'mode'},
					lualine_b = {
						{'branch', color='ColorColumn', },
						{'diff', color='ColorColumn'},
					},
					lualine_c = {
						{'filename', color='Normal'}
					},
					lualine_x = {
						{'fileformat', color='Normal'},
						{'filetype', color='Normal'}
					},
					lualine_y = {
						{'progress', color='ColorColumn'},
						{'location', color='ColorColumn'}
					},
					lualine_z = {
						{'datetime', style="%H:%M", color='Cursor'}
					},
				},
			})
		end,
	}
    use {'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
		config = function()
			-- Zig is the easiest compiler to get on Windows and WSL, but not on for MacOS or Linux
			local os = require("utils.os")

			local treesitter_compilers
			if os.is_windows or os.is_wsl then
				treesitter_compilers = { "zig" }
			else
				treesitter_compilers = { "cc" }
			end

			require('nvim-treesitter.install').compilers = treesitter_compilers
			require('nvim-treesitter.configs').setup({
				highlight = { enable = true },

				-- Note that treesitter for json sucks, and the default syntax works perfectly
				ensure_installed = {
					"comment", -- If I don't have this, WSL bugs out on every comment
					"lua",
					"python",
					"java",
					"kotlin",
					"html",
					"css",
					"javascript",
				},

				-- Configure and setup autotag plugin because it works better on bootstrapping
				autotag = {
					enable = true,
					enable_rename = false,
					enable_close = true,
					enable_close_on_slash = true,
					filetypes = { "html" , "xml" },
				},
			})
		end,
    }
	use 'folke/tokyonight.nvim'

	use {'hrsh7th/nvim-cmp',
		requires = { 'L3MON4D3/LuaSnip' },
		config = function()
			require('myCompletion')
		end,
	}
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-nvim-lua'
	use 'saadparwaiz1/cmp_luasnip'
	use 'rafamadriz/friendly-snippets'

	use {'williamboman/mason-lspconfig.nvim',
		requires = {
			'neovim/nvim-lspconfig',
			'williamboman/mason.nvim',
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			require('lsp') -- My folder, handles all setting up of all LSP stuff
		end,
	}
 	-- TODO: Remove this plugin because it is getting archived
	-- Currently is responsible for just the html lsp I believe
	use 'jose-elias-alvarez/null-ls.nvim'

 	-- Configure Java Lsp differently because it wants to be hard
	-- Actual configuration is found under ftplugin/java.lua
	use 'mfussenegger/nvim-jdtls'

	use {'nvim-telescope/telescope.nvim',
		tag = '0.1.1',
		requires = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-fzy-native.nvim',
		},
		config = function()
			require('myKeymaps.telescopeKeymaps')
			require('telescope').setup({
				extensions = {
					fzy_native = {
						override_generic_sorter = false,
						override_file_sorter = true,
					}
				},
				pickers = {
					find_files = {
						theme = "dropdown",
					},
					live_grep = {
						preview = "true", -- The preview is useful for grep
					},
				},
				defaults = {
					preview = false, -- The preview is not really useful otherwise imo
					sorting_strategy = "ascending",
					layout_config = {
						prompt_position = 'top',
					},
					prompt_prefix = " ",
					selection_caret = " ",
					path_display = { "smart" },

					mappings = My_Telescope_Keymaps,
				},
			})
			require('telescope').load_extension('fzy_native')
		end,
	}

	use {'windwp/nvim-autopairs',
		config = function()
			require("nvim-autopairs").setup({})
		end,
	}
	use {'windwp/nvim-ts-autotag',
		-- Treesitter is also responsible for config / setup of this plugin
		requires = 'nvim-treesitter/nvim-treesitter',
		after = 'nvim-treesitter',
	}
	use {'numToStr/Comment.nvim',
		config = function()
			require('myKeymaps.comments')
			require('Comment').setup()
		end,
	}
	use {'lewis6991/gitsigns.nvim',
		config = function()
			require('myKeymaps.gitSigns')
			require('gitsigns').setup({
				on_attach = GitOnAttach,
				current_line_blame_opts = {
					virt_text = false,
				},
			})
		end,
	}

	use {'akinsho/toggleterm.nvim',
		tag = '*',
		config = function()
			require("utils.shell").set_shell()
			require('myKeymaps.terminal')
			require("toggleterm").setup({
				direction = 'float',
				size = 20, -- Only relevant if I switch to horizontal
				shade_terminals = false,
				open_mapping = Terminal_Open_Mapping,
				insert_mappings = false, -- whether or not the open mapping applies in insert mode
				terminal_mappings = false, -- whether or not the open mapping applies in terminal mode
				persist_mode = false,
				float_opts = {
					width = function() return math.floor(vim.o.columns * 0.9) end,
					height = function() return math.floor(vim.o.lines * 0.9) end,
				}
			})
		end,
	}

	use {'phaazon/hop.nvim',
		config = function()
			require('hop').setup()
			require('myKeymaps.hopping')
		end,
	}
end)

