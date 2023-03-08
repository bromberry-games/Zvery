function SpawnAPDF(url, name, description)
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