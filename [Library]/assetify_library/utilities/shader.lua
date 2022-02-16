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
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    dxCreateShader = dxCreateShader,
    dxCreateTexture = dxCreateTexture,
    dxSetShaderValue = dxSetShaderValue,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    engineRemoveShaderFromWorldTexture = engineRemoveShaderFromWorldTexture
}


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
        textures = {},
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

function shader:clearElementBuffer(targetElement, shaderCategory)
    if self or (self ~= shader) then return false end
    if not targetElement or not imports.isElement(targetElement) or not buffer.element[targetElement] or (shaderCategory and not buffer.element[targetElement][shaderCategory]) then return false end
    if shaderCategory then
        for i, j in imports.pairs(buffer.element[targetElement]) do
            for k, v in imports.pairs(j) do
                if v and imports.isElement(v) then
                    v:destroy()
                end
            end
        end
        buffer.element[targetElement] = nil
    else
        for i, j in imports.pairs(buffer.element[targetElement][shaderCategory]) do
            if j and imports.isElement(j) then
                j:destroy()
            end
        end
        buffer.element[targetElement][shaderCategory] = nil
    end
    return true
end

function shader:load(shaderCategory, shaderName, textureName, targetElement, shaderData, shaderPriority, shaderDistance)
    if not self or (self == shader) then return false end
    if not shaderCategory or not shaderName or (not shader.preLoaded[shaderName] and not shader.rwCache[shaderName]) or not textureName or not targetElement or not imports.isElement(targetElement) or not shaderData then return false end
    self.isPreLoaded = (shader.preLoaded[shaderName] and true) or false
    shaderPriority = imports.tonumber(shaderPriority) or shader.defaultData.shaderPriority
    shaderDistance = imports.tonumber(shaderDistance) or shader.defaultData.shaderDistance
    self.cShader = (self.isPreLoaded and shader.preLoaded[shaderName]) or imports.dxCreateShader(shader.rwCache[shaderName], shaderPriority, shaderDistance, false, "all")
    self.shaderData = {
        shaderCategory = shaderCategory,
        shaderName = shaderName,
        textureName = textureName,
        targetElement = targetElement,
        shaderData = shaderData,
        shaderPriority = shaderPriority,
        shaderDistance = shaderDistance
    }
    buffer.element[targetElement] = buffer.element[targetElement] or {}
    buffer.element[targetElement][shaderCategory] = buffer.element[targetElement][shaderCategory] or {}
    buffer.element[targetElement][shaderCategory][textureName] = self
    imports.engineApplyShaderToWorldTexture(self.cShader, textureName, targetElement)
    return true
end

function shader:unload()
    if not self or (self == shader) then return false end
    if not self.preLoaded then
        if imports.isElement(self.cShader) then
            imports.destroyElement(self.cShader)
        end
    else
        imports.engineRemoveShaderFromWorldTexture(self.cShader, self.shaderData.textureName, self.shaderData.targetElement)
    end
    self = nil
    return true
end