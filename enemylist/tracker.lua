local tracker = {
  frameCount = 0,
  mobs = {
    -- 1345123 = { id, name, hpp }
  },
}

function tracker:initialize()
  -- listen to action events that happen
  windower.register_event('action', function(action)
    tracker:handleActionEvent(action)
  end)

  -- handle updating the tracked mobs hpp
  windower.register_event('prerender', function()
    if tracker.frameCount % 30 == 0 then
      tracker:updateMobs()
      tracker.frameCount = 0
    end

    tracker.frameCount = tracker.frameCount + 1
  end)

  -- handle zoning
  windower.register_event('incoming chunk', function(id, data, modified, isInjected, isBlocked)
    if isInjected then
      return
    end

    -- handle zoning somewhere else
    if id == 0xB then
      tracker:clearTrackedMobs()
    end
  end)
end

function tracker:getTrackedMobs()
  return tracker.mobs
end

function tracker:clearTrackedMobs()
  tracker.mobs = {}
end

function tracker:trackMob(id, name, hpp, caller)
  tracker.mobs[id] = {
    name = name,
    hpp = hpp
  }
end

function tracker:untrackMob(id)
  tracker.mobs[id] = nil
end

function tracker:updateMobs()
  for id, data in pairs(tracker:getTrackedMobs()) do
    local mob = windower.ffxi.get_mob_by_id(id)

    if mob ~= nil then
      tracker.mobs[id].hpp = mob.hpp

      if mob.hpp <= 0 then
        tracker:untrackMob(id)
      end
    end
  end
end

function tracker:handleActionEvent(action)
  -- action keys:
  --   targets(id, actions, action_count) category actor_id
  --   recast unknown target_count param
  -- actor keys:
  --   valid_target index claim_id race
  --   hpp facing is_npc in_alliance
  --   in_party charmed models entity_type
  --   target_index animation_speed spawn_type
  --   distance z x y status name model_scale
  --   heading model_size id movement_speed

  local actor = windower.ffxi.get_mob_by_id(action.actor_id)
  if (actor == nil) or (actor.valid_target ~= true) then
    return
  elseif tracker:isFinishAction(action.category) ~= true then
    return
  end

  if tracker:isMember(actor) then
    tracker:handleMemberAction(action, actor)
  elseif tracker:isPlayerPet(actor) then
    tracker:handlePlayerPetAction(action, actor)
  elseif tracker:isMob(actor) then
    tracker:handleMobAction(action, actor)
  end
end

function tracker:isPlayerOutsideParty(data)
  if data == nil then
    return false
  end

  if data.spawn_type == 1 then
    return true
  end

  return false
end

function tracker:isPartyMember(data)
  if data == nil then
    return false
  end

  if data.spawn_type == 13 then
    return true
  end

  return false
end

function tracker:isAllianceMember(data)
  if data == nil then
    return false
  end

  if data.spawn_type == 9 then
    return true
  end

  return false
end

function tracker:isMember(data)
  return tracker:isPartyMember(data) or tracker:isAllianceMember(data)
end

function tracker:isPlayerPet(data)
  if data == nil then
    return false
  end

  if data.spawn_type == 2 then
    return true
  end

  return false
end

function tracker:isMob(data)
  if data == nil then
    return false
  end

  if data.spawn_type == 16 then
    return true
  end

  return false
end

function tracker:handleMemberAction(action, actor)
  -- another player took an action, we want to make sure the action was
  -- against an enemy mob only
  for idx, data in pairs(action.targets) do
    local target = windower.ffxi.get_mob_by_id(data.id)

    if tracker:isMob(target) then
      tracker:trackMob(target.id, target.name, target.hpp, 'handleMemberAction')
    end
  end
end

function tracker:handlePlayerPetAction(action, actor)
  -- a player pet took an action, we want to make sure the action was
  -- against an enemy mob only
  for idx, data in pairs(action.targets) do
    local target = windower.ffxi.get_mob_by_id(data.id)

    if tracker:isMob(data) then
      tracker:trackMob(target.id, target.name, target.hpp, 'handlePlayerPetAction')
    end
  end
end

function tracker:handleMobAction(action, actor)
  -- a mob took an action, we want to make sure the action was
  -- against a player or a player pet
  for idx, data in pairs(action.targets) do
    local target = windower.ffxi.get_mob_by_id(data.id)

    if tracker:isMember(target) or tracker:isPlayerPet(target) then
      tracker:trackMob(actor.id, actor.name, actor.hpp, 'handleMobAction')
    end
  end
end

function tracker:isFinishAction(categoryID)
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

return tracker
