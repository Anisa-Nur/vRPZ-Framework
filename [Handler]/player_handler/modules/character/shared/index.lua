----------------------------------------------------------------
--[[ Resource: Player Handler
     Script: modules: character: shared: index.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril
     DOC: 31/01/2022
     Desc: Character Module ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tonumber = tonumber,
    getElementsByType,
    getElementPosition = getElementPosition,
    getElementRotation = getElementRotation,
    getElementData = getElementData,
    setElementData = setElementData,
    math = math
}


----------------
--[[ Module ]]--
----------------

CCharacter = {
    getPlayer = function(characterID)
        characterID = imports.tonumber(characterID)
        if not characterID then return false end
        local players = imports.getElementsByType("player")
        for i = 1, #players, 1 do
            local j = players[i]
            if CPlayer.isInitialized(j) then
                local _characterID = imports.getElementData(j, "Character:ID")
                if _characterID == characterID then
                    return j
                end
            end
        end
        return false
    end,

    generateClothing = function(characterIdentity)
        if not characterIdentity then return false end
        return {
            gender = FRAMEWORK_CONFIGS["UI"]["Login"]["Options"].characters.categories["Identity"].gender["Datas"][(characterIdentity.gender)],
            hair = FRAMEWORK_CONFIGS["UI"]["Login"]["Options"].characters.categories["Facial"].hair["Datas"][(characterIdentity.gender)][(characterIdentity.hair)],
            upper = FRAMEWORK_CONFIGS["UI"]["Login"]["Options"].characters.categories["Upper"]["Datas"][(characterIdentity.gender)][((characterIdentity.upper)],
            lower = FRAMEWORK_CONFIGS["UI"]["Login"]["Options"].characters.categories["Lower"]["Datas"][(characterIdentity.gender)][((characterIdentity.lower)],
            shoes = FRAMEWORK_CONFIGS["UI"]["Login"]["Options"].characters.categories["Shoes"]["Datas"][(characterIdentity.gender)][((characterIdentity.shoes)]
        }
    end,

    getLocation = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return {
            position = {imports.getElementPosition(player)},
            rotation = {imports.getElementRotation(player)}
        }
    end,

    setHealth = function(player, amount)
        amount = imports.tonumber(amount)
        if not CPlayer.isInitialized(player) or not amount then return false end
        return imports.setElementData(player, "Character:blood", imports.math.max(0, imports.math.min(amount, CCharacter.getMaxHealth(player))))
    end,

    getHealth = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return imports.tonumber(imports.getElementData(player, "Character:blood")) or 0
    end,

    getMaxHealth = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return FRAMEWORK_CONFIGS["Game"]["Character"]["Max_Blood"]
    end,

    getFaction = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return imports.getElementData(player, "Character:Faction") or false
    end,

    setMoney = function(player, amount)
        money = imports.tonumber(money)
        if not CPlayer.isInitialized(player) or not money then return false end
        return imports.setElementData(player, "Character:money", imports.math.max(0, money))
    end,

    getMoney = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return imports.tonumber(imports.getElementData(player, "Character:money")) or 0
    end,

    isKnocked = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return imports.getElementData(player, "Character:Knocked") or false
    end,

    isReloading = function(player)
        if not CPlayer.isInitialized(player) then return false end
        return imports.getElementData(player, "Character:Reloading") or false
    end,

    isInLoot = function(player)
        if not CPlayer.isInitialized(player) then return false end
        if imports.getElementData(player, "Character:Looting") then
            local marker = imports.getElementData(player, "Loot:Marker")
            if marker and imports.isElement(marker) then
                return marker
            end
        end
        return false
    end
}