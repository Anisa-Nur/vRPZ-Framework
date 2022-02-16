----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shader.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Shader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    decodeString = decodeString,
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    setmetatable = setmetatable,
    dxCreateShader = dxCreateShader,
    dxCreateTexture = dxCreateTexture,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture,
    file = file
}

imports.dxCreateCustomTexture = function(texturePath, encryptKey, ...)
    if not texturePath then return false end
    if encryptKey then
        local cTexturePath = texturePath..".tmp"
        if imports.file.write(cTexturePath, imports.decodeString("tea", imports.file.read(texturePath), {key = encryptKey})) then
            local cTexture = imports.dxCreateTexture(cTexturePath, ...)
            imports.file.delete(cTexturePath)
            return cTexture
        end
    else
        return imports.dxCreateTexture(texturePath, ...)
    end
    return false
end


-----------------------
--[[ Class: Shader ]]--
-----------------------

shader = {
    defaultData = {
        shaderPriority = 10000,
        shaderDistance = 0
    },
    preLoadedTex = {
        invisibleMap = imports.dxCreateTexture(2, 2, "dxt5", "clamp")
    },
    buffer = {
        texture = {},
        element = {}
    },
    rwCache = shaderRW
}
shaderRW = nil
shader.preLoaded = {
    ["Assetify_TextureClearer"] = imports.dxCreateShader(shader.rwCache["Assetify_TextureChanger"], shader.defaultData.shaderPriority, shader.defaultData.shaderDistance, false, "all")
}
imports.dxSetShaderValue(shader.preLoaded["Assetify_TextureClearer"], "baseTexture", shader.preLoadedTex.invisibleMap)
shader.__index = shader

function shader:create(...)
    local cShader = imports.setmetatable({}, {__index = self})
    if not cShader:load(...) then
        cShader = nil
        return false
    end
    return cShader
end

function shader:destroy(...)
    if not self or (self == shader) then return false end
    return self:unload(...)
end

function shader:clearAssetBuffer(assetType, assetName)
    local textureReference = (shader.buffer.texture[assetType] and shader.buffer.texture[assetType][assetName]) or false
    if textureReference then
        for i, j in imports.pairs(textureReference) do
            if j and imports.isElement(j) then
                imports.destroyElement(shader.buffer.texture[j].textureElement)
            end
        end
    end
    return true
end

function shader:clearElementBuffer(element, shaderCategory)
    if not element or not imports.isElement(element) or not shader.buffer.element[element] or (shaderCategory and not shader.buffer.element[element][shaderCategory]) then return false end
    if not shaderCategory then
        for i, j in imports.pairs(shader.buffer.element[element]) do
            for k, v in imports.pairs(j) do
                if v and imports.isElement(v) then
                    v:destroy()
                end
            end
        end
        shader.buffer.element[element] = nil
    else
        for i, j in imports.pairs(shader.buffer.element[element][shaderCategory]) do
            if j then
                j:destroy()
            end
        end
        shader.buffer.element[element][shaderCategory] = nil
    end
    return true
end
imports.addEventHandler("onClientElementDestroy", resourceRoot, function() shader:clearElementBuffer(source) end)

function shader:load(element, shaderCategory, shaderName, textureName, shaderTextures, encryptKey, shaderPriority, shaderDistance)
    if not self or (self == shader) then return false end
    if not element or not imports.isElement(element) or not shaderCategory or not shaderName or (not shader.preLoaded[shaderName] and not shader.rwCache[shaderName]) or not textureName or not shaderTextures then return false end
    shaderPriority = imports.tonumber(shaderPriority) or shader.defaultData.shaderPriority
    shaderDistance = imports.tonumber(shaderDistance) or shader.defaultData.shaderDistance
    self.isPreLoaded = (shader.preLoaded[shaderName] and true) or false
    self.cShader = (self.isPreLoaded and shader.preLoaded[shaderName]) or imports.dxCreateShader(shader.rwCache[shaderName], shaderPriority, shaderDistance, false, "all")
    for i, j in imports.pairs(shaderTextures) do
        if j and imports.file.exists(j) then
            shader.buffer.texture[j] = shader.buffer.texture[j] or {
                textureElement = imports.dxCreateCustomTexture(j, encryptKey, "dxt5", true)
            }
            imports.dxSetShaderValue(self.cShader, i, shader.buffer.texture[j].textureElement)
        end
    end
    self.shaderData = {
        element = element,
        shaderCategory = shaderCategory,
        shaderName = shaderName,
        textureName = textureName,
        shaderTextures = shaderTextures,
        shaderPriority = shaderPriority,
        shaderDistance = shaderDistance
    }
    shader.buffer.element[element] = shader.buffer.element[element] or {}
    shader.buffer.element[element][shaderCategory] = shader.buffer.element[element][shaderCategory] or {}
    shader.buffer.element[element][shaderCategory][textureName] = self
    imports.engineApplyShaderToWorldTexture(self.cShader, textureName, element)
    return true
end

function shader:unload()
    if not self or (self == shader) then return false end
    if not self.preLoaded then
        if self.cShader and imports.isElement(self.cShader) then
            imports.destroyElement(self.cShader)
        end
    else
        imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.element)
    end
    shader.buffer.element[(self.shaderData.element)][(self.shaderData.shaderCategory)][(self.shaderData.textureName)] = nil
    self = nil
    return true
end