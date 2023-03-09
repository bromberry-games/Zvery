local Helpers = {}

function Helpers.ShuffleDeckInZone(zone)
    local objectsInZone = zone.getObjects()
    for i, deck in ipairs(objectsInZone) do
        deck.shuffle()
        deck.flip()
        return deck
    end
end

function Helpers.CreateScriptingZoneAtPosition(position, name)
    local zone = spawnObject({type="ScriptingTrigger"})
    zone.setName(name)
    zone.setPosition(position)
    zone.setScale({3,3,3})
    return zone
end

function Helpers.LockAndFloor(obj)
   obj.setLock(true)
   local pos = obj.getPosition()
   obj.setPosition({pos[1], 0, pos[3]})
end

function Helpers.SelectCardAtZone(zone)
    local objects = zone.getObjects()
    for i, object in ipairs(objects) do
        return object
    end
end

function Helpers.DestroyAllInTable(toDestroy)
    for _, object in pairs(toDestroy) do
        object.destruct()
    end
end

return Helpers