-- dependencies
local settings = require('settings')
local commands = require('commands')
local ui = require('ui')

-- addon setup
_addon.name = 'enemylist'
_addon.author = 'Bitvalues'
_addon.version = 1.0
_addon.command = 'elist'

-- now, initialize everything
settings:initialize()
commands:initialize()
ui:initialize()
