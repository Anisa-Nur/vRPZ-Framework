----------------------------------------------------------------
--[[ Resource: Player Handler
     Script: handlers: resumer.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril
     DOC: 31/01/2022
     Desc: Resumer Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerClientEvent = triggerClientEvent,
    setElementFrozen = setElementFrozen,
    setPlayerName = setPlayerName,
    toJSON = toJSON,
    fromJSON = fromJSON,
    table = table
}


-------------------------------------
--[[ Player: On Delete Character ]]--
-------------------------------------

imports.addEvent("Player:onDeleteCharacter", true)
imports.addEventHandler("Player:onDeleteCharacter", root, function(characterID)
    CCharacter.delete(characterID)
end)


-----------------------------------
--[[ Player: On Save Character ]]--
-----------------------------------

imports.addEvent("Player:onSaveCharacter", true)
imports.addEventHandler("Player:onSaveCharacter", root, function(characterID, characters, unsavedChars)
    characterID = tonumber(characterID)
    if not characterID or not characterID or not unsavedChars then return false end

    local serial = CPlayer.getSerial(source)
    --TODO: NEEDS REFACTOR LATER MAYBE
    for i, j in imports.pairs(unsavedChars) do
        if characters[i] then
            for k, v in imports.pairs(characterCache) do
                if v["identity"]["name"] == characters[i]["name"] then
                    imports.triggerClientEvent(source, "onClientLoginUIEnable", source, true, true)
                    imports.triggerClientEvent(source, "onClientRecieveCharacterSaveState", source, false, "Unfortunately, '"..characters[i]["name"].."' is already registered!", i)
                    return false
                end
            end
            local characterID = CCharacter.create(serial, function(characterID, Args)
                CCharacter.setData(characterID, "identity", imports.toJSON(characters[i]))
                characterCache[characterID]["identity"] = fromJSON(characterCache[characterID]["identity"])
                imports.triggerClientEvent(Args[1], "onClientLoadCharacterID", Args[1], i, characterID, characters[i])
            end, source)
        end
    end
    CPlayer.setData(serial, {"character", characterID})
    imports.triggerClientEvent(source, "onClientRecieveCharacterSaveState", source, true)
end)


------------------------------------
--[[ Player: On Toggle Login UI ]]--
------------------------------------

imports.addEvent("Player:onToggleLoginUI", true)
imports.addEventHandler("Player:onToggleLoginUI", root, function()
    imports.setElementFrozen(source, true)
    imports.setPlayerName(source, CPlayer.generateNick())

    local lastCharacter = CPlayer.getData(CPlayer.getSerial(source), {
        "character",
        "characters",
        "premimum"
    }, function(result, Args)
        result.character = result.character or 0
        result.characters = (result.characters and imports.fromJSON(result.characters)) or {}
        result.premimum = (result.premimum and true) or false

        if (#result.characters > 0) then
            CCharacter.fetch(result.characters, function(result, Args)
                Args[2].characters = result
                for i = 1, #Args[2].characters, 1 do
                    local j = Args[2].characters[i]
                    j["identity"] = imports.fromJSON(j["identity"])
                end
                if not Args[2].characters[(Args[2].character)] then Args[2].character = 0 end
                imports.triggerClientEvent(Args[1], "Client:onToggleLoadingUI", Args[1], {
                    character = Args[2].character,
                    characters = Args[2].characters,
                    isPremium = Args[2].premimum
                })
            end, Args[1], result)
        else
            result.character = 0
            imports.triggerClientEvent(Args[1], "Client:onToggleLoadingUI", Args[1], {
                character = result.character,
                characters = result.characters,
                isPremium = result.premimum
            })
        end
    end, source)
end)