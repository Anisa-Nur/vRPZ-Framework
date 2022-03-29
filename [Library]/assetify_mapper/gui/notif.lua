----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: gui: notif.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Notif UI Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tocolor = tocolor,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    interpolateBetween = interpolateBetween,
    getInterpolationProgress = getInterpolationProgress,
    table = table,
    math = math,
    beautify = beautify
}


-------------------
--[[ Variables ]]--
-------------------

mapper.ui.notif = {
    buffer = {},
    startX = -mapper.ui.margin, startY = 65, paddingY = 10, offsetY = 0, height = 15,
    slideTopTickCounter = CLIENT_CURRENT_TICK, slideTopDuration = 750,
    slideInDuration = 750, slideOutDuration = 750, slideDelayDuration = 750,
    font = availableFonts[1]
}


-------------------------------
--[[ Functions: Renders UI ]]--
-------------------------------

mapper.ui.notif.renderUI = function()
    if #mapper.ui.notif.buffer <= 0 then return imports.beautify.render.remove(mapper.ui.notif.renderUI, {renderType = "input"}) end

    local offsetY = imports.interpolateBetween(mapper.ui.notif.offsetY, 0, 0, 0, 0, 0, imports.getInterpolationProgress(mapper.ui.notif.slideTopTickCounter, mapper.ui.notif.slideTopDuration), "OutBack")
    for i = 1, #mapper.ui.notif.buffer, 1 do
        local j = mapper.ui.notif.buffer[i]
        if j then
            local notifFontColor = j.fontColor
            local notif_width, notif_height = imports.beautify.native.getTextWidth(j.text, 1, mapper.ui.notif.font), mapper.ui.notif.height
            local notif_offsetX, notif_offsetY = 0, 0
            local notifAlphaPercent = 0
            if j.slideStatus == "forward" then
                notif_offsetX, notif_offsetY = imports.interpolateBetween(CLIENT_MTA_RESOLUTION[1], mapper.ui.notif.startY + ((i - 1)*(mapper.ui.notif.height + mapper.ui.notif.paddingY)) - mapper.ui.notif.height, 0, (CLIENT_MTA_RESOLUTION[1]) + mapper.ui.notif.startX - notif_width, mapper.ui.notif.startY + ((i - 1)*(mapper.ui.notif.height + mapper.ui.notif.paddingY)) + offsetY, 0, imports.getInterpolationProgress(j.tickCounter, mapper.ui.notif.slideInDuration), "InOutBack")
                notifAlphaPercent = imports.interpolateBetween(0, 0, 0, 1, 0, 0, imports.getInterpolationProgress(j.tickCounter, mapper.ui.notif.slideInDuration), "Linear")
                if imports.math.round(notifAlphaPercent, 2) == 1 then
                    if (CLIENT_CURRENT_TICK - j.tickCounter - mapper.ui.notif.slideInDuration) >= mapper.ui.notif.slideDelayDuration then
                        j.slideStatus = "backward"
                        j.tickCounter = CLIENT_CURRENT_TICK
                        mapper.ui.notif.offsetY = mapper.ui.notif.height
                        mapper.ui.notif.slideTopTickCounter = CLIENT_CURRENT_TICK
                    end
                end
            else
                notif_offsetX, notif_offsetY = imports.interpolateBetween((CLIENT_MTA_RESOLUTION[1]) + mapper.ui.notif.startX - notif_width, mapper.ui.notif.startY + ((i - 1)*(mapper.ui.notif.height + mapper.ui.notif.paddingY)), 0, CLIENT_MTA_RESOLUTION[1], mapper.ui.notif.startY + ((i - 1)*(mapper.ui.notif.height + mapper.ui.notif.paddingY)) + (mapper.ui.notif.height*0.5) - offsetY, 0, imports.getInterpolationProgress(j.tickCounter, mapper.ui.notif.slideOutDuration), "InOutBack")
                notifAlphaPercent = imports.interpolateBetween(1, 0, 0, 0, 0, 0, imports.getInterpolationProgress(j.tickCounter, mapper.ui.notif.slideOutDuration), "Linear")
            end
            imports.beautify.native.drawText(j.text, notif_offsetX, notif_offsetY, notif_offsetX + notif_width, notif_offsetY + notif_height, imports.tocolor(notifFontColor[1], notifFontColor[2], notifFontColor[3], notifFontColor[4]*notifAlphaPercent), 1, mapper.ui.notif.font, "center", "center", true, false, false, false, true)
            if j.slideStatus == "backward" then
                if imports.math.round(notifAlphaPercent, 2) == 0 then
                    imports.table.remove(mapper.ui.notif.buffer, i)
                end
            end
        end
    end
end


--------------------------------
--[[ Event: On Notification ]]--
--------------------------------

imports.addEvent("Assetify_Mapper:onNotification", true)
imports.addEventHandler("Assetify_Mapper:onNotification", root, function(message, color)
    imports.table.insert(mapper.ui.notif.buffer, {
        text = message,
        fontColor = color,
        slideStatus = "forward",
        tickCounter = CLIENT_CURRENT_TICK
    })
    if #mapper.ui.notif.buffer <= 1 then
        imports.beautify.render.create(mapper.ui.notif.renderUI, {renderType = "input"})
    end
end)

--TODO: REMOVE LATER
bindKey("z", "down", function()
    triggerEvent("Assetify_Mapper:onNotification", root, "Testing Some random Assetify Notif", {175, 175, 175, 255})
    triggerEvent("Assetify_Mapper:onNotification", root, "Testing Some random Assetify Notif Again xDDD", {255, 10, 10, 255})
end)