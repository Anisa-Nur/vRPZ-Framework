-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    isInventoryUIEnabled = isInventoryUIEnabled,
    math = math,
    assetify = assetify
}


---------------------------
--[[ Module: Inventory ]]--
---------------------------

CInventory.fetchSlotDimensions = function(rows, columns)
    rows, columns = imports.tonumber(rows), imports.tonumber(columns)
    if not rows or not columns then return false end
    return (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize + FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize)*imports.math.max(0, columns), (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.slotSize + FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.dividerSize)*imports.math.max(0, rows)
end

CInventory.isSlotAvailableForOrdering = function(item, slot, isEquipped)
    slot = imports.tonumber(slot)
    if not CPlayer.isInitialized(localPlayer) or not item or not slot or not imports.isInventoryUIEnabled() then return false end
    local itemData = CInventory.fetchItem(item)
    if not itemData then return false end
    local maxSlots, usedSlots = CInventory.fetchParentMaxSlots(player), CInventory.fetchParentUsedSlots(player)
    if not maxSlots or not usedSlots or (slot > maxSlots) or usedSlots[slot] then return false end
    if not isEquipped then
        --TODO: ...
        --local usedSlots = getElementUsedSlots(player)
        --if (maxSlots - usedSlots) < CInventory.fetchItemWeight(item) then return false end
    end
    local slotRow, slotColumn = CInventory.fetchSlotLocation(slot)
    if (itemData.data.itemWeight.columns - 1) > (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns - slotColumn) then return false end
    for i = slot, slot + (itemData.data.itemWeight.columns - 1), 1 do
        if (i > maxSlots) or usedSlots[i] then
            return false
        else
            for k = 2, itemData.data.itemWeight.rows, 1 do
                local v = i + (FRAMEWORK_CONFIGS["UI"]["Inventory"].inventory.columns*(k - 1))
                if (v > maxSlots) or usedSlots[v] then
                    return false
                end
            end
        end
    end
    return true
end

for i, j in imports.pairs(CInventory.CItems) do
    j.icon = {
        inventory = imports.assetify.getAssetDep(j.pack, i, "texture", "inventory"),
        hud = imports.assetify.getAssetDep(j.slot, i, "texture", "hud")
    }
    j.dimensions = {CInventory.fetchSlotDimensions(j.data.itemWeight.rows, j.data.itemWeight.columns)}
end