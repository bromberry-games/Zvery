local Spawner = {}


local refernceSheetLink ='https://raw.githubusercontent.com/bromberry-games/Zvery/master/ivan-svg-templates/reference-sheet/reference-sheet.png'
local statsCardLink = 'https://raw.githubusercontent.com/bromberry-games/Zvery/master/ivan-svg-templates/stat-card/stat-card.png'

local tabletOpenUrl = 'https://github.com/bromberry-games/Zvery/issues'

function Spawner.PDF(url, name, description)
    local myjson = [[
        {
          "Name": "Custom_PDF",
          "Transform": {
            "posX": 0.0,
            "posY": 0.0,
            "posZ": 0.0,
            "rotX": 0.0,
            "rotY": 0.0,
            "rotZ": 0.0,
            "scaleX": 1.0,
            "scaleY": 1.0,
            "scaleZ": 1.0
          },
          "Nickname": "]]..name..[[",
          "Description": "]]..description..[[",
          "GMNotes": "",
          "ColorDiffuse": {
            "r": 1.0,
            "g": 1.0,
            "b": 1.0
          },
          "Locked": false,
          "Grid": true,
          "Snap": true,
          "IgnoreFoW": false,
          "Autoraise": true,
          "Sticky": true,
          "Tooltip": true,
          "GridProjection": false,
          "HideWhenFaceDown": false,
          "Hands": false,
          "CustomPDF": {
            "PDFUrl": "]]..url..[[",
            "PDFPassword": "",
            "PDFPage": 0,
            "PDFPageOffset": 0
          },
          "XmlUI": "<!-- -->",
          "LuaScript": "--foo",
          "LuaScriptState": "",
          "GUID": "pdf001"
        }]]
    return spawnObjectJSON({
        json = myjson,
        position = {0, 5, 0},
    })
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


function Spawner.SelectButton(pos, functionName, invisbleTo)
    local checker = spawnObject({type="Checker_black", name="SelectButton"})
    checker.setPosition(pos)
    checker.setInvisibleTo({invisbleTo})
    checker.setLock(true)
    local params = {
        label = "Select",
        click_function = functionName,
        --function_owner = self,
        position = {0,1,0},
        rotation = {0, 180, 0},
        height = 440,
        width = 1000,
        font_size = 260,
        font_color = fontColor,
        color = buttonColor,
    }
    local paramstring = JSON.encode(params)
    checker.setLuaScript([[
        params = ']] .. paramstring .. [['
        function onLoad()
            self.createButton(JSON.decode(params))
        end
    ]])
    return checker
end

function Spawner.D20ForCreature(position, creatureData, direction)
    local dice = spawnObject({
        type = "Die_20",
        position = {position[1] + direction * 0.8 * (-1), position[2], position[3] + direction * 1.2},
    })
    local typing = creatureData["Type"]
    if typing == "Bubblegum" then
        dice.setColorTint({255 / 255, 77 / 255, 128 / 255})
    elseif typing == "Void" then
        dice.setColorTint({103 / 255, 58 / 255, 177 / 255})
    elseif typing == "Radioactive" then
        dice.setColorTint({67 / 255, 249 / 255, 156 / 255})
    elseif typing == "Plasma" then
        dice.setColorTint({67 / 255, 114 / 255, 238 / 255})
    elseif typing == "crystal" then
        dice.setColorTint({249 / 255, 220 / 255, 92 / 255})
    end
    dice.setValue(creatureData["Health"])
    dice.use_grid = false
    return dice
end

function Spawner.GoPiece(position)
   local piece = spawnObject({
       type = "go_game_piece_white",
       position = position,
   }) 
   piece.setScale({0.3, 0.3, 0.3})
   piece.use_grid = false
   return piece
end

function Spawner.Tablet(pos)
   local tablet = spawnObject({
       type = "tablet",
       position = pos
   }) 
   tablet.Browser.url = tabletOpenUrl
   return tablet
end


function Spawner.ReferenceSheet(position)
    local card = spawnObject({
      type = "card",
      position = position,
      name = "ReferenceSheet",
    })
    card.setCustomObject({
      face = refernceSheetLink,
      back = refernceSheetLink
    })
    return card
end

function Spawner.StatsCard(pos)
   local card = spawnObject({
      type = "card",
      position = pos,
      name = "StatsCard",
   }) 
   card.setCustomObject({
      face = statsCardLink,
      back = statsCardLink
   })
end

return Spawner