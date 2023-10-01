# nvim_config
Just my nvim configuration. I want it to work on any operating system so I can have one IDE for life


# Installation
To install neovim itself, a simple option for Windows, MacOS, and Linus is to install the latest release from neovim's github at https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-download. Do not use chocolatey to install neovim as I have had some problems with file permissions after doing that.

Use git clone to install my configuration, but it must be installed in the correct place depending on OS.
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

## Compiler for Treesitter Parsers
### Windows and WSL
I personally have had difficulty getting c compilers to work on Windows. The simplest way I found to make this work is by using zig on windows.
This can be installed with:
`choco install zig`
### MacOS and Linux
Need to have c compiler `cc` be installed and on the path. This should come by default.

## Node and NPM
Nvim and all its plugins love to autoinstall things using these javascript tools.
Even if you have no desire to write javascript code, these 2 are still needed to make nvim work.
Make sure they are installed, and on the path.

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

## Language Versions
In order to get the LSPs to work, make sure that each language is up to the neccessary version and on the path.
### Python
python3 is needed, ensure that `python` has an alias which links it to python3.
### Java
java 17 is needed, ensure that `java` returns a version >= 17.


# Cold start for Plugins
## Lazy and Plugins
The first time using neovim with this config, users should type `$nvim` with no arguments. It will start by downloading Lazy, the plugin manager.
A popup window will appear for Lazy, where it will automatically begin installing the plugins.
This is a visual process where the plugins will move out of a `Working` section and into an `Installed` section.
Once this is done, press the `q` key to close the popup.
Note that prior to doing this you may need to press the enter key to dismiss any messages that may appear at the bottom of the screen.

## Treesitter Parsers
Neovim will automatically be downloading and compiling all parsers at this time.
At this point you should wait for them to be installed correctly. Depending on the device and compiler speeds, this may be very fast or take a couple of minutes.
Messages will appear at the bottom of the screen for each parser that has been installed.
If you miss these messages you can execute the command `:messages` to reread them (use `j` and `k` to vertically scroll through all messages).
There are a total of n parsers to install, so you are looking for a message where parser number [n/n] was installed correctly.
It is very important not to exit out of neovim until all n parsers have been installed, as exiting early may lead to some parsers never working properly.

## Mason LSPs
Neovim will also be automatically downloading all LSPs at this time.
Messages will also appear saying when these are done, however it will not say how many need to be installed in total.
To check this, execute the command `:Mason` to view a new popup window.
This is very similar to the popup window for lazy, where each item visually moves from `Installing` or `Queued` sections to the `Installed` section.
Once the popup window only shows 2 sections (`Installed` and `Available`) then you can be condident that the installation is done.
Once again, press the `q` key to close the popup.

## Post Installation Completion
The safest and simplest thing to do now is to exit neovim via the `:q` command.
Now you are free to use neovim to edit files going forward :)
