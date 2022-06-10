----------------------------------------------------------------
--[[ Resource: Player Handler
     Script: utilities: server.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril, Аниса
     DOC: 31/01/2022
     Desc: Server Sided Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    isElement = isElement,
    createElement = createElement,
    getElementType = getElementType,
    getElementsByType = getElementsByType,
    getTickCount = getTickCount,
    addEventHandler = addEventHandler,
    cancelEvent = cancelEvent,
    triggerEvent = triggerEvent,
    triggerClientEvent = triggerClientEvent,
    getPlayerName = getPlayerName,
    setElementData = setElementData,
    setTimer = setTimer,
    outputChatBox = outputChatBox,
    setFPSLimit = setFPSLimit,
    setMaxPlayers = setMaxPlayers,
    setFarClipDistance = setFarClipDistance,
    setFogDistance = setFogDistance,
    setAircraftMaxHeight = setAircraftMaxHeight,
    setJetpackMaxHeight = setJetpackMaxHeight,
    setMinuteDuration = setMinuteDuration,
    setGameType = setGameType,
    setMapName = setMapName,
    math = math,
    assetify = assetify,
    thread = thread,
    network = network
}
imports.assetify.execOnModuleLoad(function()
    imports.assetify.loadModule("DBify_Library", {"shared", "server"})
    imports.assetify.loadModule("vRPZ_Config", {"shared", "server"})
    imports.assetify.loadModule("vRPZ_Core", {"shared", "server"})
    imports.assetify.scheduleExec.boot()
end)


---------------------------------------
--[[ Function: Overrides Show Chat ]]--
---------------------------------------

function showChat(player, bool, isForced)
    if (not player or not imports.isElement(player) or (imports.getElementType(player) ~= "player")) then return false end
    imports.triggerClientEvent(player, "Client:onToggleChat", player, bool, isForced)
    return true
end


-------------------------
--[[ Utility Helpers ]]--
-------------------------

CGame.execOnModuleLoad(function()
    local serverNetwork = imports.network:create("onServerRender")
    imports.setTimer(function(tickSyncer, serverNetwork)
        if tickSyncer and imports.isElement(tickSyncer) then
            local cTickCount = imports.getTickCount()
            imports.setElementData(tickSyncer, "Server:TickSyncer", cTickCount)
            serverNetwork:emit(tickSyncer, cTickCount, FRAMEWORK_CONFIGS["Game"]["Sync_Rate"])
        end
    end, FRAMEWORK_CONFIGS["Game"]["Sync_Rate"], 0, imports.createElement("Server:TickSyncer"), serverNetwork)
    imports.setFPSLimit(FRAMEWORK_CONFIGS["Game"]["FPS_Limit"])
    imports.setMaxPlayers(FRAMEWORK_CONFIGS["Game"]["Player_Limit"])
    imports.setFarClipDistance(FRAMEWORK_CONFIGS["Game"]["Draw_Distance_Limit"][2])
    imports.setFogDistance(FRAMEWORK_CONFIGS["Game"]["Fog_Distance_Limit"][2])
    imports.setAircraftMaxHeight(FRAMEWORK_CONFIGS["Game"]["Aircraft_Max_Height"])
    imports.setJetpackMaxHeight(FRAMEWORK_CONFIGS["Game"]["Jetpack_Max_Height"])
    imports.setMinuteDuration(FRAMEWORK_CONFIGS["Game"]["Minute_Duration"])
    imports.setGameType(FRAMEWORK_CONFIGS["Game"]["Game_imports.type"])
    imports.setMapName(FRAMEWORK_CONFIGS["Game"]["Game_Map"])
    imports.setTimer(function()
        for i, j in imports.pairs(CPlayer.CLogged) do
            CCharacter.giveReputation(i, FRAMEWORK_CONFIGS["Templates"]["Reputations"]["Regeneration_Amount"])
        end
    end, FRAMEWORK_CONFIGS["Templates"]["Reputations"]["Regeneration_Duration"], 0)

    --[[
    for i, j in pairs(availableWeaponSlots) do
        for k, v in pairs(j.slots) do
            if v.properties then
                for m, n in pairs(v.properties) do
                    setWeaponProperty(k, "poor", m, n)
                    setWeaponProperty(k, "std", m, n)
                    setWeaponProperty(k, "pro", m, n)
                end
            end  
        end
        for k, v in imports.ipairs(inventoryDatas[i]) do
            if v.magSize then
                setWeaponProperty(v.weaponID, "poor", "maximum_clip_ammo", 1000)
                setWeaponProperty(v.weaponID, "std", "maximum_clip_ammo", 1000)
                setWeaponProperty(v.weaponID, "pro", "maximum_clip_ammo", 1000)
            end
        end
    end
    ]]--

    imports.network:fetch("onServerRender"):on(function(_, deltaTick)
        for i, j in imports.pairs(CPlayer.CLogged) do
            CCharacter.giveSurvivalTime(i, deltaTick)
        end
    end)
    imports.addEventHandler("onPlayerChangeNick", root, function() imports.cancelEvent() end)
    imports.addEventHandler("onPlayerCommand", root, function(command)
        local disabledCMDs = FRAMEWORK_CONFIGS["Game"]["Disabled_CMDS"]
        for i = 1, #disabledCMDs, 1 do
            local j = FRAMEWORK_CONFIGS["Game"]["Disabled_CMDS"][i]
            if j == command then
                imports.cancelEvent()
                if command == "logout" then
                    if CPlayer.isInitialized(source) then
                        local cooldownETA, prevResumeTick = false, getResumeTick(source)
                        if prevResumeTick then
                            local elapsedDuration = imports.getTickCount() - prevResumeTick
                            cooldownETA = ((elapsedDuration < FRAMEWORK_CONFIGS["Game"]["Logout_CoolDown_Duration"]) and (FRAMEWORK_CONFIGS["Game"]["Logout_CoolDown_Duration"] - elapsedDuration)) or false
                        end
                        if cooldownETA then
                            imports.triggerClientEvent(source, "Client:onNotification", source, "Please wait "..imports.math.ceil(cooldownETA/1000).."s before logging out!", FRAMEWORK_CONFIGS["UI"]["Notification"].presets.error)
                        else
                            local __source = source
                            imports.thread:create(function(self)
                                local source = __source
                                imports.triggerClientEvent(source, "Client:onToggleLoadingUI", source, true)
                                imports.outputChatBox("#C8C8C8- #5050FF"..(imports.getPlayerName(source)).."#C8C8C8 left. #5050FF[Reason: Logout]", root, 255, 255, 255, true)
                                CCharacter.saveProgress(self, source)
                                imports.triggerEvent("Player:onToggleLoginUI", source)
                            end):resume()
                        end
                    end
                end
                break
            end
        end
    end)
end)

imports.addEventHandler("onResourceStop", resource, function()
    local serverPlayers = imports.getElementsByType("player")
    imports.thread:create(function(self)
        for i = 1, #serverPlayers, 1 do
            local j = serverPlayers[i]
            CCharacter.saveProgress(self, j)
        end
    end):resume()
end)