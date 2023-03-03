-- dependencies
local events = require('events')
local settings = require('settings')
local tracker = require('tracker')
local debuffs = require('debuffs')
local ui = require('ui')
local commands = require('commands')

-- addon setup
_addon.name = 'enemylist'
_addon.author = 'Bitvalues'
_addon.version = 1.3
_addon.command = 'enemylist'
_addon.commands = {'elist'}

-- now, initialize everything
settings:initialize()
tracker:initialize()
debuffs:initialize()
ui:initialize()
commands:initialize()
