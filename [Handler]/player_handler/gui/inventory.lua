----------------------------------------------------------------
--[[ Resource: Player Handler
     Script: gui: inventory.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril, Аниса
     DOC: 31/01/2022
     Desc: Inventory UI Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tocolor = tocolor,
    unpackColor = unpackColor,
    isElement = isElement,
    destroyElement = destroyElement,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    collectgarbage = collectgarbage,
    triggerServerEvent = triggerServerEvent,
    triggerEvent = triggerEvent,
    bindKey = bindKey,
    getPlayerName = getPlayerName,
    isKeyOnHold = isKeyOnHold,
    isMouseClicked = isMouseClicked,
    isMouseScrolled = isMouseScrolled,
    isMouseOnPosition = isMouseOnPosition,
    interpolateBetween = interpolateBetween,
    getInterpolationProgress = getInterpolationProgress,
    getAbsoluteCursorPosition = getAbsoluteCursorPosition,
    showChat = showChat,
    showCursor = showCursor,
    beautify = beautify,
    string = string,
    table = table,
    math = math
}


CGame.execOnModuleLoad(function()
    -------------------
    --[[ Variables ]]--
    -------------------

    local inventory_margin = 4
    local inventory_offsetX, inventory_offsetY = CInventory.fetchSlotDimensions(2, 6)
    local vicinity_slotSize = inventory_offsetY
    inventory_offsetY = inventory_offsetY + FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.slot.height + inventory_margin
    local inventoryUI = {
        cache = {keys = {scroll = {}}},
        buffer = {},
        margin = inventory_margin,
        titlebar = {
            height = FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.height,
            font = CGame.createFont(1, 19), fontColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.fontColor)),
            bgColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.bgColor)),
            slot = {
                height = FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.slot.height,
                fontPaddingY = 2, font = CGame.createFont(1, 16), fontColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.slot.fontColor)),
                bgColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.slot.bgColor))
            }
        },
        scroller = {
            width = FRAMEWORK_CONFIGS["UI"]["Inventory"].scroller.width, thumbHeight = FRAMEWORK_CONFIGS["UI"]["Inventory"].scroller.thumbHeight,
            bgColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].scroller.bgColor)), thumbColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].scroller.thumbColor))
        },
        clientInventory = {
            startX = 0, startY = -inventory_offsetY,
            bgColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.bgColor)), dividerColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerColor)),
            lockStat = {
                lockTexture = imports.beautify.assets["images"]["canvas/lock.rw"], unlockTexture = imports.beautify.assets["images"]["canvas/unlock.rw"]
            },
            equipment = {
                {identifier = "helmet", slots = {rows = 2, columns = 2}},
                {identifier = "vest", slots = {rows = 2, columns = 2}},
                {identifier = "upper", slots = {rows = 2, columns = 2}},
                {identifier = "lower", slots = {rows = 2, columns = 2}},
                {identifier = "shoes", slots = {rows = 2, columns = 2}},
                {identifier = "primary", slots = {rows = 2, columns = 6}},
                {identifier = "secondary", slots = {rows = 2, columns = 4}},
                {identifier = "backpack", slots = {rows = 3, columns = 3}}
            }
        },
        vicinityInventory = {
            width = inventory_offsetX,
            slotNameTexture = imports.beautify.native.createTexture("files/images/inventory/ui/vicinity/slot_name.rw", "argb", true, "clamp"),
            slotNameFont = CGame.createFont(1, 18), slotNameFontColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotNameFontColor)),
            slotSize = vicinity_slotSize, slotColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotColor)),
            bgColor = imports.tocolor(imports.unpackColor(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.bgColor))
        },
        opacityAdjuster = {
            startX = 10, startY = 0,
            width = 27,
            range = {50, 100}
        }
    }
    inventory_margin, inventory_offsetX, inventory_offsetY, vicinity_slotSize = nil, nil, nil, nil

    inventoryUI.clientInventory.width, inventoryUI.clientInventory.height = CInventory.fetchSlotDimensions(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.rows, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns)
    inventoryUI.clientInventory.startX, inventoryUI.clientInventory.startY = inventoryUI.clientInventory.startX + ((CLIENT_MTA_RESOLUTION[1] - inventoryUI.clientInventory.width)*0.5) + (inventoryUI.clientInventory.width*0.5), ((CLIENT_MTA_RESOLUTION[2] + inventoryUI.clientInventory.startY - inventoryUI.clientInventory.height - inventoryUI.titlebar.height)*0.5)
    inventoryUI.clientInventory.lockStat.size = inventoryUI.titlebar.height*0.5
    inventoryUI.clientInventory.lockStat.startX, inventoryUI.clientInventory.lockStat.startY = inventoryUI.clientInventory.width - inventoryUI.clientInventory.lockStat.size, -inventoryUI.titlebar.height + ((inventoryUI.titlebar.height - inventoryUI.clientInventory.lockStat.size)*0.5)
    for i = 1, #inventoryUI.clientInventory.equipment, 1 do
        local j = inventoryUI.clientInventory.equipment[i]
        j.width, j.height = CInventory.fetchSlotDimensions(j.slots.rows, j.slots.columns)
    end
    local equipment_prevX, equipment_prevY = -inventoryUI.margin, inventoryUI.titlebar.slot.height + inventoryUI.clientInventory.equipment[1].height + inventoryUI.margin
    for i = 5, 1, -1 do
        local j = inventoryUI.clientInventory.equipment[i]
        j.startX, j.startY = (-inventoryUI.margin*2) - j.width, inventoryUI.clientInventory.startY + inventoryUI.clientInventory.height + inventoryUI.margin - j.height + equipment_prevY
        equipment_prevY = equipment_prevY - j.height - (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize*0.5) - inventoryUI.titlebar.slot.height
    end
    equipment_prevY = nil
    for i = 6, 7, 1 do
        local j = inventoryUI.clientInventory.equipment[i]
        j.startX, j.startY = equipment_prevX, inventoryUI.clientInventory.equipment[5].startY
        equipment_prevX = equipment_prevX + (inventoryUI.margin*2) - FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize + j.width
    end
    equipment_prevX = nil
    equipment_prevY = -inventoryUI.titlebar.slot.height - inventoryUI.margin
    for i = 8, 8, 1 do
        local j = inventoryUI.clientInventory.equipment[i]
        j.startX, j.startY = inventoryUI.clientInventory.width + (inventoryUI.margin*2), inventoryUI.clientInventory.equipment[5].startY - j.height + equipment_prevY
        equipment_prevY = equipment_prevY - j.height - (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize*0.5) - inventoryUI.titlebar.slot.height
    end
    equipment_prevY = nil
    for i = 1, #inventoryUI.clientInventory.equipment, 1 do
        local j = inventoryUI.clientInventory.equipment[i]
        j.startX, j.startY = inventoryUI.clientInventory.startX + j.startX, inventoryUI.clientInventory.startY + j.startY
    end
    inventoryUI.vicinityInventory.startX, inventoryUI.vicinityInventory.startY = inventoryUI.clientInventory.equipment[1].startX - inventoryUI.vicinityInventory.width - inventoryUI.margin - FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize, inventoryUI.clientInventory.startY
    inventoryUI.vicinityInventory.height = inventoryUI.clientInventory.equipment[6].startY + inventoryUI.clientInventory.equipment[6].height - inventoryUI.vicinityInventory.startY - inventoryUI.titlebar.height - inventoryUI.margin
    inventoryUI.opacityAdjuster.startX, inventoryUI.opacityAdjuster.startY = inventoryUI.opacityAdjuster.startX + inventoryUI.clientInventory.startX + inventoryUI.clientInventory.width - inventoryUI.margin, inventoryUI.clientInventory.startY + inventoryUI.opacityAdjuster.startY - inventoryUI.margin
    inventoryUI.opacityAdjuster.height = inventoryUI.clientInventory.equipment[8].startY - inventoryUI.opacityAdjuster.startY - inventoryUI.margin - inventoryUI.titlebar.slot.height
    inventoryUI.createBGTexture = function(isRefresh)
        if CLIENT_MTA_MINIMIZED then return false end
        if isRefresh then
            if inventoryUI.bgTexture and imports.isElement(inventoryUI.bgTexture) then
                imports.destroyElement(inventoryUI.bgTexture)
                inventoryUI.bgTexture = nil
            end
        end
        inventoryUI.bgRT = imports.beautify.native.createRenderTarget(CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], true)
        imports.beautify.native.setRenderTarget(inventoryUI.bgRT, true)
        local client_startX, client_startY = inventoryUI.clientInventory.startX - inventoryUI.margin, inventoryUI.clientInventory.startY + inventoryUI.titlebar.height - inventoryUI.margin
        local client_width, client_height = inventoryUI.clientInventory.width + (inventoryUI.margin*2), inventoryUI.clientInventory.height + (inventoryUI.margin*2)
        imports.beautify.native.drawRectangle(client_startX, client_startY - inventoryUI.titlebar.height, client_width, inventoryUI.titlebar.height, inventoryUI.titlebar.bgColor, false)
        imports.beautify.native.drawRectangle(client_startX, client_startY, client_width, client_height, inventoryUI.clientInventory.bgColor, false)
        for i = 1, #inventoryUI.clientInventory.equipment, 1 do
            local j = inventoryUI.clientInventory.equipment[i]
            local title_height = inventoryUI.titlebar.slot.height
            local title_startY = j.startY - inventoryUI.titlebar.slot.height
            j.title = imports.string.upper(imports.string.spaceChars(j.identifier))
            imports.beautify.native.drawRectangle(j.startX, title_startY, j.width, title_height, inventoryUI.titlebar.slot.bgColor, false)
            imports.beautify.native.drawRectangle(j.startX, j.startY, j.width, j.height, inventoryUI.clientInventory.bgColor, false)
            for k = 1, j.slots.rows - 1, 1 do
                imports.beautify.native.drawRectangle(j.startX, j.startY + ((FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize + FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize)*k), j.width, 1, inventoryUI.clientInventory.dividerColor, false)
            end
            for k = 1, j.slots.columns - 1, 1 do
                imports.beautify.native.drawRectangle(j.startX + ((FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize + FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize)*k), j.startY, 1, j.height, inventoryUI.clientInventory.dividerColor, false)
            end
        end
        inventoryUI.vicinityInventory.bgTexture = (inventoryUI.vicinityInventory.element and true) or false
        if inventoryUI.vicinityInventory.bgTexture then
            local vicinity_startX, vicinity_startY = inventoryUI.vicinityInventory.startX - (inventoryUI.margin*2), inventoryUI.vicinityInventory.startY + inventoryUI.titlebar.height - inventoryUI.margin
            local vicinity_width, vicinity_height = inventoryUI.vicinityInventory.width + (inventoryUI.margin*2), inventoryUI.vicinityInventory.height + (inventoryUI.margin*2)
            imports.beautify.native.drawRectangle(vicinity_startX, vicinity_startY - inventoryUI.titlebar.height, vicinity_width, inventoryUI.titlebar.height, inventoryUI.titlebar.bgColor, false)
            imports.beautify.native.drawRectangle(vicinity_startX, vicinity_startY, vicinity_width, vicinity_height, inventoryUI.vicinityInventory.bgColor, false)
        end
        imports.beautify.native.drawRectangle(inventoryUI.opacityAdjuster.startX, inventoryUI.opacityAdjuster.startY, inventoryUI.opacityAdjuster.width, inventoryUI.opacityAdjuster.height, inventoryUI.titlebar.bgColor, false)
        imports.beautify.native.setRenderTarget()
        local rtPixels = imports.beautify.native.getTexturePixels(inventoryUI.bgRT)
        if rtPixels then
            inventoryUI.bgTexture = imports.beautify.native.createTexture(rtPixels, "dxt5", false, "clamp")
            imports.destroyElement(inventoryUI.bgRT)
            inventoryUI.bgRT = nil
        end
        if not inventoryUI.gridTexture then
            inventoryUI.gridWidth, inventoryUI.gridHeight = (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize*FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.rows) + (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize*math.max(0, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.rows - 1)), (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize*FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns) + (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize*math.max(0, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns - 1))
            inventoryUI.gridRT = imports.beautify.native.createRenderTarget(inventoryUI.gridWidth, inventoryUI.gridHeight, true)
            imports.beautify.native.setRenderTarget(inventoryUI.gridRT, true)
            for i = 1, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.rows - 1, 1 do
                imports.beautify.native.drawRectangle(0, (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize + FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize)*i, inventoryUI.clientInventory.width, 1, inventoryUI.clientInventory.dividerColor, false)
            end
            for i = 1, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns - 1, 1 do
                imports.beautify.native.drawRectangle((FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize + FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize)*i, 0, 1, inventoryUI.clientInventory.height, inventoryUI.clientInventory.dividerColor, false)
            end
            imports.beautify.native.setRenderTarget()
            local rtPixels = imports.beautify.native.getTexturePixels(inventoryUI.gridRT)
            if rtPixels then
                inventoryUI.gridTexture = imports.beautify.native.createTexture(rtPixels, "dxt5", false, "clamp")
                imports.destroyElement(inventoryUI.gridRT)
                inventoryUI.gridRT = nil
            end
        end
    end
    inventoryUI.updateUILang = function() inventoryUI.isLangUpdated = true end
    imports.addEventHandler("Client:onUpdateLanguage", root, inventoryUI.updateUILang)
    inventoryUI.fetchUIGridFromOffset = function(offsetX, offsetY)
        if not offsetX or not offsetY then return false end
        local rowIndex, columnIndex = imports.math.ceil(offsetY/(inventoryUI.clientInventory.height/FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.rows)), imports.math.ceil(offsetX/(inventoryUI.clientInventory.width/FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns))
        rowIndex, columnIndex = (((rowIndex >= 1) and (rowIndex <= FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.rows)) and rowIndex) or false, (((columnIndex >= 1) and (columnIndex <= FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns)) and columnIndex) or false
        if not rowIndex or not columnIndex then return false end
        return rowIndex, columnIndex
    end
    inventoryUI.createBuffer = function(parent, name)
        if not parent or not imports.isElement(parent) or inventoryUI.buffer[parent] then return false end
        if (parent ~= localPlayer) and CLoot.isLocked(parent) then
            imports.triggerEvent("Client:onNotification", localPlayer, "Loot is locked..", FRAMEWORK_CONFIGS["UI"]["Notification"].presets.error)
            return false
        end
        inventoryUI.buffer[parent] = {
            name = imports.string.upper(imports.string.upper(imports.string.spaceChars(name or CLoot.fetchName(parent)))),
            bufferRT = imports.beautify.native.createRenderTarget(((parent == localPlayer) and inventoryUI.clientInventory.width) or inventoryUI.vicinityInventory.width, ((parent == localPlayer) and inventoryUI.clientInventory.height) or inventoryUI.vicinityInventory.height, true),
            scroller = {percent = 0, animPercent = 0},
            inventory = {}
        }
        inventoryUI.updateBuffer(parent)
        return true
    end
    inventoryUI.destroyBuffer = function(parent)
        if not parent or not imports.isElement(parent) then return false end
        if inventoryUI.buffer[parent] and inventoryUI.buffer[parent] then
            if inventoryUI.buffer[parent].bufferRT and imports.isElement(inventoryUI.buffer[parent].bufferRT) then
                imports.destroyElement(inventoryUI.buffer[parent].bufferRT)
            end
        end
        inventoryUI.buffer[parent] = nil
        return true
    end
    inventoryUI.updateBuffer = function(parent)
        if not parent or not imports.isElement(parent) or not inventoryUI.buffer[parent] then return false end
        inventoryUI.buffer[parent].maxSlots, inventoryUI.buffer[parent].assignedSlots, inventoryUI.buffer[parent].usedSlots = CInventory.fetchParentMaxSlots(parent), CInventory.fetchParentAssignedSlots(parent), CInventory.fetchParentUsedSlots(parent)
        inventoryUI.buffer[parent].inventory = {}
        inventoryUI.buffer[parent].bufferCache = nil
        for i, j in imports.pairs(CInventory.CItems) do
            local itemCount = CInventory.fetchItemCount(parent, i)
            if itemCount > 0 then
                inventoryUI.buffer[parent].inventory[i] = itemCount
            end
        end
        return true
    end
    inventoryUI.attachItem = function(parent, item, amount, prevSlot, prevX, prevY, prevWidth, prevHeight, offsetX, offsetY)
        if inventoryUI.attachedItem then return false end
        if not parent or not imports.isElement(parent) or not item or not amount or not prevSlot or not prevX or not prevY or not prevWidth or not prevHeight or not offsetX or not offsetY then return false end
        --if parent == localPlayer then revSlot = (inventoryUI.ui.equipment.grids[prevSlot] and prevSlot) or tonumber(prevSlot) end
        inventoryUI.attachedItem = {
            parent = parent, item = item, amount = amount,
            --TODO: REQUIRES A FINISH
            --isEquippedItem = (inventoryUI.ui.equipment.grids[prevSlot] and true) or false,
            prevSlot = prevSlot, prevX = prevX, prevY = prevY,
            prevWidth = prevWidth, prevHeight = prevHeight,
            offsetX = offsetX, offsetY = offsetY,
            animTickCounter = CLIENT_CURRENT_TICK
        }
        return true
    end
    inventoryUI.detachItem = function(isForced)
        if not inventoryUI.attachedItem then return false end
        if not isForced then
            inventoryUI.attachedItem.isOnTransition = true
            inventoryUI.attachedItem.transitionTickCounter = CLIENT_CURRENT_TICK
        else
            inventoryUI.attachedItem = nil
        end
        return true
    end


    -------------------------------
    --[[ Functions: UI Helpers ]]--
    -------------------------------

    inventoryUI.isUIEnabled = function()
        return (inventoryUI.isSynced and inventoryUI.isEnabled and not inventoryUI.isForcedDisabled) or false
    end

    function isInventoryUIVisible() return inventoryUI.state end
    function isInventoryUIEnabled() return inventoryUI.isUIEnabled() end

    imports.addEvent("Client:onEnableInventoryUI", true)
    imports.addEventHandler("Client:onEnableInventoryUI", root, function(state, isForced)
        if isForced then inventoryUI.isForcedDisabled = not state end
        inventoryUI.isEnabled = state
    end)

    imports.addEvent("Client:onSyncInventoryBuffer", true)
    imports.addEventHandler("Client:onSyncInventoryBuffer", root, function(buffer)
        CInventory.CBuffer = buffer
        inventoryUI.isSynced, inventoryUI.isSyncScheduled = true, false
        imports.triggerEvent("Client:onUpdateInventory", localPlayer)
    end)

    imports.addEvent("Client:onUpdateInventory", true)
    imports.addEventHandler("Client:onUpdateInventory", root, function()
        inventoryUI.detachItem(true)
        inventoryUI.updateBuffer(localPlayer)
        inventoryUI.updateBuffer(inventoryUI.vicinityInventory.element)
    end)


    ------------------------------
    --[[ Function: Renders UI ]]--
    ------------------------------

    inventoryUI.renderUI = function(renderData)
        if not inventoryUI.state or not CPlayer.isInitialized(localPlayer) then return false end
        if renderData.renderType == "input" then
            inventoryUI.cache.keys.mouse = imports.isMouseClicked()
            inventoryUI.cache.keys.scroll.state, inventoryUI.cache.keys.scroll.streak  = imports.isMouseScrolled()
            inventoryUI.cache.isEnabled = inventoryUI.isUIEnabled()
        elseif renderData.renderType == "preRender" then
            if not inventoryUI.bgTexture then inventoryUI.createBGTexture()
            elseif inventoryUI.vicinityInventory.bgTexture ~= ((inventoryUI.vicinityInventory.element and inventoryUI.buffer[(inventoryUI.vicinityInventory.element)] and true) or false) then inventoryUI.createBGTexture(true) end
            local isUIEnabled, isUIAttachmentTask = inventoryUI.cache.isEnabled, false
            local isUIActionEnabled = isUIEnabled and not inventoryUI.attachedItem
            local isLMBClicked = (inventoryUI.cache.keys.mouse == "mouse1") and isUIActionEnabled
            local client_bufferCache, client_isHovered, client_isSlotHovered = nil, nil, nil
            local client_startX, client_startY = inventoryUI.clientInventory.startX - inventoryUI.margin, inventoryUI.clientInventory.startY + inventoryUI.titlebar.height - inventoryUI.margin
            local client_width, client_height = inventoryUI.clientInventory.width + (inventoryUI.margin*2), inventoryUI.clientInventory.height + (inventoryUI.margin*2)

            local maxSlots, assignedItems, usedSlots = inventoryUI.buffer[localPlayer].maxSlots, {}, inventoryUI.buffer[localPlayer].usedSlots
            if CInventory.CBuffer then
                --[[
                for k, v in pairs(CInventory.CBuffer.slots) do
                    if tonumber(k) then
                        if not inventoryUI.isSynced then
                            if v.movementType == "equipment" and v.isAutoReserved then
                                if (tonumber(j.inventory[v.item]) or 0) <= 0 then
                                    if not bufferCache["__"..v.item] then
                                        table.insert(bufferCache, {item = v.item, itemValue = 1})
                                        bufferCache["__"..v.item] = true
                                    end
                                end
                            end
                        end
                        --TODO:...
                        if v.movementType then
                            local itemDetails, itemCategory = getItemDetails(v.item)
                            if itemDetails and itemCategory and CInventory.CItems[itemDetails.iconPath] then
                                local slotIndex = k
                                if slotIndex then
                                    local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                                    local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                                    local iconWidth, iconHeight = 0, template.contentWrapper.itemGrid.inventory.slotSize*verticalSlotsToOccupy
                                    local originalWidth, originalHeight = iconDimensions[itemDetails.iconPath].width, iconDimensions[itemDetails.iconPath].height
                                    iconWidth = (originalWidth / originalHeight)*iconHeight
                                    local slot_row = math.ceil(slotIndex/maximumInventoryRowSlots)
                                    local slot_column = slotIndex - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                                    local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                    local slotWidth, slotHeight = horizontalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding), verticalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding)
                                    if not inventoryUI.attachedItem or (inventoryUI.attachedItem.parent ~= i) or (inventoryUI.attachedItem.prevSlotIndex ~= slotIndex) then
                                        imports.beautify.native.drawImage(slot_offsetX + ((slotWidth - iconWidth)/2), slot_offsetY + ((slotHeight - iconHeight)/2), iconWidth, iconHeight, CInventory.CItems[itemDetails.iconPath], 0, 0, 0, tocolor(255, 255, 255, 255), false)
                                    end
                                end
                            end
                        else
                            for m, n in ipairs(bufferCache) do
                                if v.item == n.item then
                                    if not assignedItems[m] then
                                        assignedItems[m] = k
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                ]]--
            end
            client_bufferCache = inventoryUI.buffer[localPlayer].bufferCache
            --[[
            for k, v in ipairs(inventory_bufferCache) do
                if CInventory.CItems[v.item] then
                    local slotIndex = assignedItems[k] or false
                    if slotIndex then
                        local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                        local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                        local iconWidth, iconHeight = 0, template.contentWrapper.itemGrid.inventory.slotSize*verticalSlotsToOccupy
                        local originalWidth, originalHeight = iconDimensions[itemDetails.iconPath].width, iconDimensions[itemDetails.iconPath].height
                        iconWidth = (originalWidth / originalHeight)*iconHeight
                        local slot_row = math.ceil(slotIndex/maximumInventoryRowSlots)
                        local slot_column = slotIndex - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                        local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                        local slotWidth, slotHeight = horizontalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding), verticalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding)
                        local isItemToBeDrawn = true
                        if inventoryUI.attachedItem and (inventoryUI.attachedItem.parent == i) and (inventoryUI.attachedItem.prevSlotIndex == slotIndex) then 
                            if not inventoryUI.attachedItem.reservedSlotType then
                                isItemToBeDrawn = false
                            end
                        end
                        if isItemToBeDrawn then
                            imports.beautify.native.drawImage(slot_offsetX + ((slotWidth - iconWidth)/2), slot_offsetY + ((slotHeight - iconHeight)/2), iconWidth, iconHeight, CInventory.CItems[itemDetails.iconPath], 0, 0, 0, tocolor(255, 255, 255, 255), false)
                        end
                        if not inventoryUI.attachedItem and isUIEnabled then
                            if (slot_offsetY >= 0) and ((slot_offsetY + slotHeight) <= template.contentWrapper.height) then
                                local isSlotHovered = isMouseOnPosition(j.gui.startX + template.contentWrapper.startX + slot_offsetX, j.gui.startY + template.contentWrapper.startY + slot_offsetY, slotWidth, slotHeight)
                                if isSlotHovered then
                                    equipmentInformation = itemDetails.itemName..":\n"..itemDetails.description
                                    if isLMBClicked then
                                        local CLIENT_CURSOR_OFFSET[1], CLIENT_CURSOR_OFFSET[2] = getAbsoluteCursorPosition()
                                        local prev_offsetX, prev_offsetY = j.gui.startX + template.contentWrapper.startX + slot_offsetX, j.gui.startY + template.contentWrapper.startY + slot_offsetY
                                        local prev_width, prev_height = iconWidth, iconHeight
                                        local attached_offsetX, attached_offsetY = CLIENT_CURSOR_OFFSET[1] - prev_offsetX, CLIENT_CURSOR_OFFSET[2] - prev_offsetY
                                        attachInventoryItem(i, v.item, itemCategory, slotIndex, horizontalSlotsToOccupy, verticalSlotsToOccupy, prev_offsetX, prev_offsetY, prev_width, prev_height, attached_offsetX, attached_offsetY)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for k = 1, maxSlots, 1 do
                if not usedSlots[k] then
                    local slot_row = math.ceil(k/maximumInventoryRowSlots)
                    local slot_column = k - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                    local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                    local isSlotToBeDrawn = true
                    if inventoryUI.attachedItem and inventoryUI.attachedItem.parent and isElement(inventoryUI.attachedItem.parent) and inventoryUI.attachedItem.parent ~= localPlayer and inventoryUI.attachedItem.animTickCounter and inventoryUI.attachedItem.releaseType and inventoryUI.attachedItem.releaseType == "ordering" then
                        local slotIndexesToOccupy = {}
                        for m = inventoryUI.attachedItem.prevSlotIndex, inventoryUI.attachedItem.prevSlotIndex + (inventoryUI.attachedItem.occupiedRowSlots - 1), 1 do
                            if m <= maxSlots then
                                for x = 1, inventoryUI.attachedItem.occupiedColumnSlots, 1 do
                                    local succeedingColumnIndex = m + (maximumInventoryRowSlots*(x - 1))
                                    if succeedingColumnIndex <= maxSlots then
                                        if k == succeedingColumnIndex then
                                            isSlotToBeDrawn = false
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if isSlotToBeDrawn then
                        dxDrawRectangle(slot_offsetX, slot_offsetY, template.contentWrapper.itemGrid.inventory.slotSize, template.contentWrapper.itemGrid.inventory.slotSize, tocolor(unpack(template.contentWrapper.itemGrid.slot.bgColor)), false)
                    end
                else
                    if CInventory.CBuffer.slots[k] and CInventory.CBuffer.slots[k].movementType and CInventory.CBuffer.slots[k].movementType == "equipment" then
                        local itemDetails, itemCategory = getItemDetails(CInventory.CBuffer.slots[k].item)
                        if itemDetails and itemCategory then
                            local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                            local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                            local slot_row = math.ceil(k/maximumInventoryRowSlots)
                            local slot_column = k - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                            local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                            local slotWidth, slotHeight = horizontalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding), verticalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding)
                            local equippedIndex = CInventory.CBuffer.slots[k].equipmentIndex
                            if not equippedIndex then
                                for m, n in pairs(inventoryUI.gui.equipment.slot) do
                                    if CInventory.CBuffer.slots[m] and CInventory.CBuffer.slots[m] == CInventory.CBuffer.slots[k].item then
                                        equippedIndex = m
                                        break
                                    end
                                end
                            end
                            if equippedIndex then
                                dxDrawText(string.upper("EQUIPPED: "..equippedIndex), slot_offsetX, slot_offsetY, slot_offsetX + slotWidth, slot_offsetY + slotHeight, tocolor(unpack(template.contentWrapper.itemGrid.slot.fontColor)), 1, template.contentWrapper.itemGrid.slot.font.instance, "right", "bottom", true, true, false)
                            end
                        end
                    end
                end
            end
            ]]
            if inventoryUI.attachedItem and not inventoryUI.attachedItem.isOnTransition then
                --TODO: CHECK IF GRID IS HOVERED OR NOT
                local cursorX, cursorY = imports.getAbsoluteCursorPosition()
                local rowSlot, columnSlot = inventoryUI.fetchUIGridFromOffset(cursorX - inventoryUI.clientInventory.startX, cursorY - (inventoryUI.clientInventory.startY + inventoryUI.titlebar.height))
                if rowSlot and columnSlot then
                    outputChatBox(rowSlot.." : "..columnSlot)
                end
                --[[
                for k = 1, inventoryUI.buffer[localPlayer].maxSlots, 1 do
                    if not inventoryUI.buffer[localPlayer].usedSlots[k] then
                        local slot_row = math.ceil(k/FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns)
                        local slot_column = k - (math.max(0, slot_row - 1)*FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns)
                        outputChatBox(k.." : "..slot_row.." : "..slot_column)
                        local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                        if (slot_offsetY >= 0) and ((slot_offsetY + template.contentWrapper.itemGrid.inventory.slotSize) <= template.contentWrapper.height) then
                            local isSlotHovered = isMouseOnPosition(j.gui.startX + template.contentWrapper.startX + slot_offsetX, j.gui.startY + template.contentWrapper.startY + slot_offsetY, template.contentWrapper.itemGrid.inventory.slotSize, template.contentWrapper.itemGrid.inventory.slotSize)
                            if isSlotHovered then
                                local isSlotAvailable = isPlayerSlotAvailableForOrdering(localPlayer, inventoryUI.attachedItem.item, k, inventoryUI.attachedItem.isEquippedItem)
                                if isSlotAvailable then
                                    isItemAvailableForOrdering = {
                                        slotIndex = k,
                                        offsetX = slot_offsetX,
                                        offsetY = slot_offsetY
                                    }
                                end
                                for m = k, k + (inventoryUI.attachedItem.occupiedRowSlots - 1), 1 do
                                    for x = 1, inventoryUI.attachedItem.occupiedColumnSlots, 1 do
                                        local succeedingColumnIndex = m + (maximumInventoryRowSlots*(x - 1))
                                        if succeedingColumnIndex <= inventoryUI.buffer[localPlayer].maxSlots and not inventoryUI.buffer[localPlayer].usedSlots[succeedingColumnIndex] then
                                            local _slot_row = math.ceil(succeedingColumnIndex/maximumInventoryRowSlots)
                                            local _slot_column = succeedingColumnIndex - (math.max(0, _slot_row - 1)*maximumInventoryRowSlots)
                                            local _slot_offsetX, _slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, _slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, _slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                            if _slot_column >= slot_column then
                                                dxDrawRectangle(_slot_offsetX, _slot_offsetY, template.contentWrapper.itemGrid.inventory.slotSize, template.contentWrapper.itemGrid.inventory.slotSize, tocolor(unpack((isSlotAvailable and template.contentWrapper.itemGrid.slot.availableBGColor) or template.contentWrapper.itemGrid.slot.unavailableBGColor)), false)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                ]]--
            end
            imports.beautify.native.drawImage(0, 0, CLIENT_MTA_RESOLUTION[1], CLIENT_MTA_RESOLUTION[2], inventoryUI.bgTexture, 0, 0, 0, inventoryUI.opacityAdjuster.bgColor, false)
            imports.beautify.native.drawImage(inventoryUI.clientInventory.startX, inventoryUI.clientInventory.startY + inventoryUI.titlebar.height, inventoryUI.gridWidth, inventoryUI.gridHeight, inventoryUI.gridTexture, 0, 0, 0, inventoryUI.opacityAdjuster.bgColor, false)
            imports.beautify.native.drawText(inventoryUI.buffer[localPlayer].name, client_startX, client_startY - inventoryUI.titlebar.height, client_startX + client_width, client_startY, inventoryUI.titlebar.fontColor, 1, inventoryUI.titlebar.font.instance, "center", "center", true, false, false)
            imports.beautify.native.drawImage(client_startX + inventoryUI.margin, client_startY + inventoryUI.margin, inventoryUI.clientInventory.width, inventoryUI.clientInventory.height, inventoryUI.buffer[localPlayer].bufferRT, 0, 0, 0, -1, false)
            imports.beautify.native.drawImage(client_startX + inventoryUI.clientInventory.lockStat.startX, client_startY + inventoryUI.clientInventory.lockStat.startY, inventoryUI.clientInventory.lockStat.size, inventoryUI.clientInventory.lockStat.size, (isUIActionEnabled and inventoryUI.clientInventory.lockStat.unlockTexture) or inventoryUI.clientInventory.lockStat.lockTexture, 0, 0, 0, inventoryUI.titlebar.fontColor, false)
            for i = 1, #inventoryUI.clientInventory.equipment, 1 do
                local j = inventoryUI.clientInventory.equipment[i]
                imports.beautify.native.drawText(j.title, j.startX, j.startY - inventoryUI.titlebar.slot.height + inventoryUI.titlebar.slot.fontPaddingY, j.startX + j.width, j.startY, inventoryUI.titlebar.slot.fontColor, 1, inventoryUI.titlebar.slot.font.instance, "center", "center", true, false, false)
            end
            if inventoryUI.vicinityInventory.element and inventoryUI.buffer[(inventoryUI.vicinityInventory.element)] then
                local vicinity_bufferCache, vicinity_isHovered, vicinity_isSlotHovered = nil, nil, nil
                local vicinity_startX, vicinity_startY = inventoryUI.vicinityInventory.startX - (inventoryUI.margin*2), inventoryUI.vicinityInventory.startY + inventoryUI.titlebar.height - inventoryUI.margin
                local vicinity_width, vicinity_height = inventoryUI.vicinityInventory.width + (inventoryUI.margin*2), inventoryUI.vicinityInventory.height + (inventoryUI.margin*2)
                imports.beautify.native.setRenderTarget(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferRT, true)
                if not inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache then
                    local slotPriority = {}
                    inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache = {}
                    for i = 1, #FRAMEWORK_CONFIGS["Templates"]["Inventory"]["Priority"], 1 do
                        local j = FRAMEWORK_CONFIGS["Templates"]["Inventory"]["Priority"][i]
                        if CInventory.CCategories[j] then
                            slotPriority[j] = true
                            for k, v in imports.pairs(CInventory.CCategories[j]) do
                                if inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].inventory[k] then
                                    imports.table.insert(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache, {item = k, amount = inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].inventory[k]})
                                end
                            end
                        end
                    end
                    for i, j in imports.pairs(CInventory.CCategories) do
                        if not slotPriority[i] then
                            for k, v in imports.pairs(j) do
                                if inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].inventory[k] then
                                    imports.table.insert(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache, {item = k, amount = inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].inventory[k]})
                                end
                            end
                        end
                    end
                end
                vicinity_bufferCache = inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache
                vicinity_isHovered = imports.isMouseOnPosition(vicinity_startX + inventoryUI.margin, vicinity_startY + inventoryUI.margin, inventoryUI.vicinityInventory.width, inventoryUI.vicinityInventory.height)
                vicinity_bufferCache.overflowHeight =  imports.math.max(0, (inventoryUI.vicinityInventory.slotSize*#vicinity_bufferCache) + (inventoryUI.margin*imports.math.max(0, #vicinity_bufferCache - 1)) - inventoryUI.vicinityInventory.height)
                local vicinity_offsetY = vicinity_bufferCache.overflowHeight*inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.animPercent*0.01
                --TODO: MUST SHOW ONLY THE RORWS THAT ARE VISIBLE..
                for i = 1, #vicinity_bufferCache, 1 do
                    local j = vicinity_bufferCache[i]
                    j.offsetY = (inventoryUI.vicinityInventory.slotSize + inventoryUI.margin)*(i - 1) - vicinity_offsetY
                    vicinity_isSlotHovered = (vicinity_isHovered and isUIActionEnabled and (vicinity_isSlotHovered or (imports.isMouseOnPosition(vicinity_startX + inventoryUI.margin, vicinity_startY + inventoryUI.margin + j.offsetY, vicinity_width, inventoryUI.vicinityInventory.slotSize) and i))) or false
                    if not j.isPositioned then
                        j.title = imports.string.upper(CInventory.CItems[(j.item)].data.itemName)
                        j.width, j.height = (CInventory.CItems[(j.item)].dimensions[1]/CInventory.CItems[(j.item)].dimensions[2])*inventoryUI.vicinityInventory.slotSize, inventoryUI.vicinityInventory.slotSize
                        j.startX, j.startY = inventoryUI.vicinityInventory.width - j.width, 0
                        j.isPositioned = true
                    end
                    if vicinity_isSlotHovered == i then
                        if j.hoverStatus ~= "forward" then
                            j.hoverStatus = "forward"
                            j.hoverAnimTick = CLIENT_CURRENT_TICK
                        end
                    else
                        if j.hoverStatus ~= "backward" then
                            j.hoverStatus = "backward"
                            j.hoverAnimTick = CLIENT_CURRENT_TICK
                        end
                    end
                    j.animAlphaPercent = j.animAlphaPercent or 0
                    if j.hoverStatus == "forward" then
                        if j.animAlphaPercent < 1 then
                            j.animAlphaPercent = imports.interpolateBetween(j.animAlphaPercent, 0, 0, 1, 0, 0, imports.getInterpolationProgress(j.hoverAnimTick, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.animDuration*0.75), "OutQuad")
                            j.slotNameWidth = inventoryUI.vicinityInventory.width*j.animAlphaPercent
                        end
                    else
                        if j.animAlphaPercent > 0 then
                            j.animAlphaPercent = imports.interpolateBetween(j.animAlphaPercent, 0, 0, 0, 0, 0, imports.getInterpolationProgress(j.hoverAnimTick, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.animDuration*0.75), "OutQuad")
                            j.slotNameWidth = inventoryUI.vicinityInventory.width*j.animAlphaPercent
                        end
                    end
                    local itemValue = (inventoryUI.attachedItem and (inventoryUI.attachedItem.parent == inventoryUI.vicinityInventory.element) and (inventoryUI.attachedItem.prevSlot == i) and (j.amount - inventoryUI.attachedItem.amount)) or j.amount
                    imports.beautify.native.drawRectangle(0, j.offsetY, inventoryUI.vicinityInventory.width, inventoryUI.vicinityInventory.slotSize, inventoryUI.vicinityInventory.slotColor, false)
                    if itemValue > 0 then
                        imports.beautify.native.drawImage(j.startX, j.offsetY + j.startY, j.width, j.height, CInventory.CItems[(j.item)].icon.inventory, 0, 0, 0, -1, false)
                    end
                    if j.slotNameWidth and (j.slotNameWidth > 0) then
                        imports.beautify.native.drawImageSection(0, j.offsetY, j.slotNameWidth, inventoryUI.vicinityInventory.slotSize, inventoryUI.vicinityInventory.width - j.slotNameWidth, 0, j.slotNameWidth, inventoryUI.vicinityInventory.slotSize, inventoryUI.vicinityInventory.slotNameTexture, 0, 0, 0, -1, false)
                        imports.beautify.native.drawText(j.title, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize*0.25, j.offsetY, j.slotNameWidth - FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize, j.offsetY + inventoryUI.vicinityInventory.slotSize, inventoryUI.vicinityInventory.slotNameFontColor, 1, inventoryUI.vicinityInventory.slotNameFont.instance, "left", "center", true, false, false)
                    end
                end
                if vicinity_isSlotHovered then
                    if isLMBClicked then
                        local cursorX, cursorY = imports.getAbsoluteCursorPosition()
                        local slot_prevX, slot_prevY = vicinity_startX + inventoryUI.margin + vicinity_bufferCache[vicinity_isSlotHovered].startX, vicinity_startY + inventoryUI.margin + vicinity_bufferCache[vicinity_isSlotHovered].startY + vicinity_bufferCache[vicinity_isSlotHovered].offsetY
                        inventoryUI.attachItem(inventoryUI.vicinityInventory.element, vicinity_bufferCache[vicinity_isSlotHovered].item, 1, vicinity_isSlotHovered, slot_prevX, slot_prevY, vicinity_bufferCache[vicinity_isSlotHovered].width, vicinity_bufferCache[vicinity_isSlotHovered].height, cursorX - slot_prevX, cursorY - slot_prevY)
                        isUIActionEnabled = false
                    end
                end
                imports.beautify.native.setRenderTarget()
                imports.beautify.native.drawText(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].name, vicinity_startX, vicinity_startY - inventoryUI.titlebar.height, vicinity_startX + vicinity_width, vicinity_startY, inventoryUI.titlebar.fontColor, 1, inventoryUI.titlebar.font.instance, "center", "center", true, false, false)
                imports.beautify.native.drawImage(vicinity_startX + inventoryUI.margin, vicinity_startY + inventoryUI.margin, inventoryUI.vicinityInventory.width, inventoryUI.vicinityInventory.height, inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferRT, 0, 0, 0, -1, false)
                if vicinity_bufferCache.overflowHeight > 0 then
                    if not inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.isPositioned then
                        inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.startX, inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.startY = vicinity_startX + vicinity_width - inventoryUI.scroller.width, vicinity_startY + inventoryUI.margin
                        inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.height = inventoryUI.vicinityInventory.height
                        inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.isPositioned = true
                    end
                    if imports.math.round(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.animPercent, 2) ~= imports.math.round(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.percent, 2) then
                        inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.animPercent = imports.interpolateBetween(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.animPercent, 0, 0, inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.percent, 0, 0, 0.5, "InQuad")
                    end
                    imports.beautify.native.drawRectangle(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.startX, inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.startY, inventoryUI.scroller.width, inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.height, inventoryUI.scroller.bgColor, false)
                    imports.beautify.native.drawRectangle(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.startX, inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.startY + ((inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.height - inventoryUI.scroller.thumbHeight)*inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.animPercent*0.01), inventoryUI.scroller.width, inventoryUI.scroller.thumbHeight, inventoryUI.scroller.thumbColor, false)
                    if inventoryUI.cache.keys.scroll.state and (not inventoryUI.attachedItem or not inventoryUI.attachedItem.isOnTransition) and vicinity_isHovered then
                        local vicinity_scrollPercent = imports.math.max(1, 100/(vicinity_bufferCache.overflowHeight/(inventoryUI.vicinityInventory.slotSize*0.5)))
                        inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.percent = imports.math.max(0, imports.math.min(inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].scroller.percent + (vicinity_scrollPercent*imports.math.max(1, inventoryUI.cache.keys.scroll.streak)*(((inventoryUI.cache.keys.scroll.state == "down") and 1) or -1)), 100))
                        inventoryUI.cache.keys.scroll.state = false
                    end
                end
            else
                imports.beautify.native.setRenderTarget()
            end
            inventoryUI.opacityAdjuster.percent = imports.beautify.slider.getPercent(inventoryUI.opacityAdjuster.element)
            if inventoryUI.opacityAdjuster.percent ~= inventoryUI.opacityAdjuster.animPercent then
                inventoryUI.opacityAdjuster.animPercent = inventoryUI.opacityAdjuster.percent
                inventoryUI.opacityAdjuster.bgColor = imports.tocolor(255, 255, 255, 255*0.01*(inventoryUI.opacityAdjuster.range[1] + ((inventoryUI.opacityAdjuster.range[2] - inventoryUI.opacityAdjuster.range[1])*inventoryUI.opacityAdjuster.percent*0.01)))
            end
            if inventoryUI.attachedItem then
                --TODO: HIGHLY WIP..
                --[[
                local horizontalSlotsToOccupy = inventoryUI.attachedItem.occupiedRowSlots
                local verticalSlotsToOccupy = inventoryUI.attachedItem.occupiedColumnSlots
                local iconWidth, iconHeight = 0, inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.inventory.slotSize*verticalSlotsToOccupy
                local originalWidth, originalHeight = iconDimensions[itemDetails.iconPath].width, iconDimensions[itemDetails.iconPath].height
                iconWidth = (originalWidth / originalHeight)*iconHeight
                ]]
                if not inventoryUI.attachedItem.isOnTransition and (CLIENT_MTA_WINDOW_ACTIVE or not imports.isKeyOnHold("mouse1") or not isUIEnabled) then
                    if isUIAttachmentTask == "order" then
                        --[[
                        local slotWidth, slotHeight = horizontalSlotsToOccupy*inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding), verticalSlotsToOccupy*inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding)
                        local releaseIndex = inventoryUI.attachedItem.prevSlotIndex
                        inventoryUI.attachedItem.prevSlotIndex = isItemAvailableForOrdering.slotIndex
                        inventoryUI.attachedItem.prevPosX = inventoryUI.buffer[localPlayer].gui.startX + inventoryUI.gui.itemBox.templates[1].contentWrapper.startX + isItemAvailableForOrdering.offsetX + ((slotWidth - iconWidth)/2)
                        inventoryUI.attachedItem.prevPosY = inventoryUI.buffer[localPlayer].gui.startY + inventoryUI.gui.itemBox.templates[1].contentWrapper.startY + isItemAvailableForOrdering.offsetY + ((slotHeight - iconHeight)/2)
                        inventoryUI.attachedItem.releaseType = isUIAttachmentTask
                        inventoryUI.attachedItem.releaseIndex = releaseIndex
                        if inventoryUI.attachedItem.parent == localPlayer then
                            if inventoryUI.attachedItem.isEquippedItem then
                                unequipItemInInventory(inventoryUI.attachedItem.item, releaseIndex, isItemAvailableForOrdering.slotIndex, localPlayer)
                            else
                                orderItemInInventory(inventoryUI.attachedItem.item, releaseIndex, isItemAvailableForOrdering.slotIndex)
                            end
                        end
                        triggerEvent("onClientInventorySound", localPlayer, "inventory_move_item")
                        ]]
                    elseif isUIAttachmentTask == "drop" then
                        --[[
                        local totalLootItems = 0
                        for index, _ in pairs(inventoryUI.buffer[isItemAvailableForDropping.loot].inventory) do
                            totalLootItems = totalLootItems + 1
                        end
                        local template = inventoryUI.gui.itemBox.templates[(inventoryUI.buffer[isItemAvailableForDropping.loot].gui.templateIndex)]
                        local totalContentHeight = template.contentWrapper.itemSlot.startY + ((template.contentWrapper.itemSlot.paddingY + template.contentWrapper.itemSlot.height)*totalLootItems)
                        local exceededContentHeight =  totalContentHeight - template.contentWrapper.height
                        local slot_offsetY = template.contentWrapper.itemSlot.startY + ((template.contentWrapper.itemSlot.paddingY + template.contentWrapper.itemSlot.height)*(isItemAvailableForDropping.slotIndex - 1))
                        local slotWidth, slotHeight = 0, template.contentWrapper.itemSlot.iconSlot.height
                        slotWidth = (originalWidth / originalHeight)*slotHeight
                        if exceededContentHeight > 0 then
                            slot_offsetY = slot_offsetY - (exceededContentHeight*inventoryUI.buffer[isItemAvailableForDropping.loot].gui.scroller.percent*0.01)
                            if slot_offsetY < 0 then
                                local finalScrollPercent = inventoryUI.buffer[isItemAvailableForDropping.loot].gui.scroller.percent + (slot_offsetY/exceededContentHeight)*100
                                slot_offsetY = template.contentWrapper.itemSlot.paddingY
                                inventoryUI.attachedItem.__scrollItemBox = {initial = inventoryUI.buffer[isItemAvailableForDropping.loot].gui.scroller.percent, final = finalScrollPercent, tickCounter = getTickCount()}
                            elseif (slot_offsetY + template.contentWrapper.itemSlot.height + template.contentWrapper.itemSlot.paddingY) > template.contentWrapper.height then
                                local finalScrollPercent = inventoryUI.buffer[isItemAvailableForDropping.loot].gui.scroller.percent + (((slot_offsetY + template.contentWrapper.itemSlot.height + template.contentWrapper.itemSlot.paddingY) - template.contentWrapper.height)/exceededContentHeight)*100
                                slot_offsetY = template.contentWrapper.height - (template.contentWrapper.itemSlot.height + template.contentWrapper.itemSlot.paddingY)
                                inventoryUI.attachedItem.__scrollItemBox = {initial = inventoryUI.buffer[isItemAvailableForDropping.loot].gui.scroller.percent, final = finalScrollPercent, tickCounter = getTickCount()}
                            end
                        end
                        local releaseIndex = inventoryUI.attachedItem.prevSlotIndex
                        inventoryUI.attachedItem.finalWidth, inventoryUI.attachedItem.finalHeight = slotWidth, slotHeight
                        inventoryUI.attachedItem.prevWidth, inventoryUI.attachedItem.prevHeight = inventoryUI.attachedItem.__width, inventoryUI.attachedItem.__height
                        inventoryUI.attachedItem.animTickCounter = getTickCount()
                        inventoryUI.attachedItem.prevSlotIndex = isItemAvailableForDropping.slotIndex
                        inventoryUI.attachedItem.prevPosX = inventoryUI.buffer[isItemAvailableForDropping.loot].gui.startX + template.contentWrapper.startX + template.contentWrapper.itemSlot.startX + template.contentWrapper.itemSlot.iconSlot.startX
                        inventoryUI.attachedItem.prevPosY = inventoryUI.buffer[isItemAvailableForDropping.loot].gui.startY + template.contentWrapper.startY + slot_offsetY
                        inventoryUI.attachedItem.releaseType = isUIAttachmentTask
                        inventoryUI.attachedItem.releaseLoot = isItemAvailableForDropping.loot
                        inventoryUI.attachedItem.releaseIndex = releaseIndex
                        if inventoryUI.attachedItem.isEquippedItem then
                            local reservedSlotIndex = false
                            inventoryUI.isSyncScheduled = true
                            CInventory.CBuffer.slots[releaseIndex] = nil
                            for i, j in pairs(CInventory.CBuffer.slots) do
                                if tonumber(i) then
                                    if j.movementType and j.movementType == "equipment" and releaseIndex == j.equipmentIndex then
                                        reservedSlotIndex = i
                                        break
                                    end
                                end
                            end
                            if reservedSlotIndex then
                                inventoryUI.attachedItem.reservedSlotType = "equipment"
                                inventoryUI.attachedItem.reservedSlot = reservedSlotIndex
                                CInventory.CBuffer.slots[reservedSlotIndex] = {
                                    item = inventoryUI.attachedItem.item,
                                    loot = isItemAvailableForDropping.loot,
                                    movementType = "loot"
                                }
                            end
                        else
                            inventoryUI.isSyncScheduled = true
                            CInventory.CBuffer.slots[releaseIndex] = {
                                item = inventoryUI.attachedItem.item,
                                loot = isItemAvailableForDropping.loot,
                                movementType = "loot"
                            }
                        end
                        triggerEvent("onClientInventorySound", localPlayer, "inventory_move_item")
                        ]]
                    elseif isUIAttachmentTask == "equip" then
                        --[[
                        local slotWidth, slotHeight = inventoryUI.gui.equipment.slot[isItemAvailableForEquipping.slotIndex].width - inventoryUI.gui.equipment.slot[isItemAvailableForEquipping.slotIndex].paddingX, inventoryUI.gui.equipment.slot[isItemAvailableForEquipping.slotIndex].height - inventoryUI.gui.equipment.slot[isItemAvailableForEquipping.slotIndex].paddingY
                        local releaseIndex = inventoryUI.attachedItem.prevSlotIndex
                        local reservedSlot = isItemAvailableForEquipping.reservedSlot or releaseIndex
                        inventoryUI.attachedItem.finalWidth, inventoryUI.attachedItem.finalHeight = slotWidth, slotHeight
                        inventoryUI.attachedItem.prevWidth, inventoryUI.attachedItem.prevHeight = inventoryUI.attachedItem.__width, inventoryUI.attachedItem.__height
                        inventoryUI.attachedItem.animTickCounter = getTickCount()
                        inventoryUI.attachedItem.prevSlotIndex = isItemAvailableForEquipping.slotIndex
                        inventoryUI.attachedItem.prevPosX = isItemAvailableForEquipping.offsetX
                        inventoryUI.attachedItem.prevPosY = isItemAvailableForEquipping.offsetY
                        inventoryUI.attachedItem.releaseType = isUIAttachmentTask
                        inventoryUI.attachedItem.releaseLoot = isItemAvailableForEquipping.loot
                        inventoryUI.attachedItem.releaseIndex = releaseIndex
                        inventoryUI.attachedItem.reservedSlot = reservedSlot
                        if loot == localPlayer then
                            inventoryUI.isSyncScheduled = true
                            CInventory.CBuffer.slots[reservedSlot] = {
                                item = inventoryUI.attachedItem.item,
                                movementType = "equipment"
                            }
                        else
                            inventoryUI.isSyncScheduled = true
                            CInventory.CBuffer.slots[reservedSlot] = {
                                item = inventoryUI.attachedItem.item,
                                loot = isItemAvailableForEquipping.loot,
                                isAutoReserved = true,
                                movementType = "equipment"
                            }
                        end
                        triggerEvent("onClientInventorySound", localPlayer, "inventory_move_item")
                        ]]
                    else
                        if inventoryUI.attachedItem.parent == localPlayer then
                            --[[
                            local maxSlots = CInventory.fetchParentMaxSlots(inventoryUI.attachedItem.parent)
                            local totalContentHeight = inventoryUI.gui.itemBox.templates[1].contentWrapper.padding + inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding + (math.max(0, math.ceil(maxSlots/maximumInventoryRowSlots) - 1)*(inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.inventory.slotSize + inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding)) + inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.inventory.slotSize + inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding
                            local exceededContentHeight =  totalContentHeight - inventoryUI.gui.itemBox.templates[1].contentWrapper.height
                            if exceededContentHeight > 0 then
                                local slot_row = math.ceil(inventoryUI.attachedItem.prevSlotIndex/maximumInventoryRowSlots)
                                local slot_offsetY = inventoryUI.gui.itemBox.templates[1].contentWrapper.padding + inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.inventory.slotSize + inventoryUI.gui.itemBox.templates[1].contentWrapper.itemGrid.padding)) - (exceededContentHeight*inventoryUI.buffer[localPlayer].gui.scroller.percent*0.01)
                                local slot_prevOffsetY = inventoryUI.attachedItem.prevPosY - inventoryUI.buffer[localPlayer].gui.startY - inventoryUI.gui.itemBox.templates[1].contentWrapper.startY
                                if (math.round(slot_offsetY, 2) ~= math.round(slot_prevOffsetY, 2)) then
                                    local finalScrollPercent = inventoryUI.buffer[localPlayer].gui.scroller.percent + ((slot_offsetY - slot_prevOffsetY)/exceededContentHeight)*100
                                    inventoryUI.attachedItem.__scrollItemBox = {initial = inventoryUI.buffer[localPlayer].gui.scroller.percent, final = finalScrollPercent, tickCounter = getTickCount()}
                                end
                            end
                            ]]
                        else
                            inventoryUI.attachedItem.finalWidth, inventoryUI.attachedItem.finalHeight = inventoryUI.attachedItem.prevWidth, inventoryUI.attachedItem.prevHeight
                            inventoryUI.attachedItem.prevWidth, inventoryUI.attachedItem.prevHeight = inventoryUI.attachedItem.__width, inventoryUI.attachedItem.__height
                            inventoryUI.attachedItem.animTickCounter = getTickCount()
                            if inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache.overflowHeight > 0 then
                                local slot_offsetY = inventoryUI.vicinityInventory.startY + inventoryUI.titlebar.height + ((inventoryUI.vicinityInventory.slotSize + inventoryUI.margin)*(inventoryUI.attachedItem.prevSlot - 1)) - (inventoryUI.buffer[(inventoryUI.attachedItem.parent)].bufferCache.overflowHeight*inventoryUI.buffer[(inventoryUI.attachedItem.parent)].scroller.percent*0.01)
                                if imports.math.round(slot_offsetY, 2) ~= imports.math.round(inventoryUI.attachedItem.prevY, 2) then
                                    inventoryUI.buffer[(inventoryUI.attachedItem.parent)].scroller.percent = inventoryUI.buffer[(inventoryUI.attachedItem.parent)].scroller.percent + (((slot_offsetY - inventoryUI.attachedItem.prevY)/inventoryUI.buffer[(inventoryUI.vicinityInventory.element)].bufferCache.overflowHeight)*100)
                                end
                            end
                        end
                        --TODO: PLAY SOUND
                        --triggerEvent("onClientInventorySound", localPlayer, "inventory_rollback_item")
                    end
                    inventoryUI.detachItem()
                end
                local isDetachAttachment = false
                local attachment_posX, attachment_posY = nil, nil
                inventoryUI.attachedItem.__width, inventoryUI.attachedItem.__height = imports.interpolateBetween(inventoryUI.attachedItem.prevWidth, inventoryUI.attachedItem.prevHeight, 0, inventoryUI.attachedItem.finalWidth or CInventory.CItems[(inventoryUI.attachedItem.item)].dimensions[1], inventoryUI.attachedItem.finalHeight or CInventory.CItems[(inventoryUI.attachedItem.item)].dimensions[2], 0, imports.getInterpolationProgress(inventoryUI.attachedItem.animTickCounter, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.animDuration*0.35), "OutBack")
                if inventoryUI.attachedItem.isOnTransition then
                    attachment_posX, attachment_posY = imports.interpolateBetween(inventoryUI.attachedItem.__posX, inventoryUI.attachedItem.__posY, 0, inventoryUI.attachedItem.prevX, inventoryUI.attachedItem.prevY, 0, imports.getInterpolationProgress(inventoryUI.attachedItem.transitionTickCounter, FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.animDuration), "OutElastic")
                    if (imports.math.round(attachment_posX, 2) == imports.math.round(inventoryUI.attachedItem.prevX, 2)) and (imports.math.round(attachment_posY, 2) == imports.math.round(inventoryUI.attachedItem.prevY, 2)) then
                        --TODO: WIP..
                        --[[
                        if inventoryUI.attachedItem.releaseType and inventoryUI.attachedItem.releaseType == "equipping" then
                            equipItemInInventory(inventoryUI.attachedItem.item, inventoryUI.attachedItem.releaseIndex, inventoryUI.attachedItem.reservedSlot, inventoryUI.attachedItem.prevSlotIndex, inventoryUI.attachedItem.parent)
                        else
                            if inventoryUI.attachedItem.parent ~= localPlayer then
                                if inventoryUI.attachedItem.releaseType and inventoryUI.attachedItem.releaseType == "ordering" then
                                    if not inventoryUI.attachedItem.isEquippedItem then
                                        moveItemInInventory(inventoryUI.attachedItem.item, inventoryUI.attachedItem.prevSlotIndex, inventoryUI.attachedItem.parent)
                                    end
                                end
                            else
                                if inventoryUI.attachedItem.releaseType and inventoryUI.attachedItem.releaseType == "dropping" then
                                    if inventoryUI.attachedItem.isEquippedItem then
                                        unequipItemInInventory(inventoryUI.attachedItem.item, inventoryUI.attachedItem.releaseIndex, inventoryUI.attachedItem.prevSlotIndex, inventoryUI.attachedItem.releaseLoot, inventoryUI.attachedItem.reservedSlot)
                                    else
                                        moveItemInLoot(inventoryUI.attachedItem.item, inventoryUI.attachedItem.releaseIndex, inventoryUI.attachedItem.releaseLoot)
                                    end
                                end
                            end
                        end
                        ]]
                        isDetachAttachment = true
                    end
                else
                    local cursorX, cursorY = imports.getAbsoluteCursorPosition()
                    inventoryUI.attachedItem.__posX, inventoryUI.attachedItem.__posY = cursorX - inventoryUI.attachedItem.offsetX, cursorY - inventoryUI.attachedItem.offsetY
                    attachment_posX, attachment_posY = inventoryUI.attachedItem.__posX, inventoryUI.attachedItem.__posY
                end
                imports.beautify.native.drawImage(attachment_posX, attachment_posY, inventoryUI.attachedItem.__width, inventoryUI.attachedItem.__height, CInventory.CItems[(inventoryUI.attachedItem.item)].icon.inventory, 0, 0, 0, -1, false)
                if isDetachAttachment then inventoryUI.detachItem(true) end
            end
            inventoryUI.isLangUpdated = nil
        end
    end


    ----------------------------------------
    --[[ Client: On Toggle Inventory UI ]]--
    ----------------------------------------

    local testPed = createPed(0, 0, 0, 0); setElementAlpha(testPed, 0) --TODO: REMOVE IT LATER
    setElementData(testPed, "Loot:Type", "something")
    setElementData(testPed, "Loot:Name", "Test Loot")
    for i, j in pairs(CInventory.CItems) do
        setElementData(testPed, "Item:"..i, 1)
    end
    inventoryUI.toggleUI = function(state)
        if (((state ~= true) and (state ~= false)) or (state == inventoryUI.state)) then return false end

        if state then
            if inventoryUI.state then return false end
            --TODO: ENABLE LATER
            --if not CPlayer.isInitialized(localPlayer) or (CCharacter.getHealth(localPlayer) <= 0) then inventoryUI.toggleUI(false) return false end
            --inventoryUI.vicinityInventory.element = CCharacter.isInLoot(localPlayer)
            inventoryUI.vicinityInventory.element = testPed --TODO: REMOVE IT LATER AND ENABLE ^
            imports.triggerEvent("Client:onEnableInventoryUI", localPlayer, true)
            inventoryUI.createBuffer(localPlayer, imports.string.format(FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory["Title"][(CPlayer.CLanguage)], imports.getPlayerName(localPlayer)))
            inventoryUI.createBuffer(inventoryUI.vicinityInventory.element)
            inventoryUI.opacityAdjuster.element = imports.beautify.slider.create(inventoryUI.opacityAdjuster.startX, inventoryUI.opacityAdjuster.startY, inventoryUI.opacityAdjuster.width, inventoryUI.opacityAdjuster.height, "vertical", nil, false)
            inventoryUI.opacityAdjuster.percent = inventoryUI.opacityAdjuster.percent or 100
            imports.beautify.slider.setPercent(inventoryUI.opacityAdjuster.element, inventoryUI.opacityAdjuster.percent)
            imports.beautify.slider.setText(inventoryUI.opacityAdjuster.element, imports.string.upper(imports.string.spaceChars("Opacity")))
            imports.beautify.slider.setTextColor(inventoryUI.opacityAdjuster.element, FRAMEWORK_CONFIGS["UI"]["Inventory"].titlebar.fontColor)
            imports.beautify.render.create(inventoryUI.renderUI, {elementReference = inventoryUI.opacityAdjuster.element, renderType = "preRender"})
            imports.beautify.render.create(inventoryUI.renderUI, {renderType = "input"})
            imports.beautify.setUIVisible(inventoryUI.opacityAdjuster.element, true)
        else
            if not inventoryUI.state then return false end
            if inventoryUI.opacityAdjuster.element and imports.isElement(inventoryUI.opacityAdjuster.element) then
                imports.destroyElement(inventoryUI.opacityAdjuster.element)
                imports.beautify.render.remove(inventoryUI.renderUI, {renderType = "input"})
            end
            if inventoryUI.isSyncScheduled then
                imports.triggerServerEvent("Player:onSyncInventorySlots", localPlayer)
            end
            inventoryUI.destroyBuffer(localPlayer)
            inventoryUI.destroyBuffer(inventoryUI.vicinityInventory.element)
            inventoryUI.vicinityInventory.element = nil
            inventoryUI.opacityAdjuster.element = nil
            imports.collectgarbage()
        end
        inventoryUI.detachItem(true)
        inventoryUI.state = (state and true) or false
        imports.showChat(not inventoryUI.state)
        imports.showCursor(inventoryUI.state)
        return true
    end

    imports.addEvent("Client:onToggleInventoryUI", true)
    imports.addEventHandler("Client:onToggleInventoryUI", root, inventoryUI.toggleUI)
    imports.bindKey(FRAMEWORK_CONFIGS["UI"]["Inventory"].toggleKey, "down", function() inventoryUI.toggleUI(not inventoryUI.state) end)
    imports.addEventHandler("onClientPlayerWasted", localPlayer, function() inventoryUI.toggleUI(false) end)




    --[[
    local bufferCache = {
        "primary_weapon",
        "secondary_weapon",
        "Ammo",
        "special_weapon",
        "Medical",
        "Nutrition",
        "Backpack",
        "Helmet",
        "Armor",
        "Suit",
        "Tent",
        "Other",
        "Build",
        "Utility"
    }

    function displayInventoryUI()
        local isItemAvailableForOrdering = false
        local isItemAvailableForDropping = false
        local isItemAvailableForEquipping = false
        local playerMaxSlots = CInventory.fetchParentMaxSlots(localPlayer)
        local playerUsedSlots = getElementUsedSlots(localPlayer)

        --Draws Equipment
        dxSetRenderTarget()
        imports.beautify.native.drawImage(inventoryUI.gui.equipment.startX, inventoryUI.gui.equipment.startY - inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.titlebar.leftEdgePath, 0, 0, 0, tocolor(inventoryUI.gui.equipment.titlebar.bgColor[1], inventoryUI.gui.equipment.titlebar.bgColor[2], inventoryUI.gui.equipment.titlebar.bgColor[3], inventoryUI.gui.equipment.titlebar.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
        dxDrawRectangle(inventoryUI.gui.equipment.startX + inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.startY - inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.width - inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.titlebar.height, tocolor(inventoryUI.gui.equipment.titlebar.bgColor[1], inventoryUI.gui.equipment.titlebar.bgColor[2], inventoryUI.gui.equipment.titlebar.bgColor[3], inventoryUI.gui.equipment.titlebar.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
        imports.beautify.native.drawImage(inventoryUI.gui.equipment.startX, inventoryUI.gui.equipment.startY, inventoryUI.gui.equipment.width, inventoryUI.gui.equipment.height, inventoryUI.gui.equipment.bgPath, 0, 0, 0, tocolor(inventoryUI.gui.equipment.bgColor[1], inventoryUI.gui.equipment.bgColor[2], inventoryUI.gui.equipment.bgColor[3], inventoryUI.gui.equipment.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
        dxDrawBorderedText(inventoryUI.gui.equipment.titlebar.outlineWeight, inventoryUI.gui.equipment.titlebar.fontColor, string.upper(playerName.."'S EQUIPMENT   |   "..playerUsedSlots.."/"..playerMaxSlots), inventoryUI.gui.equipment.startX + inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.startY - inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.startX + inventoryUI.gui.equipment.width - inventoryUI.gui.equipment.titlebar.height, inventoryUI.gui.equipment.startY, tocolor(inventoryUI.gui.equipment.titlebar.fontColor[1], inventoryUI.gui.equipment.titlebar.fontColor[2], inventoryUI.gui.equipment.titlebar.fontColor[3], inventoryUI.gui.equipment.titlebar.fontColor[4]*inventoryOpacityPercent), 1, inventoryUI.gui.equipment.titlebar.font.instance, "right", "center", true, false, inventoryUI.gui.postGUI)
        dxDrawRectangle(inventoryUI.gui.equipment.startX, inventoryUI.gui.equipment.startY, inventoryUI.gui.equipment.width, inventoryUI.gui.equipment.titlebar.dividerSize, tocolor(inventoryUI.gui.equipment.titlebar.dividerColor[1], inventoryUI.gui.equipment.titlebar.dividerColor[2], inventoryUI.gui.equipment.titlebar.dividerColor[3], inventoryUI.gui.equipment.titlebar.dividerColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
        for i, j in pairs(inventoryUI.gui.equipment.slot) do
            local itemDetails, itemCategory = false, false
            if CInventory.CBuffer and CInventory.CBuffer.slots[i] then
                itemDetails, itemCategory = getItemDetails(CInventory.CBuffer.slots[i])
            end
            imports.beautify.native.drawImage(j.startX - j.borderSize, j.startY - j.borderSize, j.height/2 + j.borderSize, j.height/2 + j.borderSize, inventoryUI.gui.equipment.slotTopLeftCurvedEdgeBGPath, 0, 0, 0, tocolor(j.borderColor[1], j.borderColor[2], j.borderColor[3], j.borderColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            imports.beautify.native.drawImage(j.startX + j.width - j.height/2, j.startY - j.borderSize, j.height/2 + j.borderSize, j.height/2 + j.borderSize, inventoryUI.gui.equipment.slotTopRightCurvedEdgeBGPath, 0, 0, 0, tocolor(j.borderColor[1], j.borderColor[2], j.borderColor[3], j.borderColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            imports.beautify.native.drawImage(j.startX - j.borderSize, j.startY + j.height - j.height/2, j.height/2 + j.borderSize, j.height/2 + j.borderSize, inventoryUI.gui.equipment.slotBottomLeftCurvedEdgeBGPath, 0, 0, 0, tocolor(j.borderColor[1], j.borderColor[2], j.borderColor[3], j.borderColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            imports.beautify.native.drawImage(j.startX + j.width - j.height/2, j.startY + j.height - j.height/2, j.height/2 + j.borderSize, j.height/2 + j.borderSize, inventoryUI.gui.equipment.slotBottomRightCurvedEdgeBGPath, 0, 0, 0, tocolor(j.borderColor[1], j.borderColor[2], j.borderColor[3], j.borderColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            if j.width > j.height then
                dxDrawRectangle(j.startX + j.height/2, j.startY - j.borderSize, j.width - j.height, j.height + (j.borderSize*2), tocolor(j.borderColor[1], j.borderColor[2], j.borderColor[3], j.borderColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            end
            imports.beautify.native.drawImage(j.startX, j.startY, j.height/2, j.height/2, inventoryUI.gui.equipment.slotTopLeftCurvedEdgeBGPath, 0, 0, 0, tocolor(j.bgColor[1], j.bgColor[2], j.bgColor[3], j.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            imports.beautify.native.drawImage(j.startX + j.width - j.height/2, j.startY, j.height/2, j.height/2, inventoryUI.gui.equipment.slotTopRightCurvedEdgeBGPath, 0, 0, 0, tocolor(j.bgColor[1], j.bgColor[2], j.bgColor[3], j.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            imports.beautify.native.drawImage(j.startX, j.startY + j.height - j.height/2, j.height/2, j.height/2, inventoryUI.gui.equipment.slotBottomLeftCurvedEdgeBGPath, 0, 0, 0, tocolor(j.bgColor[1], j.bgColor[2], j.bgColor[3], j.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            imports.beautify.native.drawImage(j.startX + j.width - j.height/2, j.startY + j.height - j.height/2, j.height/2, j.height/2, inventoryUI.gui.equipment.slotBottomRightCurvedEdgeBGPath, 0, 0, 0, tocolor(j.bgColor[1], j.bgColor[2], j.bgColor[3], j.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            if j.width > j.height then
                dxDrawRectangle(j.startX + j.height/2, j.startY, j.width - j.height, j.height, tocolor(j.bgColor[1], j.bgColor[2], j.bgColor[3], j.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
            end
            local isSlotHovered = isMouseOnPosition(j.startX, j.startY, j.width, j.height) and isUIEnabled
            if itemDetails and itemCategory then
                if CInventory.CItems[itemDetails.iconPath] then
                    if not inventoryUI.attachedItem or (inventoryUI.attachedItem.parent ~= localPlayer) or (inventoryUI.attachedItem.prevSlotIndex ~= i) then                
                        imports.beautify.native.drawImage(j.startX + (j.paddingX/2), j.startY + (j.paddingY/2), j.width - j.paddingX, j.height - j.paddingY, CInventory.CItems[itemDetails.iconPath], 0, 0, 0, tocolor(255, 255, 255, 255*inventoryOpacityPercent), inventoryUI.gui.postGUI)
                    end
                    if isSlotHovered then
                        equipmentInformation = itemDetails.itemName..":\n"..itemDetails.description
                        if isLMBClicked then
                            local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                            local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                            local CLIENT_CURSOR_OFFSET[1], CLIENT_CURSOR_OFFSET[2] = getAbsoluteCursorPosition()
                            local prev_offsetX, prev_offsetY = j.startX + (j.paddingX/2), j.startY + (j.paddingY/2)
                            local prev_width, prev_height = j.width - j.paddingX, j.height - j.paddingY
                            local attached_offsetX, attached_offsetY = CLIENT_CURSOR_OFFSET[1] - prev_offsetX, CLIENT_CURSOR_OFFSET[2] - prev_offsetY
                            attachInventoryItem(localPlayer, itemDetails.dataName, itemCategory, i, horizontalSlotsToOccupy, verticalSlotsToOccupy, prev_offsetX, prev_offsetY, prev_width, prev_height, attached_offsetX, attached_offsetY)
                        end
                    end
                end
            else
                if j.bgImage then
                    local isPlaceHolderToBeShown = true
                    local placeHolderColor = {255, 255, 255, 255}
                    if inventoryUI.attachedItem then
                        if not inventoryUI.attachedItem.animTickCounter then
                            if isSlotHovered and isUIEnabled then
                                local isSlotAvailable, slotIndex = isPlayerSlotAvailableForEquipping(localPlayer, inventoryUI.attachedItem.item, i, inventoryUI.attachedItem.parent == localPlayer)
                                if isSlotAvailable then
                                    isItemAvailableForEquipping = {
                                        slotIndex = i,
                                        reservedSlot = slotIndex,
                                        offsetX = j.startX + (j.paddingX/2),
                                        offsetY = j.startY + (j.paddingY/2),
                                        loot = inventoryUI.attachedItem.parent
                                    }
                                end
                                placeHolderColor = (isSlotAvailable and j.availableBGColor) or j.unavailableBGColor
                            end
                        else
                            if inventoryUI.attachedItem.releaseType and inventoryUI.attachedItem.releaseType == "equipping" and inventoryUI.attachedItem.prevSlotIndex == i then
                                isPlaceHolderToBeShown = false
                            end
                        end
                    end
                    if isPlaceHolderToBeShown then
                        imports.beautify.native.drawImage(j.startX, j.startY, j.width, j.height, j.bgImage, 0, 0, 0, tocolor(placeHolderColor[1], placeHolderColor[2], placeHolderColor[3], placeHolderColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)	
                    end
                end
            end
        end

        --Draws ItemBoxes
        for i, j in pairs(inventoryUI.buffer) do
            if i and isElement(i) and j then
                local maxSlots = CInventory.fetchParentMaxSlots(i)
                local usedSlots = getElementUsedSlots(i)
                if j.gui.templateIndex == 1 then
                    if not j.bufferCache then
                        j.bufferCache = {}
                        for k, v in pairs(inventoryDatas) do
                            for key, value in ipairs(v) do
                                if j.inventory[value.dataName] then
                                    --TODO: SAME THING BUT ADD MULTIPLE OF THEM BASED ON TOTAL COUNT
                                    for x = 1, j.inventory[value.dataName], 1 do
                                        table.insert(j.bufferCache, {item = value.dataName, itemValue = 1})
                                    end
                                end
                            end
                        end
                    end
                    bufferCache = j.bufferCache
                    dxSetRenderTarget(j.gui.bufferRT, true)
                    local maxSlots, assignedItems, usedSlots = math.min(maxSlots, math.max(maxSlots, #bufferCache)), {}, CInventory.fetchParentUsedSlots(localPlayer) or {}
                    local totalContentHeight = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, math.ceil(maxSlots/maximumInventoryRowSlots) - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) + template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding
                    local exceededContentHeight =  totalContentHeight - template.contentWrapper.height
                    dxSetRenderTarget(j.gui.bufferRT, true)
                    if CInventory.CBuffer then
                        for k, v in pairs(CInventory.CBuffer.slots) do
                            if tonumber(k) then
                                local isSlotToBeDrawn = true
                                if v.movementType and v.movementType ~= "inventory" then
                                    isSlotToBeDrawn = false
                                end
                                if not inventoryUI.isSynced then
                                    if v.movementType == "equipment" and v.isAutoReserved then
                                        if (tonumber(j.inventory[v.item]) or 0) <= 0 then
                                            if not bufferCache["__"..v.item] then
                                                table.insert(bufferCache, {item = v.item, itemValue = 1})
                                                bufferCache["__"..v.item] = true
                                            end
                                        end
                                    end
                                end
                                if isSlotToBeDrawn then
                                    if v.movementType then
                                        local itemDetails, itemCategory = getItemDetails(v.item)
                                        if itemDetails and itemCategory and CInventory.CItems[itemDetails.iconPath] then
                                            local slotIndex = k
                                            if slotIndex then
                                                local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                                                local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                                                local iconWidth, iconHeight = 0, template.contentWrapper.itemGrid.inventory.slotSize*verticalSlotsToOccupy
                                                local originalWidth, originalHeight = iconDimensions[itemDetails.iconPath].width, iconDimensions[itemDetails.iconPath].height
                                                iconWidth = (originalWidth / originalHeight)*iconHeight
                                                local slot_row = math.ceil(slotIndex/maximumInventoryRowSlots)
                                                local slot_column = slotIndex - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                                                local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                                local slotWidth, slotHeight = horizontalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding), verticalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding)
                                                if not inventoryUI.attachedItem or (inventoryUI.attachedItem.parent ~= i) or (inventoryUI.attachedItem.prevSlotIndex ~= slotIndex) then
                                                    imports.beautify.native.drawImage(slot_offsetX + ((slotWidth - iconWidth)/2), slot_offsetY + ((slotHeight - iconHeight)/2), iconWidth, iconHeight, CInventory.CItems[itemDetails.iconPath], 0, 0, 0, tocolor(255, 255, 255, 255), false)
                                                end
                                            end
                                        end
                                    else
                                        for m, n in ipairs(bufferCache) do
                                            if v.item == n.item then
                                                if not assignedItems[m] then
                                                    assignedItems[m] = k
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    for k, v in ipairs(bufferCache) do
                        local itemDetails, itemCategory = getItemDetails(v.item)
                        if itemDetails and itemCategory and CInventory.CItems[itemDetails.iconPath] then
                            local slotIndex = assignedItems[k] or false
                            if slotIndex then
                                local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                                local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                                local iconWidth, iconHeight = 0, template.contentWrapper.itemGrid.inventory.slotSize*verticalSlotsToOccupy
                                local originalWidth, originalHeight = iconDimensions[itemDetails.iconPath].width, iconDimensions[itemDetails.iconPath].height
                                iconWidth = (originalWidth / originalHeight)*iconHeight
                                local slot_row = math.ceil(slotIndex/maximumInventoryRowSlots)
                                local slot_column = slotIndex - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                                local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                local slotWidth, slotHeight = horizontalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding), verticalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding)
                                local isItemToBeDrawn = true
                                if inventoryUI.attachedItem and (inventoryUI.attachedItem.parent == i) and (inventoryUI.attachedItem.prevSlotIndex == slotIndex) then 
                                    if not inventoryUI.attachedItem.reservedSlotType then
                                        isItemToBeDrawn = false
                                    end
                                end
                                if isItemToBeDrawn then
                                    imports.beautify.native.drawImage(slot_offsetX + ((slotWidth - iconWidth)/2), slot_offsetY + ((slotHeight - iconHeight)/2), iconWidth, iconHeight, CInventory.CItems[itemDetails.iconPath], 0, 0, 0, tocolor(255, 255, 255, 255), false)
                                end
                                if not inventoryUI.attachedItem and isUIEnabled then
                                    if (slot_offsetY >= 0) and ((slot_offsetY + slotHeight) <= template.contentWrapper.height) then
                                        local isSlotHovered = isMouseOnPosition(j.gui.startX + template.contentWrapper.startX + slot_offsetX, j.gui.startY + template.contentWrapper.startY + slot_offsetY, slotWidth, slotHeight)
                                        if isSlotHovered then
                                            equipmentInformation = itemDetails.itemName..":\n"..itemDetails.description
                                            if isLMBClicked then
                                                local CLIENT_CURSOR_OFFSET[1], CLIENT_CURSOR_OFFSET[2] = getAbsoluteCursorPosition()
                                                local prev_offsetX, prev_offsetY = j.gui.startX + template.contentWrapper.startX + slot_offsetX, j.gui.startY + template.contentWrapper.startY + slot_offsetY
                                                local prev_width, prev_height = iconWidth, iconHeight
                                                local attached_offsetX, attached_offsetY = CLIENT_CURSOR_OFFSET[1] - prev_offsetX, CLIENT_CURSOR_OFFSET[2] - prev_offsetY
                                                attachInventoryItem(i, v.item, itemCategory, slotIndex, horizontalSlotsToOccupy, verticalSlotsToOccupy, prev_offsetX, prev_offsetY, prev_width, prev_height, attached_offsetX, attached_offsetY)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    for k = 1, maxSlots, 1 do
                        if not usedSlots[k] then
                            local slot_row = math.ceil(k/maximumInventoryRowSlots)
                            local slot_column = k - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                            local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                            local isSlotToBeDrawn = true
                            if inventoryUI.attachedItem and inventoryUI.attachedItem.parent and isElement(inventoryUI.attachedItem.parent) and inventoryUI.attachedItem.parent ~= localPlayer and inventoryUI.attachedItem.animTickCounter and inventoryUI.attachedItem.releaseType and inventoryUI.attachedItem.releaseType == "ordering" then
                                local slotIndexesToOccupy = {}
                                for m = inventoryUI.attachedItem.prevSlotIndex, inventoryUI.attachedItem.prevSlotIndex + (inventoryUI.attachedItem.occupiedRowSlots - 1), 1 do
                                    if m <= maxSlots then
                                        for x = 1, inventoryUI.attachedItem.occupiedColumnSlots, 1 do
                                            local succeedingColumnIndex = m + (maximumInventoryRowSlots*(x - 1))
                                            if succeedingColumnIndex <= maxSlots then
                                                if k == succeedingColumnIndex then
                                                    isSlotToBeDrawn = false
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if isSlotToBeDrawn then
                                dxDrawRectangle(slot_offsetX, slot_offsetY, template.contentWrapper.itemGrid.inventory.slotSize, template.contentWrapper.itemGrid.inventory.slotSize, tocolor(unpack(template.contentWrapper.itemGrid.slot.bgColor)), false)
                            end
                        else
                            if CInventory.CBuffer.slots[k] and CInventory.CBuffer.slots[k].movementType and CInventory.CBuffer.slots[k].movementType == "equipment" then
                                local itemDetails, itemCategory = getItemDetails(CInventory.CBuffer.slots[k].item)
                                if itemDetails and itemCategory then
                                    local horizontalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemHorizontalSlots) or 1)
                                    local verticalSlotsToOccupy = math.max(1, tonumber(itemDetails.itemVerticalSlots) or 1)
                                    local slot_row = math.ceil(k/maximumInventoryRowSlots)
                                    local slot_column = k - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                                    local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                    local slotWidth, slotHeight = horizontalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((horizontalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding), verticalSlotsToOccupy*template.contentWrapper.itemGrid.inventory.slotSize + ((verticalSlotsToOccupy - 1)*template.contentWrapper.itemGrid.padding)
                                    local equippedIndex = CInventory.CBuffer.slots[k].equipmentIndex
                                    if not equippedIndex then
                                        for m, n in pairs(inventoryUI.gui.equipment.slot) do
                                            if CInventory.CBuffer.slots[m] and CInventory.CBuffer.slots[m] == CInventory.CBuffer.slots[k].item then
                                                equippedIndex = m
                                                break
                                            end
                                        end
                                    end
                                    if equippedIndex then
                                        dxDrawText(string.upper("EQUIPPED: "..equippedIndex), slot_offsetX, slot_offsetY, slot_offsetX + slotWidth, slot_offsetY + slotHeight, tocolor(unpack(template.contentWrapper.itemGrid.slot.fontColor)), 1, template.contentWrapper.itemGrid.slot.font.instance, "right", "bottom", true, true, false)
                                    end
                                end
                            end
                        end
                    end
                    if inventoryUI.attachedItem and not inventoryUI.attachedItem.animTickCounter then
                        for k = 1, maxSlots, 1 do
                            if not usedSlots[k] then
                                local slot_row = math.ceil(k/maximumInventoryRowSlots)
                                local slot_column = k - (math.max(0, slot_row - 1)*maximumInventoryRowSlots)
                                local slot_offsetX, slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                if (slot_offsetY >= 0) and ((slot_offsetY + template.contentWrapper.itemGrid.inventory.slotSize) <= template.contentWrapper.height) then
                                    local isSlotHovered = isMouseOnPosition(j.gui.startX + template.contentWrapper.startX + slot_offsetX, j.gui.startY + template.contentWrapper.startY + slot_offsetY, template.contentWrapper.itemGrid.inventory.slotSize, template.contentWrapper.itemGrid.inventory.slotSize)
                                    if isSlotHovered then
                                        local isSlotAvailable = isPlayerSlotAvailableForOrdering(localPlayer, inventoryUI.attachedItem.item, k, inventoryUI.attachedItem.isEquippedItem)
                                        if isSlotAvailable then
                                            isItemAvailableForOrdering = {
                                                slotIndex = k,
                                                offsetX = slot_offsetX,
                                                offsetY = slot_offsetY
                                            }
                                        end
                                        for m = k, k + (inventoryUI.attachedItem.occupiedRowSlots - 1), 1 do
                                            for x = 1, inventoryUI.attachedItem.occupiedColumnSlots, 1 do
                                                local succeedingColumnIndex = m + (maximumInventoryRowSlots*(x - 1))
                                                if succeedingColumnIndex <= maxSlots and not usedSlots[succeedingColumnIndex] then
                                                    local _slot_row = math.ceil(succeedingColumnIndex/maximumInventoryRowSlots)
                                                    local _slot_column = succeedingColumnIndex - (math.max(0, _slot_row - 1)*maximumInventoryRowSlots)
                                                    local _slot_offsetX, _slot_offsetY = template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, _slot_column - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)), template.contentWrapper.padding + template.contentWrapper.itemGrid.padding + (math.max(0, _slot_row - 1)*(template.contentWrapper.itemGrid.inventory.slotSize + template.contentWrapper.itemGrid.padding)) - (exceededContentHeight*j.gui.scroller.percent*0.01)
                                                    if _slot_column >= slot_column then
                                                        dxDrawRectangle(_slot_offsetX, _slot_offsetY, template.contentWrapper.itemGrid.inventory.slotSize, template.contentWrapper.itemGrid.inventory.slotSize, tocolor(unpack((isSlotAvailable and template.contentWrapper.itemGrid.slot.availableBGColor) or template.contentWrapper.itemGrid.slot.unavailableBGColor)), false)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    dxSetRenderTarget()
                    imports.beautify.native.drawImage(j.gui.startX + template.contentWrapper.startX, j.gui.startY + template.contentWrapper.startY, template.contentWrapper.width, template.contentWrapper.height, j.gui.bufferRT, 0, 0, 0, tocolor(255, 255, 255, 255*inventoryOpacityPercent), inventoryUI.gui.postGUI)
                    if exceededContentHeight > 0 then
                        local scrollOverlayStartX, scrollOverlayStartY = j.gui.startX + template.scrollBar.overlay.startX, j.gui.startY + template.scrollBar.overlay.startY
                        local scrollOverlayWidth, scrollOverlayHeight =  template.scrollBar.overlay.width, template.scrollBar.overlay.height
                        dxDrawRectangle(scrollOverlayStartX, scrollOverlayStartY, scrollOverlayWidth, scrollOverlayHeight, tocolor(template.scrollBar.overlay.bgColor[1], template.scrollBar.overlay.bgColor[2], template.scrollBar.overlay.bgColor[3], template.scrollBar.overlay.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
                        local scrollBarWidth, scrollBarHeight =  scrollOverlayWidth, template.scrollBar.bar.height
                        local scrollBarStartX, scrollBarStartY = scrollOverlayStartX, scrollOverlayStartY + ((scrollOverlayHeight - scrollBarHeight)*j.gui.scroller.percent*0.01)
                        dxDrawRectangle(scrollBarStartX, scrollBarStartY, scrollBarWidth, scrollBarHeight, tocolor(template.scrollBar.bar.bgColor[1], template.scrollBar.bar.bgColor[2], template.scrollBar.bar.bgColor[3], template.scrollBar.bar.bgColor[4]*inventoryOpacityPercent), inventoryUI.gui.postGUI)
                        if prevScrollState and (not inventoryUI.attachedItem or not inventoryUI.attachedItem.animTickCounter) and (isMouseOnPosition(scrollOverlayStartX, scrollOverlayStartY, scrollOverlayWidth, scrollOverlayHeight) or isMouseOnPosition(j.gui.startX + template.contentWrapper.startX, j.gui.startY + template.contentWrapper.startY, template.contentWrapper.width, template.contentWrapper.height)) then
                            if prevScrollState == "up" then
                                if j.gui.scroller.percent <= 0 then
                                    j.gui.scroller.percent = 0
                                else
                                    if exceededContentHeight < template.contentWrapper.height then
                                        j.gui.scroller.percent = j.gui.scroller.percent - (10*prevScrollStreak.streak)
                                    else
                                        j.gui.scroller.percent = j.gui.scroller.percent - (1*prevScrollStreak.streak)
                                    end
                                    if j.gui.scroller.percent <= 0 then j.gui.scroller.percent = 0 end
                                end
                            elseif prevScrollState == "down" then
                                if j.gui.scroller.percent >= 100 then
                                    j.gui.scroller.percent = 100
                                else
                                    if exceededContentHeight < template.contentWrapper.height then
                                        j.gui.scroller.percent = j.gui.scroller.percent + (10*prevScrollStreak.streak)
                                    else
                                        j.gui.scroller.percent = j.gui.scroller.percent + (1*prevScrollStreak.streak)
                                    end
                                    if j.gui.scroller.percent >= 100 then j.gui.scroller.percent = 100 end
                                end
                            end
                            prevScrollState = false
                        end
                    end
                else
                    if not inventoryUI.isSynced then
                        for k, v in pairs(CInventory.CBuffer.slots) do
                            if tonumber(k) and v.loot and v.loot == i then
                                if v.movementType then
                                    if v.movementType == "loot" and (tonumber(j.inventory[v.item]) or 0) <= 0 then
                                        if not bufferCache["__"..v.item] then
                                            table.insert(bufferCache, {item = v.item, itemValue = 1})
                                            bufferCache["__"..v.item] = true
                                        end
                                    elseif not inventoryUI.attachedItem then
                                        if (v.movementType == "inventory" and not v.isOrdering) or (v.movementType == "equipment" and v.isAutoReserved) then
                                            if not bufferCache["__"..v.item] then
                                                for m, n in ipairs(bufferCache) do
                                                    if n.item == v.item then
                                                        if n.itemValue == 1 then
                                                            table.remove(bufferCache, m)
                                                        else
                                                            n.itemValue = n.itemValue - 1
                                                        end
                                                        bufferCache["__"..v.item] = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end
                    dxSetRenderTarget()
                end
            end
        end
    end
    ]]--
end)