----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: gui: client.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Mapper UI Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tocolor = tocolor,
    isElement = isElement,
    destroyElement = destroyElement,
    string = string,
    beautify = beautify
}


-------------------
--[[ Variables ]]--
-------------------

mapper.ui = {
    margin = 5,
    bgColor = imports.tocolor(6, 6, 6, 255),
    toolWnd = {
        font = availableFonts[1], fontColor = imports.tocolor(175, 175, 175, 255)
    },

    propWnd = {
        startX = 0, startY = 0,
        width = 265, height = 339,
        propLst = {
            text = imports.string.upper("Assets"),
            height = 300
        },
        spawnBtn = {
            text = "Spawn Asset",
            startY = 300 + 5,
            height = 24
        }
    },

    sceneWnd = {
        startX = 0, startY = 339,
        width = 265, height = 418,
        propLst = {
            text = imports.string.upper("Props"),
            height = 321
        },
        loadBtn = {
            text = "Load Scene",
            startY = 321 + 5 + 5,
            height = 24
        },
        resetBtn = {
            text = "Reset Scene",
            startY = 321 + 5 + 5 + 24 + 5,
            height = 24
        },
        saveBtn = {
            text = "Save Scene",
            startY = 321 + 5 + 5 + 24 + 5 + 24 + 5,
            height = 24
        }
    }
}

mapper.ui.propWnd.createUI = function()
    mapper.ui.propWnd.element = imports.beautify.card.create(mapper.ui.propWnd.startX, mapper.ui.propWnd.startY, mapper.ui.propWnd.width, mapper.ui.propWnd.height)
    imports.beautify.setUIVisible(mapper.ui.propWnd.element, true)
    imports.beautify.setUIDraggable(mapper.ui.propWnd.element, true)
    mapper.ui.propWnd.propLst.element = imports.beautify.gridlist.create(mapper.ui.margin, mapper.ui.margin, mapper.ui.propWnd.width - (mapper.ui.margin*2), mapper.ui.propWnd.propLst.height, mapper.ui.propWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.propWnd.propLst.element, true)
    imports.beautify.gridlist.addColumn(mapper.ui.propWnd.propLst.element, mapper.ui.propWnd.propLst.text, mapper.ui.propWnd.width - 2 - (mapper.ui.margin*2))
    for i = 1, #Assetify_Props, 1 do
        local j = Assetify_Props[i]
        local rowIndex = imports.beautify.gridlist.addRow(mapper.ui.propWnd.propLst.element)
        imports.beautify.gridlist.setRowData(mapper.ui.propWnd.propLst.element, rowIndex, 1, j)
    end
    imports.beautify.gridlist.setSelection(mapper.ui.propWnd.propLst.element, 1)
    mapper.ui.propWnd.spawnBtn.element = imports.beautify.button.create(mapper.ui.propWnd.spawnBtn.text, mapper.ui.margin, mapper.ui.margin + mapper.ui.propWnd.spawnBtn.startY, "default", mapper.ui.propWnd.width - (mapper.ui.margin*2), mapper.ui.propWnd.spawnBtn.height, mapper.ui.propWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.propWnd.spawnBtn.element, true)
    imports.beautify.render.create(function()
        imports.beautify.native.drawRectangle(0, 0, mapper.ui.propWnd.width, mapper.ui.propWnd.height, mapper.ui.bgColor, false)
    end, {
        elementReference = mapper.ui.propWnd.element,
        renderType = "preViewRTRender"
    })
end

mapper.ui.sceneWnd.createUI = function()
    mapper.ui.sceneWnd.element = imports.beautify.card.create(mapper.ui.sceneWnd.startX, mapper.ui.sceneWnd.startY, mapper.ui.sceneWnd.width, mapper.ui.sceneWnd.height)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.element, true)
    imports.beautify.setUIDraggable(mapper.ui.sceneWnd.element, true)
    mapper.ui.sceneWnd.propLst.element = imports.beautify.gridlist.create(mapper.ui.margin, mapper.ui.margin, mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.propLst.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.propLst.element, true)
    imports.beautify.gridlist.addColumn(mapper.ui.sceneWnd.propLst.element, mapper.ui.sceneWnd.propLst.text, mapper.ui.sceneWnd.width - 2 - (mapper.ui.margin*2))
    mapper.ui.sceneWnd.loadBtn.element = imports.beautify.button.create(mapper.ui.sceneWnd.loadBtn.text, mapper.ui.margin, mapper.ui.sceneWnd.loadBtn.startY, "default", mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.loadBtn.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.loadBtn.element, true)
    mapper.ui.sceneWnd.resetBtn.element = imports.beautify.button.create(mapper.ui.sceneWnd.resetBtn.text, mapper.ui.margin, mapper.ui.sceneWnd.resetBtn.startY, "default", mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.resetBtn.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.resetBtn.element, true)
    mapper.ui.sceneWnd.saveBtn.element = imports.beautify.button.create(mapper.ui.sceneWnd.saveBtn.text, mapper.ui.margin, mapper.ui.sceneWnd.saveBtn.startY, "default", mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.saveBtn.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.saveBtn.element, true)
    imports.beautify.render.create(function()
        imports.beautify.native.drawRectangle(0, 0, mapper.ui.sceneWnd.width, mapper.ui.sceneWnd.height, mapper.ui.bgColor, false)
    end, {
        elementReference = mapper.ui.sceneWnd.element,
        renderType = "preViewRTRender"
    })
end


-------------------------------------------
--[[ Functions: Renders Tool Window UI ]]--
-------------------------------------------

mapper.ui.renderToolWnd = function()
    imports.beautify.gridlist.setSelection(mapper.ui.sceneWnd.propLst.element, (mapper.isTargettingDummy and mapper.buffer.element[(mapper.isTargettingDummy)].id) or 0)
    imports.beautify.native.drawText("Selected Prop: "..(mapper.isTargettingDummy and imports.beautify.gridlist.getRowData(mapper.ui.sceneWnd.propLst.element, mapper.buffer.element[(mapper.isTargettingDummy)].id, 1) or "-").."\nTranslator Mode: "..((mapper.translationMode and mapper.translationMode.type and (((mapper.axis.validAxesTypes[(mapper.translationMode.type)] == "slate") and "Position") or "Rotation")) or "-").."\nTranslation Axis: "..((mapper.translationMode and mapper.translationMode.axis) or "-"), 0, mapper.ui.margin, CLIENT_MTA_RESOLUTION[1] - mapper.ui.margin, CLIENT_MTA_RESOLUTION[2], mapper.ui.toolWnd.fontColor, 1, mapper.ui.toolWnd.font, "right", "top", true, true, false)
end


----------------------------------------
--[[ Functions: Creates/Destroys UI ]]--
----------------------------------------

mapper.ui.create = function()
    mapper.ui.propWnd.createUI()
    mapper.ui.sceneWnd.createUI()
end

mapper.ui.destroy = function()
    if mapper.ui.propWnd.element and imports.isElement(mapper.ui.propWnd.element) then
        imports.destroyElement(mapper.ui.propWnd.element)
    end
    if mapper.ui.sceneWnd.element and imports.isElement(mapper.ui.sceneWnd.element) then
        imports.destroyElement(mapper.ui.sceneWnd.element)
    end
end