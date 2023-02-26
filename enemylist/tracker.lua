local tracker = {
  mobs = {
    -- 1345123 = { id, name, hpp }
  }
}

function tracker:initialize()
  windower.register_event('action', function(action)
    tracker:handleAction(action)
  end)

  windower.register_event('prerender', function()
    tracker:updateTrackedMobsHPP()
  end)
end

function tracker:getTrackedMobs()
  return tracker.mobs
end

function tracker:handleAction(action)
  -- keys: targets, category, actor_id, recast, unknown, target_count, param
  local actor = windower.ffxi.get_mob_by_id(action.actor_id)

  if actor == nil then
    return
  elseif actor.valid_target ~= true then
    return
  end

  if actor.in_party or actor.in_alliance then
    -- player -> something else
    for idx, target in pairs(action.targets) do
      local target = windower.ffxi.get_mob_by_id(target.id)

      if target.valid_target and target.is_npc then
        tracker:trackMob(target.id, target.name, target.hpp)
      end
    end
  elseif actor.is_npc then
    -- mob -> player
    for idx, target in pairs(action.targets) do
      local target = windower.ffxi.get_mob_by_id(target.id)

      if target.valid_target and (target.is_npc == false) and (target.in_party or target.in_alliance) then
        tracker:trackMob(actor.id, actor.name, actor.hpp)
      end
    end
  end
end

function tracker:trackMob(id, name, hpp)
  if tracker.mobs[id] == nil then
    print('Tracking new mob: ' .. name)
  end

  tracker.mobs[id] = {
    name = name,
    hpp = hpp
  }
end

function tracker:untrackMob(id)
  local mobs = {}

  for k, v in pairs(tracker:getTrackedMobs()) do
    if k ~= id then
      mobs[k] = v
    end
  end

  tracker.mobs = mobs
end

function tracker:updateTrackedMobsHPP()
  for id, data in pairs(tracker:getTrackedMobs()) do
    local mob = windower.ffxi.get_mob_by_id(id)

    tracker.mobs[id].hpp = mob.hpp
    if mob.hpp == 0 then
      print('Untracking mob: ' .. mob.name)
      tracker:untrackMob(id)
    end
  end
end

return tracker
