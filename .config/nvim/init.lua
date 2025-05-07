local plugins = require("config")

require("plugins.utils.root").setup()
require("plugins.utils.run").setup()
require("config.neovide").setup()
_G.Root = require("plugins.utils.root")
_G.Pick = require("plugins.utils.pick")
