-----------------
--[[ Exports ]]--
-----------------

function fetchSettings(...) return CGame.fetchSettings(...) end
function updateSettings(...) return CGame.updateSettings(...) end
function loadLanguage(...) return CGame.loadLanguage(...) end
function createFont(...) return CGame.createFont(...) end
function isUIVisible(...) return CGame.isUIVisible(...) end
function loadAnim(...) return CGame.loadAnim(...) end
function unloadAnim(...) return CGame.unloadAnim(...) end
function playSound(...) return CGame.playSound(...) end
function playSound3D(...) return CGame.playSound3D(...) end


----------------
--[[ Events ]]--
----------------

imports.addEvent("Client:onUpdateLanguage", false)
imports.addEventHandler("Client:onUpdateLanguage", root, function(prevLanguage, currLanguage)
    for i, j in imports.pairs(CGame.CFont.dynamic) do
        for k, v in imports.pairs(j) do
            local cData = FRAMEWORK_CONFIGS["Templates"]["Fonts"][i]
            if cData.alt then
                local cResource, cSettings = nil, cData.alt[currLanguage]
                if cData.alt[prevLanguage] or cSettings then
                    if cSettings then cResource = cSettings[3]
                    else cResource = cData.resource end
                    local cPath, cSize = ((cResource and ":"..cResource.."/") or "")..((cSettings and cSettings[1]) or cData.path), (cSettings and cSettings[2] and (cSettings[2]*k)) or k
                    local cFont = imports.beautify.native.createFont(cPath, cSize)
                    if cFont then
                        local __cFont = v.instance
                        v.instance = cFont
                        imports.destroyElement(__cFont)
                    end
                end
            end
        end
    end
    for i, j in imports.pairs(FRAMEWORK_CONFIGS["Templates"]["Beautify"]) do
        local isTemplateUpdated = false
        local cTemplate = imports.beautify.getUITemplate(i)
        if not cTemplate.isVRPZTemplate then
            cTemplate = imports.table.clone(j, true)
            cTemplate.isVRPZTemplate = true
            isTemplateUpdated = true
        end
        if j.font then
            local cData = FRAMEWORK_CONFIGS["Templates"]["Fonts"][(j.font[1])]
            if not cData.alt or not cData.alt[currLanguage] then
                if isTemplateUpdated or (cData.alt and cData.alt[prevLanguage]) then
                    cTemplate.font = {cData.path, j.font[2], cData.resource}
                    isTemplateUpdated = true
                end
            else
                local cResource, cSettings = nil, cData.alt and cData.alt[currLanguage]
                if cData.alt[prevLanguage] or cSettings then
                    if cSettings then cResource = cSettings[3]
                    else cResource = cData.resource end
                    local cPath, cSize = (cSettings and cSettings[1]) or cData.path, (cSettings and cSettings[2] and (cSettings[2]*j.font[2])) or j.font[2]
                    cTemplate.font = {cPath, cSize, cResource}
                    isTemplateUpdated = true
                end
            end
        end
        if isTemplateUpdated then imports.beautify.setUITemplate(i, cTemplate) end
    end
end)
