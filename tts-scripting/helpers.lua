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

function Helpers.SelectFirstObjectInZone(zone)
    local objects = zone.getObjects()
    for i, object in ipairs(objects) do
        return object
    end
end

function Helpers.ZoneIsEmpty(zone)
    return #zone.getObjects() == 0
end

function Helpers.DestroyAllInTable(toDestroy)
    for _, object in pairs(toDestroy) do
        object.destruct()
    end
end

function Helpers.GetObjectsFromGUIDs(guids)
    if guids == nil or #guids == 0 then
       return {} 
    end
    local objects = {}
    for _, guid in pairs(guids) do
        local object = getObjectFromGUID(guid)
        if object ~= nil then
            table.insert(objects, object)
        end
    end
    return objects
end

function Helpers.GetGUIDsTable(objects)
   local guids = {} 
   for _, object in pairs(objects) do
       table.insert(guids, object.getGUID()) 
   end
   return guids
end
    

return Helpers