----------------------------------------------------------------
--[[ Resource: Player Handler
     Script: handlers: inventory.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril, Аниса
     DOC: 31/01/2022
     Desc: Inventory Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tonumber = tonumber,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerClientEvent = triggerClientEvent,
    getElementData = getElementData
}


-------------------------------
--[[ Player: On Order Item ]]--
-------------------------------

imports.addEvent("Player:onAddItem", true)
imports.addEventHandler("Player:onAddItem", root, function(item, parent, prevSlot, newSlot)
    if not CPlayer.isInitialized(source) then return false end
    prevSlot, newSlot = imports.tonumber(prevSlot), imports.tonumber(newSlot)
    local characterID = imports.getElementData(source, "Character:ID")
    local inventoryID = CCharacter.CBuffer[characterID].inventory

    print("WOOW 1: "..tostring(item).." : "..tostring(prevSlot).." : "..tostring(newSlot))
    if item and prevSlot and newSlot and CInventory.isSlotAvailableForOrdering(source, item, newSlot) then
        --TODO: ADD FUNCTION TO GIVE/REVOKE ITEMS ETC
        print("WOOW 2")
        local itemAmount = imports.tonumber(imports.getElementData(source, "Item:"..item)) or 0
        setElementData(localPlayer, "Item:"..item, itemAmounts + 1) --SYNC AMOUNT TOO....
        --TODO: WHY IS IT CLEARING WHEN VICINITY TO INVENTORY?
        --playerInventorySlots[source].slots[prevSlot] = nil --TODO: ONLY FOR ORDER
        CInventory.CBuffer[inventoryID].slots[newSlot] = {
            item = item
        }
    end
    --TODO: MAKE FUNCTON TO GET PLAYER;'S INVENTORY ID' and CHAR ID
    imports.triggerClientEvent(source, "Client:onSyncInventoryBuffer", source, CInventory.CBuffer[inventoryID])
end)


-------------------------------
--[[ Player: On Order Item ]]--
-------------------------------

imports.addEvent("Player:onOrderItem", true)
imports.addEventHandler("Player:onOrderItem", root, function(item, prevSlot, newSlot)

end)