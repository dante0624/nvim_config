local M = {}

local hardware_architecture = vim.system({'uname', '-m'}, { text = true }):wait().stdout

--[[
Some common values `uname -m` can return:
    x86_64: 64-bit x86 architecture (common for modern Intel and AMD processors)
    amd64: Another name for x86_64 (commonly used in Debian-based systems)
    i386, i486, i586, i686: 32-bit x86 architectures

    arm64: 64-bit ARM architecture
    aarch64: Another name for 64-bit ARM architecture
    armv7l, armv6l: 32-bit ARM architectures

Some more obscure values `uname -m` can return:
    ppc64, ppc64le: 64-bit PowerPC architecture (le stands for little-endian)
    s390x: IBM System z architecture
    mips, mips64: MIPS architecture (32-bit and 64-bit)
    ia64: Intel Itanium architecture
    sparc, sparc64: SPARC architecture (32-bit and 64-bit)
    riscv64: 64-bit RISC-V architecture
]]

-- Use flags with if statements to guard architecture specific lines of code
M.is_x86 = (hardware_architecture:find("x86_64") ~= nil) or
	(hardware_architecture:find("amd64") ~= nil) or
	(hardware_architecture:match("i%d86") ~= nil)

M.is_arm = (hardware_architecture:find("arm64") ~= nil) or
	(hardware_architecture:find("aarch64") ~= nil) or
	(hardware_architecture:match("armv%dl") ~= nil)

return M

