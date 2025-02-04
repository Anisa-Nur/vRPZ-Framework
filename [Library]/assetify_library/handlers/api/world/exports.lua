----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: api: world: exports.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: World APIs ]]--
----------------------------------------------------------------


-----------------
--[[ Exports ]]--
-----------------

manager:exportAPI("World", {
    shared = {},
    client = {
        {name = "clearWorld", API = "clearWorld"},
        {name = "restoreWorld", API = "restoreWorld"},
        {name = "toggleOcclusions", API = "toggleOcclusions"},
        {name = "clearModel", API = "clearModel"},
        {name = "restoreModel", API = "restoreModel"}
    },
    server = {}
})