-- ~/.config/xplr/init.lua

version = "0.18.0"

local home = os.getenv("HOME")
package.path = home
.. "/.config/xplr/plugins/?/init.lua;"
.. home
.. "/.config/xplr/plugins/?.lua;"
.. package.path

require("zentable").setup()
require("icons").setup()
