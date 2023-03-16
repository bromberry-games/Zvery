local Decker = require("decker")
local Helpers = require("helpers")
local CreaturesScript = require("creatures")
local AbilitiesScript = require("abilities")
local Spawner = require("spawner")

local mutationDeckLink = 'https://raw.githubusercontent.com/bromberry-games/Zvery/master/tts/mutation-full-grid.png'
local creatureDeckLink = 'https://raw.githubusercontent.com/bromberry-games/Zvery/master/tts/creature-full-grid.png'
local Game = {}

local abilityDeckLink = 'https://raw.githubusercontent.com/bromberry-games/Zvery/master/tts/adaptation-full-grid.png'
local backTemplate = 'https://raw.githubusercontent.com/bromberry-games/Zvery/master/ivan-svg-templates/back-templates/card-back.png'
local rulesLink = 'https://raw.githubusercontent.com/bromberry-games/Zvery/master/rules-new-structure/rules.pdf'


local state = {
    currentPlayer = "",
    otherPlayer = "",
    playersSetup = 0,
    selectedAt = 0, 
    mutationSelectedCount = 0,
    selectedLevel = 0,

    creatureZonesGUID = {},
    creatureDeckZonesGUIDs = {},
    fightCreatureButtonsGUIDs = {},
    abilityDeckZoneGUID = 0,

    mutationZonesGUIDS = {},
    mutationButtonsGUIDs = {},
    mutationDeckGUID = 0,

    selectedStartButtonsGUIDs = {},
    middleZonesGUID = {},
}
local creatureZones = {}
local creatureDeckZones = {}
local fightCreatureButtons = {}
local abilityDeckZone = ""

local mutationZones = {}
local mutationButtons = {}
local mutationDeck = ""

local selectedStartButtons = {}
local middleZones = {}

local function showEndTurnButton()
    UI.show("end-turn-button")
    UI.setAttribute("end-turn-button", "visibility", state.currentPlayer)
end

function Game.OnLoad(save)
    local savestate = JSON.decode(save)
    state = savestate.state
    if state.creatureDeckZonesGUIDs == nil then
        return
    end

    creatureZones = Helpers.GetObjectsFromGUIDs(state.creatureZonesGUID)
    creatureDeckZones = Helpers.GetObjectsFromGUIDs(state.creatureDeckZonesGUIDs)
    fightCreatureButtons = Helpers.GetObjectsFromGUIDs(state.fightCreatureButtonsGUIDs)
    abilityDeckZone = getObjectFromGUID(state.abilityDeckZoneGUID)

    mutationZones = Helpers.GetObjectsFromGUIDs(state.mutationZonesGUIDS)
    mutationButtons = Helpers.GetObjectsFromGUIDs(state.mutationButtonsGUIDs)
    mutationDeck = getObjectFromGUID(state.mutationDeckGUID)
    selectedStartButtons = Helpers.GetObjectsFromGUIDs(state.selectedStartButtonsGUIDs)
    middleZones = Helpers.GetObjectsFromGUIDs(state.middleZonesGUID)


    if state.mutationSelectedCount >= state.selectedLevel then
        Helpers.DestroyAllInTable(mutationButtons) 
        showEndTurnButton()
    else
        UI.hide("end-turn-button")
    end
end

function Game.OnSave()
    if abilityDeckZone == nil or abilityDeckZone == "" then
        return JSON.encode({
            nosave = 0      
        })
    end
    state.creatureZonesGUID = Helpers.GetGUIDsTable(creatureZones)
    state.creatureDeckZonesGUIDs = Helpers.GetGUIDsTable(creatureDeckZones)
    state.fightCreatureButtonsGUIDs = Helpers.GetGUIDsTable(fightCreatureButtons)
    state.abilityDeckZoneGUID = abilityDeckZone.getGUID()

    state.mutationZonesGUIDS = Helpers.GetGUIDsTable(mutationZones)
    state.mutationButtonsGUIDs = Helpers.GetGUIDsTable(mutationButtons)
    state.selectedStartButtonsGUIDs = Helpers.GetGUIDsTable(selectedStartButtons)
    state.mutationDeckGUID = mutationDeck.getGUID()
    state.middleZonesGUID = Helpers.GetGUIDsTable(middleZones)
    return JSON.encode(
        {state = state}
    )
end

local function initVars()
    local rand = math.random()
    state = {}
    if rand < 0.5 then
        state.currentPlayer = "White"
        state.otherPlayer = "Blue"
    else
        state.currentPlayer = "Blue"
        state.otherPlayer = "White"
    end
    state.playersSetup = 0
    state.selectedAt = 0
    state.selectedLevel = 0
    state.mutationSelectedCount = -1 --init at -1 to hide end turn button on load

    middleZones = {}
    creatureZones = {}
    creatureDeckZones = {}
    fightCreatureButtons = {}
    mutationZones = {}
    mutationButtons = {}
    selectedStartButtons = {}
    UI.hide("end-turn-button")
end

-- Positions --
local zSpacing = 4.0
local xSpacing = 4.0
local middlePosZ = 0.0 
local middlePosX = 0.0

local abilityDeckPos = {middlePosX - 18.0, 1, middlePosZ}

local lvlX = middlePosX - 14.0
local lvlOnePos = {lvlX, 0, middlePosZ - zSpacing}
local lvlTwoPos = {lvlX, 0, middlePosZ}
local lvlThreePos = {lvlX, 0, middlePosZ + zSpacing}

local creatureX = middlePosX - 10.0
local creaturePositions = {
    {creatureX, 1, middlePosZ - zSpacing},
    {creatureX, 1, middlePosZ},
    {creatureX, 1, middlePosZ + zSpacing}
}
local referenceBluePos = {creatureX, 1, middlePosZ + 2* zSpacing} 

local middlePos1 = {middlePosX - xSpacing, 1.0, middlePosZ}
local middlePos2 = {middlePosX, 1.0, middlePosZ}
local middlePos3 = {middlePosX + xSpacing, 1.0, middlePosZ}

local mutationX = middlePosX + 10
local mutationPositions = {
    {mutationX, 1, middlePosZ + zSpacing},
    {mutationX, 1, middlePosZ},
    {mutationX,1, middlePosZ - zSpacing}
}
local referenceWhitePos = {mutationX, 1, middlePosZ - 2* zSpacing}
local mutationDeckPos = {mutationX + xSpacing,1,middlePosZ}
local rulesPos = {mutationX + 2*xSpacing,1,middlePosZ}

local discardPilePos = {middlePosX + 14.0,1, middlePosZ + zSpacing}

local creature1X = middlePosX - 4.0
local whiteCreature1Pos = {creature1X, 1, middlePosZ - 2*zSpacing}
local whiteAbilityPos = {creature1X, 1, whiteCreature1Pos[3] - 0.65 * zSpacing}

local blueCreature1Pos = {creature1X, 1, middlePosZ + 2*zSpacing}
local blueAbilityPos = {creature1X, 1, blueCreature1Pos[3] + 0.65 * zSpacing}
-- Positions end --


local function switchPlayers()
   local temp = state.currentPlayer 
   state.currentPlayer = state.otherPlayer
   state.otherPlayer = temp
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

local function createReferenceSheets()
    Spawner.ReferenceSheet(referenceBluePos)
    local card = Spawner.ReferenceSheet(referenceWhitePos)
    card.setRotation({0,180,0})
end

local function createRules()
    local rules = Spawner.PDF(rulesLink,"rules", "DA rules")
    rules.setPosition(rulesPos)
end

local function createStatsCards()
    for i = 1, 4, 1 do
        Spawner.StatsCard({mutationDeckPos[1], 1, mutationDeckPos[3] - zSpacing})
    end
    for i = 1, 4, 1 do
        for j = 1, 4, 1 do
            Spawner.GoPiece({mutationDeckPos[1] + xSpacing * (0.6 + i * 0.1), 1, mutationDeckPos[3] - zSpacing * (0.6 + 0.1 * j)})
        end
    end
end

local function createTablet()
   Spawner.Tablet({rulesPos[1] + 2*xSpacing, 1, rulesPos[3]})
end

function GameSetup()
    initVars()
    local creatureDeck =  SpawnDeck(creatureDeckLink)
    ParseCreatureDeck(creatureDeck, Creatures)
    setupAbilityDeck()
    setupMutationDeck()
    createRules()
    createReferenceSheets()
    createStatsCards()
    createTablet()
    local zStartBlue = middlePosZ - 8
    local zStartWhite = middlePosZ + 8
    for i = 1, 5, 1 do
        spawnObject({
            type = "Die_6",
            position = {middlePosX + 14,i,zStartBlue},
        }).use_grid = false
        spawnObject({
            type = "Die_6",
            position = {middlePosX - 14.0,i, zStartWhite},
        }).use_grid = false
    end
end

function setupAbilityDeck()
    local abilityDeck = SpawnDeck(abilityDeckLink)
    local customObject = abilityDeck.getCustomObject()[1]
    customObject.sideways = true
    abilityDeck.setCustomObject(customObject)
    local len = #Abilities + 1
    for i, card in ipairs(Abilities) do
        card = abilityDeck.takeObject({i})
        card.setName(Abilities[len - i].Name)
        local jsonData = JSON.encode(Abilities[len - i])
        card.setDescription(jsonData)
        card.setPosition(abilityDeckPos)
        card.flip()
    end
    abilityDeckZone = Helpers.CreateScriptingZoneAtPosition(abilityDeckPos, "Ability Card Zone")
end

function setupMutationDeck()
    mutationDeck = SpawnDeck(mutationDeckLink)
    mutationDeck.setPosition(mutationDeckPos)
    mutationDeck.flip()
    mutationDeck.shuffle()
    for index, value in ipairs(mutationPositions) do
       mutationDeck.takeObject({index - 1}).setPosition(value) 
       mutationZones[index] = Helpers.CreateScriptingZoneAtPosition(value, "Mutation Card Zone " .. index)
    end
end

function SpawnDeck(cardFaces)
    local cardAsset = Decker.Asset(cardFaces, backTemplate, {width = 10, height = 5})
    local myDeck = Decker.AssetDeck(cardAsset,45)
    return myDeck:spawn({position = {-4, 3, 0}, hands = false})
end

function ParseCreatureDeck(creatureDeck, creatures)
    local objects = creatureDeck.getObjects()

    local zoneLvl1 = Helpers.CreateScriptingZoneAtPosition(lvlOnePos, "ZoneLvl1")
    local zoneLvl2 = Helpers.CreateScriptingZoneAtPosition(lvlTwoPos, "ZoneLvl2")
    local zoneLvl3 = Helpers.CreateScriptingZoneAtPosition(lvlThreePos, "ZoneLvl3")
    table.insert(creatureDeckZones, zoneLvl1)
    table.insert(creatureDeckZones, zoneLvl2)
    table.insert(creatureDeckZones, zoneLvl3)

    local len = #creatures + 1
    for i, card in ipairs(objects) do
        local tempCard = creatureDeck.takeObject({
            i
        })
        local creature = creatures[len - i] 
        if tempCard == nil then
            print("Card is null")
        elseif  creature.TexturePath == nil then
            tempCard.destruct()
        else
            tempCard.setName(creature.Name)
            local jsonData = JSON.encode(creature)
            tempCard.setDescription(jsonData)
            if(creature.Level == 1) then
                tempCard.setPosition(lvlOnePos)
            elseif (creature.Level == 2) then
                tempCard.setPosition(lvlTwoPos)
            else 
                tempCard.setPosition(lvlThreePos)
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


function setupLvl3(zoneLvl3)
   local deck = Helpers.ShuffleDeckInZone(zoneLvl3) 
   Helpers.LockAndFloor(deck)
end

local function createSbuttonsForcurrentPlayer() 
    selectedStartButtons = {}
    local offset = 0
    if state.currentPlayer == 'White' then
        offset = -3.0
    else
        offset = 3.0
    end
    if state.selectedAt ~= 1 then
        selectedStartButtons[1] = Spawner.SelectButton({middlePos1[1],1,middlePos1[3] + offset}, "SelectCreatureAtZone" .. 1, state.otherPlayer)
    end
    if state.selectedAt ~= 2 then
        selectedStartButtons[2] = Spawner.SelectButton({middlePos2[1],1,middlePos2[3] + offset}, "SelectCreatureAtZone" .. 2,state.otherPlayer)
    end
    if state.selectedAt ~= 3 then
        selectedStartButtons[3] = Spawner.SelectButton({middlePos3[1],1,middlePos3[3] + offset}, "SelectCreatureAtZone" .. 3,state.otherPlayer)
    end
end

local function takeCardFromDeckAndSetPosition(deck, selectedAt, position)--TODO: does this even work properly?
    local card = deck.takeObject({selectedAt})
    card.setPosition(position)
    card.setLock(true)
    card.use_hands = false
    return card
end

function setupLvl2(zoneLvl2)
    local deck = Helpers.ShuffleDeckInZone(zoneLvl2) 

    takeCardFromDeckAndSetPosition(deck,0,middlePos1)
    takeCardFromDeckAndSetPosition(deck,1,middlePos2)
    takeCardFromDeckAndSetPosition(deck,2,middlePos3)

    middleZones[1] = Helpers.CreateScriptingZoneAtPosition(middlePos1, "Middle-Zone1")
    middleZones[2] = Helpers.CreateScriptingZoneAtPosition(middlePos2, "Middle-Zone2")
    middleZones[3] = Helpers.CreateScriptingZoneAtPosition(middlePos3, "Middle-Zone3")

    createSbuttonsForcurrentPlayer()
end

function setupLvl1(zoneLvl1)
    local deck = Helpers.ShuffleDeckInZone(zoneLvl1)

    deck.takeObject({0}).setPosition(creaturePositions[1])
    deck.takeObject({1}).setPosition(creaturePositions[2])
    deck.takeObject({2}).setPosition(creaturePositions[3])

    table.insert(creatureZones, Helpers.CreateScriptingZoneAtPosition(creaturePositions[1], "Creature Zone 1"))
    table.insert(creatureZones, Helpers.CreateScriptingZoneAtPosition(creaturePositions[2], "Creature Zone 2"))
    table.insert(creatureZones, Helpers.CreateScriptingZoneAtPosition(creaturePositions[3], "Creature Zone 3"))
end

function SelectCreatureAtZone1()
    state.selectedAt = 1
    SelectCreatureAtZoneAndManageGame(middleZones[1])
end

function SelectCreatureAtZone2()
    state.selectedAt = 2
    SelectCreatureAtZoneAndManageGame(middleZones[2])
end

function SelectCreatureAtZone3()
    state.selectedAt = 3
    SelectCreatureAtZoneAndManageGame(middleZones[3])
end

local function moveCardsFromZonesToDiscard(zones)
    for i, zone in ipairs(zones) do
        local creature = Helpers.SelectFirstObjectInZone(zone)
        if creature ~= nil then
            creature.setPosition(discardPilePos)
        end
    end
end

local function createSelectMutationButtons()
    state.mutationSelectedCount = 0
    mutationButtons = {}
    if state.selectedLevel == 3 then
        SelectMutation1()
        SelectMutation2()
        SelectMutation3()
        return
    end
    for i, mutationZone in ipairs(mutationZones) do
        local mutationPos = mutationZone.getPosition()
        local button = Spawner.SelectButton({mutationPos[1] - 3.0, mutationPos[2], mutationPos[3]}, "SelectMutation" .. i,state.otherPlayer)
        table.insert(mutationButtons, button)
    end
end

local function refillMutations()
    for _, mutationZone in ipairs(mutationZones) do
        if Helpers.ZoneIsEmpty(mutationZone) then        
           local mutation = mutationDeck.takeObject({index = 0})
           mutation.setPosition(mutationZone.getPosition())
           mutation.flip()
        end
    end
end

local function refillCreatures()
    for _, creatureZone in ipairs(creatureZones) do
        if Helpers.ZoneIsEmpty(creatureZone) then
            if state.selectedLevel ~= 3 then
               local creature = Helpers.SelectFirstObjectInZone(creatureDeckZones[state.selectedLevel + 1]).takeObject({index = 0}) 
               creature.setPosition(creatureZone.getPosition())
               creature.flip()
            end
        end
    end 
end



local function selectMutationAtZone(index)
    local mutation = Helpers.SelectFirstObjectInZone(mutationZones[index]) 
    local playerDirection = state.currentPlayer == 'White' and -1 or 1
    mutation.setRotation({0, 90, 0})
    mutation.setPosition({middlePos1[1] + xSpacing * state.mutationSelectedCount, 1, middlePos1[3] +  zSpacing * playerDirection})
    state.mutationSelectedCount = state.mutationSelectedCount + 1
    if #mutationButtons == 0 then
        return
    elseif state.mutationSelectedCount >= state.selectedLevel then
        Helpers.DestroyAllInTable(mutationButtons) 
        showEndTurnButton()
    else
        mutationButtons[index].destruct()
        table.remove(mutationButtons, index)
   end
end

function SelectMutation1()
    selectMutationAtZone(1)
end

function SelectMutation2()
    selectMutationAtZone(2)
end

function SelectMutation3()
    selectMutationAtZone(3)
end
    
local function selectCreatureToFightAtZone(zone)
    if(state.currentPlayer == 'White') then
        state.selectedLevel = SelectCreatureWithAbility(
            Helpers.SelectFirstObjectInZone(zone), {middlePos1[1], 1, middlePos1[3] + 0.65 * zSpacing}, middlePos1, -1
        )
    elseif (state.currentPlayer == 'Blue') then
        state.selectedLevel = SelectCreatureWithAbility(Helpers.SelectFirstObjectInZone(zone), {middlePos1[1], 1, middlePos1[3] - 0.65 * zSpacing}, middlePos1, 1)
    end
    Helpers.DestroyAllInTable(fightCreatureButtons)
    createSelectMutationButtons()
end

function SelectCreatureToFight1()
    selectCreatureToFightAtZone(creatureZones[1])
end

function SelectCreatureToFight2()
    selectCreatureToFightAtZone(creatureZones[2])
end

function SelectCreatureToFight3()
    selectCreatureToFightAtZone(creatureZones[3])
end

local function createFightCreatureButtons()
    fightCreatureButtons = {}
    for i, creatureZone in ipairs(creatureZones) do
        local creaturePos = creatureZone.getPosition()
        local button = Spawner.SelectButton({creaturePos[1] + 3.0, creaturePos[2], creaturePos[3]}, "SelectCreatureToFight" .. i,state.otherPlayer)
        table.insert(fightCreatureButtons, button)
    end
end

function EndTurn()
    refillMutations()
    refillCreatures()
    UI.hide("end-turn-button")
    switchPlayers()
    createFightCreatureButtons()
end


function SelectCreatureAtZoneAndManageGame(zone)
    if(state.currentPlayer == 'White') then
        SelectCreatureWithAbility(Helpers.SelectFirstObjectInZone(zone), whiteAbilityPos, whiteCreature1Pos, 1)
    elseif state.currentPlayer == 'Blue' then
        SelectCreatureWithAbility(Helpers.SelectFirstObjectInZone(zone), blueAbilityPos, blueCreature1Pos, -1)
    end

    state.playersSetup = state.playersSetup + 1
    Helpers.DestroyAllInTable(selectedStartButtons)
    if state.playersSetup == 2 then
        Wait.frames(function ()
            moveCardsFromZonesToDiscard({middleZones[1], middleZones[2], middleZones[3]})
        end, 5)
        createFightCreatureButtons()
       return 
    end
    switchPlayers()
    createSbuttonsForcurrentPlayer()
end


function getAbilityZoneDeck()
    local objects = abilityDeckZone.getObjects()
    for i, object in ipairs(objects) do
        return object
    end
end

local function getFirstCardFromDeckWithType(deck, typing)
    for i, card in ipairs(deck.getObjects()) do
        local abilityData = JSON.decode(card.description)
        if(abilityData["Type"] == typing) then
            return deck.takeObject({index = i - 1})
        end
    end
end

local function setCreatureAndAbilityToPos(ability, abilityPos, creature, creaturePos, creatureData, direction)
    ability.setPosition(abilityPos)
    creature.setPosition(creaturePos) 
    Spawner.D20ForCreature(creaturePos, creatureData, direction)
    creature.addAttachment(ability)
end

function SelectCreatureWithAbility(creature, abilityPos, creaturePos, rotationScalar)
    local savedData = JSON.decode(creature.getDescription())
    local typing = savedData["Type"]
    local abilityDeck = getAbilityZoneDeck()

    local selectedAbility = getFirstCardFromDeckWithType(abilityDeck, typing)
    selectedAbility.flip()

    creature.setLock(false)
    creature.setRotation({0, 180 * 1/2 * (rotationScalar + 1), 0})
    selectedAbility.setRotation({0, 90 * rotationScalar, 0})
    setCreatureAndAbilityToPos(selectedAbility, abilityPos, creature, creaturePos, savedData, rotationScalar)
    return savedData["Level"]
end



return Game