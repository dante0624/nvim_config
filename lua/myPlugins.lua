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
	-- My plugins here. Just requires a URL after github.com/
	use 'wbthomason/packer.nvim' -- Have packer manage itself

	use {'nvim-tree/nvim-tree.lua', -- File Exploration Tree
		requires = {
			'nvim-tree/nvim-web-devicons', -- Gives the tree nice icons
		},
		config = function()
			-- NvimTree: disable netrw at the very start of your init.lua (strongly advised)
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			require('myKeymaps.fileTree') -- Gives me the TreeOnAttach function

			require("nvim-tree").setup({
				on_attach = Tree_On_Attach,
				view = {
					number = true,
					relativenumber = true,
				},
				sync_root_with_cwd = true,
				git = {
					ignore = false, -- Starts off by not ignoring gitignored files
				},
			})
		end,
	}
	use {'akinsho/bufferline.nvim', -- Gives buffers very nice tabs
		tag = "*",
		requires = 'nvim-tree/nvim-web-devicons',
		config = function()
			require("bufferline").setup({})
		end,
	}

    use {'nvim-treesitter/nvim-treesitter', -- Better coloring based on languages
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
		config = function()
			require('nvim-treesitter.install').compilers = { "zig" }
			require('nvim-treesitter.configs').setup({
				highlight = { enable = true },
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
			})
		end,
    }
	use 'folke/tokyonight.nvim' -- Give me a nice color scheme

	use {'hrsh7th/nvim-cmp', -- The Code Completion Engine
		requires = { 'L3MON4D3/LuaSnip' }, -- The Snippet Engine
		config = function()
			require('myCompletion') -- Runs all the needed config stuff
		end,
	}
	use 'hrsh7th/cmp-buffer' -- Buffer completions
	use 'hrsh7th/cmp-path' -- Path completions
	-- use 'hrsh7th/cmp-cmdline' -- Cmdline completions
	use 'hrsh7th/cmp-nvim-lua' -- Gives completion on nvim things like vim.fn.*
	use 'saadparwaiz1/cmp_luasnip' -- Snippet completions
	use 'rafamadriz/friendly-snippets' -- Collection of snippets to use

	use {'williamboman/mason-lspconfig.nvim', -- Installs and manages LSPs
		requires = {
			'neovim/nvim-lspconfig', -- NVim's own LSP client
			'williamboman/mason.nvim', -- Just an LSP installer
			'hrsh7th/cmp-nvim-lsp', -- Gives lsp code completion
		},
		config = function()
			require('lsp') -- My folder, handles all setting up of all LSP stuff
		end,
	}
	use 'jose-elias-alvarez/null-ls.nvim' -- Formatters and Linters
	use 'mfussenegger/nvim-jdtls' -- Configure Java Lsp differently because it wants to be hard
	-- Actual configuration is found under ftplugin/java.lua

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
						preview = "true", -- The preview is more useful for grep
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
		config = function()
			require('nvim-ts-autotag').setup({
				filetypes = { "html" , "xml" },
			})
		end,
	}
	use {'numToStr/Comment.nvim',
		config = function()
			require('myKeymaps.comments')
			require('Comment').setup()
		end,
	}
	use {'lewis6991/gitsigns.nvim',
		config = function()
			require('myKeymaps.gitSigns') -- Gives me the GitOnAttach 
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
				size = 20, -- Only relevant if I switch back to horizontal
				shade_terminals = false,
				open_mapping = Terminal_Open_Mapping,
				insert_mappings = true, -- whether or not the open mapping applies in insert mode
				terminal_mappings = true, -- whether or not the open mapping applies in terminal mode
				persist_mode = false,
				float_opts = {
					width = function() return math.floor(vim.o.columns * 0.9) end,
					height = function() return math.floor(vim.o.lines * 0.9) end,
				}
			})
		end,
	}
end)

