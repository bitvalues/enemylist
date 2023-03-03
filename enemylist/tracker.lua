local events = require('events')
require('tables')
require('sets')
require('pack')

local CHUNK_ID_LOGIN_ZONE = 0x0A
local CHUNK_ID_LOGOUT_ZONE = 0x0B
local CHUNK_ID_ACTION = 0x28
local CHUNK_ID_ACTION_MESSAGE = 0x29

local tracker = {
  _frameCount = 0,
  _trackedMobs = T{
    -- 1345123 = { name, hpp },
    -- 1345124 = { name, hpp },
  },
}

function tracker.initialize()
  windower.register_event('incoming chunk', tracker.onIncomingChunk)
  windower.register_event('prerender', tracker.onPrerender)
end

function tracker.onPrerender()
  if tracker._frameCount % 10 == 0 then
    tracker:updateAllTrackedMobsHPP()
    tracker._frameCount = 0
  end

  tracker._frameCount = tracker._frameCount + 1
end

function tracker.onIncomingChunk(id, data)
  if id == CHUNK_ID_LOGOUT_ZONE then
    tracker._trackedMobs = T{}
    events.publish('mobs.cleared', tracker._trackedMobs:length())
  elseif id == CHUNK_ID_ACTION then
    tracker.handleActionPacket(windower.packets.parse_action(data))
  elseif id == CHUNK_ID_ACTION_MESSAGE then
    tracker.handleActionMessagePacket({
      targetID = data:unpack('I',0x09),
      paramID = data:unpack('I',0x0D),
      messageID = data:unpack('H',0x19)%32768,
    })
  end
end

function tracker.updateAllTrackedMobsHPP()
  for id, data in pairs(tracker._trackedMobs) do
    local mob = windower.ffxi.get_mob_by_id(id)

    if mob ~= nil then
      tracker.trackMob(id, mob.name, mob.hpp)
    end
  end
end

function tracker.handleActionPacket(action)
  -- make sure there was a valid actor first
  local actor = windower.ffxi.get_mob_by_id(action.actor_id)
  if (not actor) or (not actor.valid_target) then
    return
  elseif tracker.isFinishCategoryID(action.category) ~= true then
    return
  end

  -- determine what type of actor and handle it accordingly
  if tracker.isMember(actor) then
    tracker.handleMemberAction(action, actor)
  elseif tracker.isPlayerPet(actor) then
    tracker.handlePlayerPetAction(action, actor)
  elseif tracker.isMob(actor) then
    tracker.handleMobAction(action, actor)
  end
end

function tracker.getTrackedMobs()
  return tracker._trackedMobs
end

function tracker.isPlayerOutsideParty(data)
  if not data then
    return false
  elseif data.spawn_type == 1 then
    return true
  end

  return false
end

function tracker.isPartyMember(data)
  if not data then
    return false
  elseif data.spawn_type == 13 then
    return true
  end

  return false
end

function tracker.isAllianceMember(data)
  if not data then
    return false
  elseif data.spawn_type == 9 then
    return true
  end

  return false
end

function tracker.isMember(data)
  return tracker.isPartyMember(data) or tracker.isAllianceMember(data)
end

function tracker:isPlayerPet(data)
  if not data then
    return false
  elseif data.spawn_type == 2 then
    return true
  end

  return false
end

function tracker.isMob(data)
  if not data then
    return false
  elseif data.spawn_type == 16 then
    return true
  end

  return false
end

function tracker.isFinishCategoryID(categoryID)
  -- https://github.com/Windower/Lua/wiki/Action-Event
  if categoryID == 1 then -- melee attack
    return true
  elseif categoryID == 2 then -- range attack
    return true
  elseif categoryID == 3 then -- weapon skill
    return true
  elseif categoryID == 4 then -- spell cast
    return true
  elseif categoryID == 5 then -- item use
    return true
  elseif categoryID == 6 then -- job ability
    return true
  elseif categoryID == 11 then -- tp move
    return true
  elseif categoryID == 13 then -- pet ability
    return true
  end

  return false
end

function tracker.handleMemberAction(action, actor)
  -- another player took an action, we want to make sure the action was
  -- against an enemy mob only
  for idx, data in pairs(action.targets) do
    local target = windower.ffxi.get_mob_by_id(data.id)

    if tracker.isMob(target) then
      tracker.trackMob(target.id, target.name, target.hpp)
    end
  end
end

function tracker.handlePlayerPetAction(action, actor)
  -- a player pet took an action, we want to make sure the action was
  -- against an enemy mob only
  for idx, data in pairs(action.targets) do
    local target = windower.ffxi.get_mob_by_id(data.id)

    if tracker.isMob(data) then
      tracker.trackMob(target.id, target.name, target.hpp)
    end
  end
end

function tracker.handleMobAction(action, actor)
  -- a mob took an action, we want to make sure the action was
  -- against a player or a player pet
  for idx, data in pairs(action.targets) do
    local target = windower.ffxi.get_mob_by_id(data.id)

    if tracker.isMember(target) then
      tracker.trackMob(actor.id, actor.name, actor.hpp)
    end
  end
end

function tracker.trackMob(id, name, hpp)
  if not tracker._trackedMobs[id] then
    tracker._trackedMobs[id] = {}
  end

  local cachedHPP = tracker._trackedMobs[id].hpp
  local cachedName = tracker._trackedMobs[id].name

  tracker._trackedMobs[id].name = name
  tracker._trackedMobs[id].hpp = hpp

  if (cachedName ~= name) or (cachedHPP ~= hpp) then
    events.publish('mob.track', id, name, hpp)
  end
end

function tracker.untrackMob(id)
  if tracker._trackedMobs[id] ~= nil then
    local mob = tracker._trackedMobs[id]
    tracker._trackedMobs[id] = nil

    events.publish('mob.untrack', id, mob.name)
  end
end

function tracker.handleActionMessagePacket(actionMessage)
  if S{6, 20, 113, 406, 605, 646}:contains(actionMessage.messageID) then
    -- mob died
    tracker.untrackMob(actionMessage.targetID)
  end
end

return tracker
