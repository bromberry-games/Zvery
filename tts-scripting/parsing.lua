local Decker = require("decker")
local CreaturesScript = require("creatures")
local AbilitiesScript = require("abilities")

--local AbilitiesScript = require("abilities_json")
local mutationDeckLink = 'https://i.imgur.com/tukh2KN.png'
local creatureDeckLink = 'https://i.imgur.com/Vo3OeAN.png'
local abilityDeckLink = 'https://i.imgur.com/JGFH47k.png'


local currentPlayer = ""
local otherPlayer = ""
local playersSetup = 0
local selectedAt = 0

local function lockAndFloor(obj)
   obj.setLock(true)
   local pos = obj.getPosition()
   obj.setPosition({pos[1], 0, pos[3]})
end

local function createScriptingZoneAtPosition(position, name)
    local zone = spawnObject({type="ScriptingTrigger"})
    zone.setName(name)
    zone.setPosition(position)
    zone.setScale({3,3,3})
    return zone
end

function switchPlayers()
   temp = currentPlayer 
   currentPlayer = otherPlayer
   otherPlayer = temp
end

function StartSetup()
    DestroyAll()
    Wait.frames(GameSetup, 5)
end

function DestroyAll()
    local objects = getAllObjects()
    for i, object in ipairs(objects) do
        object.destruct()
    end
end

function GameSetup()
    local creatureDeck =  SpawnDeck(creatureDeckLink)
    currentPlayer = 'White'
    otherPlayer = 'Blue'
    playersSetup = 0
    selectedAt = 0
    ParseCreatureDeck(creatureDeck, Creatures)
    setupAbilityDeck()
    setupMutationDeck()
    for i = 1, 5, 1 do
        spawnObject(
            {
                type = "Die_6",
                position = {21,i,-10},
            }
        )
    end
    for i = 1, 3, 1 do
        spawnObject(
            {
                type = "Die_20",
                position = {21,0,-10-i},
            }
        )
    end
    for i = 1, 5, 1 do
        spawnObject(
            {
                type = "Die_6",
                position = {-3,i,6},
            }
        )
    end
    for i = 1, 3, 1 do
        spawnObject(
            {
                type = "Die_20",
                position = {-3,0,6 + i},
            }
        )
    end
end


abilityCards = {}
function setupAbilityDeck()
    local abilityDeck = SpawnDeck(abilityDeckLink)
    local len = #Abilities + 1
    for i, card in ipairs(Abilities) do
        card = abilityDeck.takeObject({i})
        card.setName(Abilities[len - i].Name)
        jsonData = JSON.encode(Abilities[len - i])
        card.setDescription(jsonData)
        card.setPosition({-7.0,1,-2.0})
        card.flip()
    end
    AbilityCardZone = createScriptingZoneAtPosition({-7.0,1,-2.0}, "Ability Card Zone")
end

function setupMutationDeck()
    local mutationDeck = SpawnDeck(mutationDeckLink)
    mutationDeck.setPosition({25.0,1,-2.0})
    mutationDeck.flip()
    mutationDeck.shuffle()
    mutationDeck.takeObject({0}).setPosition({21.0,1,2.0})
    mutationDeck.takeObject({1}).setPosition({21.0,1,-2.0})
    mutationDeck.takeObject({2}).setPosition({21.0,1,-6.0})
end

function SpawnDeck(cardFaces)
    local cardBack = 'https://i.imgur.com/KQtQGE7.png'
    local cardAsset = Decker.Asset(cardFaces, cardBack, {width = 10, height = 5})
    local myDeck = Decker.AssetDeck(cardAsset,45)
    --return myDeck:spawn({position = {-4, 3, 0}, sideways = true})
    return myDeck:spawn({position = {-4, 3, 0}})
end

function ParseCreatureDeck(creatureDeck, creatures)
    creatureDeck.setName("Creature deck")
    local objects = creatureDeck.getObjects()

    local lvlOnePosition = {-3.0, 0, -6.0}
    local lvlTwoPosition = {-3.0, 0, -2.0}
    local lvlThreePosition = {-3.0, 0, 2.0}
    local zoneLvl1 = createScriptingZoneAtPosition(lvlOnePosition, "ZoneLvl1")
    local zoneLvl2 = createScriptingZoneAtPosition(lvlTwoPosition, "ZoneLvl2")
    local zoneLvl3 = createScriptingZoneAtPosition(lvlThreePosition, "ZoneLvl3")

    local len = #creatures + 1
    for i, card in ipairs(objects) do
        local tempCard = creatureDeck.takeObject({
            i
        })
        if tempCard == nil then
            print("Card is null")
        else
            local creature = creatures[len - i] 
            tempCard.setName(creature.Name)
            jsonData = JSON.encode(creature)
            tempCard.setDescription(jsonData)
            if(creature.Level == 1) then
                tempCard.setPosition(lvlOnePosition)
            elseif (creature.Level == 2) then
                tempCard.setPosition(lvlTwoPosition)
            else 
                tempCard.setPosition(lvlThreePosition)
            end
        end
    end 
    Wait.frames( function ()
       setupLvl1(zoneLvl1) 
    end, 20)
    Wait.frames( function ()
        setupLvl2(zoneLvl2)
    end, 20)
    Wait.frames( function ()
        setupLvl3(zoneLvl3)
    end, 20)
end

function shuffleDeckInZone(zone)
    local objectsInZone = zone.getObjects()
    for i, deck in ipairs(objectsInZone) do
        deck.shuffle()
        deck.flip()
        return deck
    end
end

function setupLvl3(zoneLvl3)
   local deck = shuffleDeckInZone(zoneLvl3) 
   lockAndFloor(deck)
end

local middlePos1 = {7.0, 1.0, -2.0}
local middlePos2 = {7.0, 1.0, -2.0}
local middlePos3 = {7.0, 1.0, -2.0}

local function createSbuttonsForCurrentPlayer() 
    local offset = 0
    print(currentPlayer)
    if currentPlayer == 'White' then
        offset = -3.0
    else
        offset = 3.0
    end
    Wait.frames( function ()
        if selectedAt ~= 1 then
            SButton1 = createSelectButton({middlePos1[1],1,middlePos1[3] + offset}, 1)
        end
        if selectedAt ~= 2 then
            SButton2 = createSelectButton({middlePos2[1],1,middlePos2[3] + offset}, 2)
        end
        if selectedAt ~= 3 then
            SButton3 = createSelectButton({middlePos3[1],1,middlePos3[3] + offset}, 3)
        end
    end, 2
    )
end

function setupLvl2(zoneLvl2)
    local deck = shuffleDeckInZone(zoneLvl2) 
    --deck.setLock(true)
    middlePos2 = {middlePos1[1] + 4, middlePos1[2], middlePos1[3]}
    middlePos3 = {middlePos2[1] + 4, middlePos2[2], middlePos2[3]}
    local card1 = deck.takeObject({0})
    card1.setPosition(middlePos1)
    card1.setLock(true)
    local card2 = deck.takeObject({1})
    card2.setPosition(middlePos2)
    card2.setLock(true)
    local card3 = deck.takeObject({2})
    card3.setPosition(middlePos3)
    card3.setLock(true)
    MiddleZone1 = createScriptingZoneAtPosition(middlePos1, "Zone1")
    MiddleZone2 = createScriptingZoneAtPosition(middlePos2, "Zone2")
    MiddleZone3 = createScriptingZoneAtPosition(middlePos3, "Zone3")

    createSbuttonsForCurrentPlayer()
end


function setupLvl1(zoneLvl1)
    local deck = shuffleDeckInZone(zoneLvl1)
    local xPos = 1.0
    deck.takeObject({0}).setPosition({xPos,1,-6.0})
    deck.takeObject({1}).setPosition({xPos,1,-2.0})
    deck.takeObject({2}).setPosition({xPos,1,2.0})
end


local buttonColor = {
    r = 1,
    g = 1,
    b = 1
}
local fontColor = {
    r = 0.25,
    g = 0.25,
    b = 0.25
}

function createSelectButton(pos, index)
    local checker = spawnObject({type="Checker_black", name="SelectButton"})
    checker.setPosition(pos)
    checker.setInvisibleTo({otherPlayer})
    checker.setLock(true)
    local button = checker.createButton({
        label = "Select",
        click_function = "SelectCreatureAtZone" .. index,
        function_owner = self,
        position = {0,1,0},
        rotation = {0, 180, 0},
        height = 440,
        width = 1000,
        font_size = 260,
        font_color = fontColor,
        color = buttonColor,
    })
    return checker
end

function SelectCreatureAtZone1()
    selectedAt = 1
    SelectCreatureAtZoneAndManageGame(MiddleZone1)
end

function SelectCreatureAtZone2()
    selectedAt = 2
    SelectCreatureAtZoneAndManageGame(MiddleZone2)
end

function SelectCreatureAtZone3()
    selectedAt = 3
    SelectCreatureAtZoneAndManageGame(MiddleZone3)
end

local function destroySbuttons()
    if SButton1 ~= nil then
        SButton1.destruct()
    end
    if SButton2 ~= nil then
        SButton2.destruct()
    end
    if SButton3 ~= nil then
        SButton3.destruct()
    end
end


local function selectCreatureAtZone (zone)
    local objects = zone.getObjects()
    for i, object in ipairs(objects) do
        return object
    end
end

local function moveCardsFromZonesToDiscard(zones)
    for i, zone in ipairs(zones) do
        local creature = selectCreatureAtZone(zone)
        if creature ~= nil then
            creature.setPosition({25.0,1,2.0})
        end
    end
end

function SelectCreatureAtZoneAndManageGame(zone)
    SelectCard(selectCreatureAtZone(zone))
    playersSetup = playersSetup + 1
    destroySbuttons()
    if playersSetup == 2 then
        Wait.frames(function ()
            moveCardsFromZonesToDiscard({MiddleZone1, MiddleZone2, MiddleZone3})
        end, 5)
       return 
    end
    switchPlayers()
    createSbuttonsForCurrentPlayer()
end


function getAbilityZoneDeck()
    local objects = AbilityCardZone.getObjects()
    for i, object in ipairs(objects) do
        return object
    end
end

function SelectCard(creature)
    local savedData = JSON.decode(creature.getDescription())
    local typing = savedData["Type"]
    local abilityDeck = getAbilityZoneDeck()

    local selectedAbility
    for i, card in ipairs(abilityDeck.getObjects()) do
        local abilityCard = abilityDeck.takeObject({i})
        local abilityData = JSON.decode(abilityCard.getDescription())
        if(abilityData["Type"] == typing) then
            selectedAbility = abilityCard
            break
        else
            abilityCard.setPosition({-7.0,1,-2.0})
        end
    end

    selectedAbility.flip()
    creature.setLock(false)
    if currentPlayer == "White" then
        selectedAbility.setPosition({7.0,1,-14.0})
        creature.setPosition({7,1,-10}) 
        creature.setRotation({0, 180, 0})
        selectedAbility.setRotation({0, 90, 0})
    else
        creature.setPosition({7,1,8}) 
        selectedAbility.setPosition({7.0, 1, 12.0})
        selectedAbility.setRotation({0, -90, 0})
    end
end



