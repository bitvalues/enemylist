local events = require('events')
local resources = require('resources')
require('tables')
require('sets')

local CHUNK_ID_LOGOUT_ZONE = 0x0B
local CHUNK_ID_ACTION = 0x28
local CHUNK_ID_ACTION_MESSAGE = 0x29

local debuffs = {
  _trackedMobs = T{
    -- 1345123 = { 21 = "Dia", 22 = "Poison" },
  }
}

function debuffs.initialize()
  windower.register_event('incoming chunk', debuffs.onIncomingChunk)
end

function debuffs.onIncomingChunk(id, data)
  if id == CHUNK_ID_LOGOUT_ZONE then
    debuffs._trackedMobs = T{}
    events.publish('debuffs.cleared', debuffs._trackedMobs:length())
  elseif id == CHUNK_ID_ACTION then
    debuffs.handleActionPacket(windower.packets.parse_action(data))
  elseif id == CHUNK_ID_ACTION_MESSAGE then
    debuffs.handleActionMessagePacket({
      targetID = data:unpack('I',0x09),
      paramID = data:unpack('I',0x0D),
      messageID = data:unpack('H',0x19)%32768,
    })
  end
end

function debuffs:getActionFirstTargetActionMessage(action)
  if (not action) or (not action.targets) then
    return nil
  elseif (not action.targets[1]) or (not action.targets[1].actions) then
    return nil
  elseif (not action.targets[1].actions[1]) or (not action.targets[1].actions[1].message) then
    return nil
  end

  return action.targets[1].actions[1].message
end

function debuffs.handleActionPacket(action)
  local message = debuffs:getActionFirstTargetActionMessage(action)

  if not message then
    return
  end

  -- check damaging spell
  if S{2, 252}:contains(message) then
    local targetID = action.targets[1].id
    local spellID = action.param
    local effectID = resources.spells[spellID].status
    local spellName = resources.spells[spellID].name

    if effectID then
      debuffs.register(targetID, effectID, spellName)
    end

  -- check non-damaging spells
  elseif S{236, 237, 268, 271}:contains(message) then
    local targetID = action.targets[1].id
    local effectID = action.targets[1].actions[1].param
    local spellID = action.param
    local spellName = resources.spells[spellID].name

    if (resources.spells[spellID].status) and (resources.spells[spellID].status == effectID) then
      debuffs.register(targetID, effectID, spellName)
    end
  end
end

function debuffs.handleActionMessagePacket(actionMessage)
  -- unit died
  if S{6, 20, 113, 406, 605, 646}:contains(actionMessage.messageID) then
    debuffs.unregister(actionMessage.targetID, nil)

  -- debuff expired
  elseif S{64, 204, 206, 350, 531}:contains(actionMessage.messageID) then
    debuffs.unregister(actionMessage.targetID, actionMessage.paramID)
  end
end

function debuffs.register(targetID, effectID, spellName)
  if not debuffs._trackedMobs[targetID] then
    debuffs._trackedMobs[targetID] = T{}
  end

  if not debuffs._trackedMobs[targetID]:containskey(effectID) then
    debuffs._trackedMobs[targetID][effectID] = spellName
    events.publish('debuffs.register', targetID, effectID, spellName)
  end
end

function debuffs.unregister(targetID, effectID)
  if not targetID then
    return
  elseif not debuffs._trackedMobs[targetID] then
    return
  end

  if not effectID then
    debuffs._trackedMobs = {}
    events.publish('debuffs.target.clear', targetID)
  elseif debuffs._trackedMobs[targetID][effectID] ~= nil then
    local spellName = debuffs._trackedMobs[targetID][effectID]

    debuffs._trackedMobs[targetID][effectID] = nil
    events.publish('debuffs.unregister', targetID, effectID, spellName)
  end

end

return debuffs
