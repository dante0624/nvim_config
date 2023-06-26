local Map = require("utils.map").Map

--[[ Treesitter initially parses where all folds should be perfectly a buffer first opens
But sometimes if a newline is added, the new lines that should be folded don't get updated
Hacky solution to make treesitter re-parse where the folds should be.
Just set the foldmethod to expr again]]
local reload_fold_parsing = '<Cmd>set foldmethod=expr<CR>'

Map('', 'zz', reload_fold_parsing..'za')
Map('', 'ze', reload_fold_parsing..']z')
Map('', 'zb', reload_fold_parsing..'[z')

Map('', 'za', reload_fold_parsing..'za')
Map('', 'zo', reload_fold_parsing..'zo')
Map('', 'zO', reload_fold_parsing..'zO')
Map('', 'zc', reload_fold_parsing..'zc')
Map('', 'zC', reload_fold_parsing..'zC')
Map('', 'zR', reload_fold_parsing..'zR')
Map('', 'zM', reload_fold_parsing..'zM')

