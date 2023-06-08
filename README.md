# nvim_config
Just my nvim configuration. I want it to work on any operating system so I can have one IDE for life

# Installation
Use git clone to install, but it must be installed in the correct place depending on OS.
Generally you can figure this out by going into Neovim's command mode and typing: `lua print(vim.fn.stdpath("config"))`
You may need to manually create this directory path if it does not exist yet.
Then clone the repo into this now empty directory with `git clone <URL> <Dir>`
Generally these paths look like:

## Windows
`~\AppData\Local\nvim`
## WSL, MacOS, and Linux
`~\.config\nvim`

# Dependencies
These need to be installed manually, and be available as shell commands. So they need to also be on the path.

## Some Compiler for Treesitter
I suggest using zig for everything because it is cross platform and works everywhere. It can be installed with
### Windows
`choco install zig`
### WSL, MacOS, and Linux
`sudo snap install zig`

## A special font used in terminal
Need to download a special font from https://www.nerdfonts.com/
The Nvim config was built using one called "Hack Nerd Font" so that should probably be used.
It needs to be downloaded, and the terminal which nvim is inside of needs to be set to use this font.
This gives several, very useful icons to many nvim plugins.

## Rip Grep
Available at: https://github.com/BurntSushi/ripgrep
Needed for telescope's live grep feature. Check if installed by typing `rg` in terminal.

## FD
Available at https://github.com/sharkdp/fd
Needed for speed up telescope. Check if installed by typing `fd` in terminal.

# Cold start for Plugins
When nvim is opened for the first time with this config, it will start by downloading Packer, the plugin manager.
Once this is done, the user needs to exit and reopen nvim.
At this point packer itself will be installed, but it will not yet have installed all needed plugins.
So the user needs to run :PackerSync from the command line. This will begin installing all plugins.
Once done, it is time to exit and quit one more time, and now nvim should work!
