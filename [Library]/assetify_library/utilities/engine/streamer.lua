----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: streamer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Streamer Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    collectgarbage = collectgarbage,
    getCamera = getCamera,
    isElement = isElement,
    addDebugHook = addDebugHook,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    getTickCount = getTickCount,
    setElementMatrix = setElementMatrix,
    getElementMatrix = getElementMatrix,
    isElementOnScreen = isElementOnScreen,
    getElementCollisionsEnabled = getElementCollisionsEnabled,
    setElementCollisionsEnabled = setElementCollisionsEnabled,
    getElementPosition = getElementPosition,
    getElementDimension = getElementDimension,
    setElementDimension = setElementDimension,
    getElementInterior = getElementInterior,
    setElementInterior = setElementInterior,
    getElementVelocity = getElementVelocity
}


-------------------------
--[[ Class: Streamer ]]--
-------------------------

local streamer = class:create("streamer")
streamer.private.allocator = {
    validStreams = {
        ["dummy"] = {desyncOccclusionsOnPause = true},
        ["bone"] = {skipAttachment = true, dynamicStreamAllocation = true},
        ["light"] = {desyncOccclusionsOnPause = true}
    }
}
streamer.private.ref = {}
streamer.private.attached = {element = {}, parent = {}}
streamer.private.buffer = {}
streamer.private.cache = {
    clientCamera = getCamera()
}

function streamer.public:create(...)
    local cStreamer = self:createInstance()
    if cStreamer and not cStreamer:load(...) then
        cStreamer:destroyInstance()
        return false
    end
    return cStreamer
end

function streamer.public:destroy(...)
    if not streamer.public:isInstance(self) then return false end
    return self:unload(...)
end

function streamer.public:attachElements(element, parent, offX, offY, offZ, rotX, rotY, rotZ)
    offX, offY, offZ, rotX, rotY, rotZ = imports.tonumber(offX) or 0, imports.tonumber(offY) or 0, imports.tonumber(offZ) or 0, imports.tonumber(rotX) or 0, imports.tonumber(rotY) or 0, imports.tonumber(rotZ) or 0
    if not imports.isElement(element) or not imports.isElement(parent) or (element == parent) then return false end
    streamer.public:detachElements(element)
    streamer.private.attached.parent[parent] = streamer.private.attached.parent[parent] or {}
    streamer.private.attached.parent[parent][element] = true
    streamer.private.attached.element[element] = {
        parent = parent,
        position = {x = offX, y = offY, z = offZ},
        rotation = {x = rotX, y = rotY, z = rotZ, matrix = math.matrix:fromRotation(rotX, rotY, rotZ)}
    }
    streamer.private.updateAttachments(parent, element)
    return true
end

function streamer.public:detachElements(element)
    if not element or (not streamer.private.attached.element[element] and not streamer.private.attached.parent[element]) then return false end
    if streamer.private.attached.parent[element] then
        for i, j in imports.pairs(streamer.private.attached.parent[element]) do
            streamer.public:detachElements(i)
        end
    end
    if streamer.private.attached.element[element] then
        if streamer.private.attached.parent[(streamer.private.attached.element[element].parent)] then
            streamer.private.attached.parent[(streamer.private.attached.element[element].parent)][element] = nil
        end
        streamer.private.attached.element[element].rotation.matrix:destroyInstance()
    end
    streamer.private.attached.element[element] = nil
    streamer.private.attached.parent[element] = nil
    imports.collectgarbage()
    return true
end

function streamer.private.updateAttachments(parent, element, parentMatrix)
    if not parent or not streamer.private.attached.parent[parent] then return false end
    parentMatrix = parentMatrix or imports.getElementMatrix(parent)
    if element then
        local cPointer = streamer.private.attached.element[element]
        if cPointer then
            local rotationMatrix = cPointer.rotation.matrix.rows
            local offX, offY, offZ = cPointer.position.x, cPointer.position.y, cPointer.position.z
            imports.setElementMatrix(element, {
                {
                    (parentMatrix[2][1]*rotationMatrix[1][2]) + (parentMatrix[1][1]*rotationMatrix[1][1]) + (rotationMatrix[1][3]*parentMatrix[3][1]),
                    (parentMatrix[3][2]*rotationMatrix[1][3]) + (parentMatrix[1][2]*rotationMatrix[1][1]) + (parentMatrix[2][2]*rotationMatrix[1][2]),
                    (parentMatrix[2][3]*rotationMatrix[1][2]) + (parentMatrix[3][3]*rotationMatrix[1][3]) + (rotationMatrix[1][1]*parentMatrix[1][3]),
                    0
                },
                {
                    (rotationMatrix[2][3]*parentMatrix[3][1]) + (parentMatrix[2][1]*rotationMatrix[2][2]) + (rotationMatrix[2][1]*parentMatrix[1][1]),
                    (parentMatrix[3][2]*rotationMatrix[2][3]) + (parentMatrix[2][2]*rotationMatrix[2][2]) + (parentMatrix[1][2]*rotationMatrix[2][1]),
                    (rotationMatrix[2][1]*parentMatrix[1][3]) + (parentMatrix[3][3]*rotationMatrix[2][3]) + (parentMatrix[2][3]*rotationMatrix[2][2]),
                    0
                },
                {
                    (parentMatrix[2][1]*rotationMatrix[3][2]) + (rotationMatrix[3][3]*parentMatrix[3][1]) + (rotationMatrix[3][1]*parentMatrix[1][1]),
                    (parentMatrix[3][2]*rotationMatrix[3][3]) + (parentMatrix[2][2]*rotationMatrix[3][2]) + (rotationMatrix[3][1]*parentMatrix[1][2]),
                    (rotationMatrix[3][1]*parentMatrix[1][3]) + (parentMatrix[3][3]*rotationMatrix[3][3]) + (parentMatrix[2][3]*rotationMatrix[3][2]),
                    0
                },
                {
                    (offZ*parentMatrix[1][1]) + (offY*parentMatrix[2][1]) - (offX*parentMatrix[3][1]) + parentMatrix[4][1],
                    (offZ*parentMatrix[1][2]) + (offY*parentMatrix[2][2]) - (offX*parentMatrix[3][2]) + parentMatrix[4][2],
                    (offZ*parentMatrix[1][3]) + (offY*parentMatrix[2][3]) - (offX*parentMatrix[3][3]) + parentMatrix[4][3],
                    1
                }
            })
        end
    else
        for i, j in imports.pairs(streamer.private.attached.parent[parent]) do
            if j and streamer.private.attached.element[i] then
                streamer.private.updateAttachments(parent, i, parentMatrix)
            end
        end
    end
    return true
end

function streamer.public:load(streamerInstance, streamType, occlusionInstances, syncRate)
    if not streamer.public:isInstance(self) then return false end
    if not streamerInstance or not streamType or not imports.isElement(streamerInstance) or not occlusionInstances or not occlusionInstances[1] or not imports.isElement(occlusionInstances[1]) then return false end
    self.streamer, self.isStreamerCollidable = streamerInstance, imports.getElementCollisionsEnabled(streamerInstance)
    self.streamType, self.occlusions = streamType, occlusionInstances
    self.dimension, self.interior = imports.getElementDimension(occlusionInstances[1]), imports.getElementInterior(occlusionInstances[1])
    self.syncRate = settings.streamer.streamRate
    self:resume()
    return true
end

function streamer.public:unload()
    if not streamer.public:isInstance(self) then return false end
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self] = nil
    self:pause()
    self:destroyInstance()
    return true
end

function streamer.public:resume()
    if not streamer.public:isInstance(self) or self.isResumed then return false end
    if self.streamer ~= self.occlusions[1] then
        if not streamer.private.allocator.validStreams[(self.streamType)] or not streamer.private.allocator.validStreams[(self.streamType)].skipAttachment then
            streamer.public:attachElements(self.streamer, self.occlusions[1])
        end
        imports.setElementDimension(self.streamer, self.dimension)
        imports.setElementInterior(self.streamer, self.interior)
    end
    for i = 1, #self.occlusions do
        local j = self.occlusions[i]
        streamer.private.ref[j] = streamer.private.ref[j] or {}
        streamer.private.ref[j][self] = true
        if streamer.private.allocator.validStreams[(self.streamType)] and streamer.private.allocator.validStreams[(self.streamType)].desyncOccclusionsOnPause then
            imports.setElementDimension(j, self.dimension)
        end
    end
    self.isResumed = true
    imports.setElementCollisionsEnabled(self.streamer, self.isStreamerCollidable)
    streamer.private.buffer[(self.dimension)] = streamer.private.buffer[(self.dimension)] or {}
    streamer.private.buffer[(self.dimension)][(self.interior)] = streamer.private.buffer[(self.dimension)][(self.interior)] or {}
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)] = streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)] or {}
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self] = true
    self:allocate()
    return true
end

function streamer.public:pause()
    if not streamer.public:isInstance(self) or not self.isResumed then return false end
    self:deallocate()
    self.isResumed = false
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self] = nil
    if self.streamer ~= self.occlusions[1] then
        if not streamer.private.allocator.validStreams[(self.streamType)] or not streamer.private.allocator.validStreams[(self.streamType)].skipAttachment then
            streamer.public:detachElements(self.streamer)
        end
        imports.setElementDimension(self.streamer, settings.streamer.unsyncDimension)
    end
    for i = 1, #self.occlusions do
        local j = self.occlusions[i]
        streamer.private.ref[j][self] = nil
        if streamer.private.allocator.validStreams[(self.streamType)] and streamer.private.allocator.validStreams[(self.streamType)].desyncOccclusionsOnPause then
            imports.setElementDimension(j, settings.streamer.unsyncDimension)
        end
    end
    return true
end

function streamer.public:update(clientDimension, clientInterior)
    if not clientDimension and not clientInterior then return false end
    local currentDimension, currentInterior = imports.getElementDimension(localPlayer), imports.getElementInterior(localPlayer)
    clientDimension, clientInterior = clientDimension or _clientDimension, clientInterior or clientInterior
    if streamer.public.waterBuffer then
        imports.setElementDimension(streamer.public.waterBuffer, currentDimension)
        imports.setElementInterior(streamer.public.waterBuffer, currentInterior)
    end
    if streamer.private.buffer[clientDimension] and streamer.private.buffer[clientDimension][clientInterior] then
        for i, j in imports.pairs(streamer.private.buffer[clientDimension][clientInterior]) do
            if j then
                i.isStreamed = nil
                imports.setElementDimension(i.streamer, settings.streamer.unsyncDimension)
            end
        end
    end
    streamer.private.cache.isCameraTranslated = true
    streamer.private.cache.clientWorld = streamer.private.cache.clientWorld or {}
    streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior = currentDimension, currentInterior
    return true
end

function streamer.public:allocate()
    if not streamer.public:isInstance(self) or not self.isResumed or self.isAllocated then return false end
    if not streamer.private.allocator.validStreams[(self.streamType)] then return false end
    self.isAllocated = true
    streamer.private.allocator[(self.syncRate)] = streamer.private.allocator[(self.syncRate)] or {}
    streamer.private.allocator[(self.syncRate)][(self.streamType)] = streamer.private.allocator[(self.syncRate)][(self.streamType)] or {}
    streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] = streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or {}
    streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] = streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] or {}
    local streamBuffer = streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)]
    if self.streamType == "bone" then
        if self.syncRate <= 0 then
            if not streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer then
                streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = true
                imports.addEventHandler("onClientPedsProcessed", root, streamer.private.onBoneUpdate)
            end
        else
            if not streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer or not timer:isInstance(streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer) then
                streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = timer:create(streamer.private.onBoneUpdate, self.syncRate, 0, self.syncRate, self.streamType)
            end
        end
        streamBuffer[self] = streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self]
    end
    return true
end

function streamer.public:deallocate()
    if not streamer.public:isInstance(self) or not self.isResumed or not self.isAllocated then return false end
    if not streamer.private.allocator.validStreams[(self.streamType)] then return false end
    if not streamer.private.allocator[(self.syncRate)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] then return false end
    local isAllocatorVoid = true
    self.isAllocated = false
    streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)][self] = nil
    for i, j in imports.pairs(streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)]) do
        isAllocatorVoid = false
        break
    end
    if isAllocatorVoid then
        if self.streamType == "bone" then
            if streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer then
                if self.syncRate <= 0 then
                    imports.removeEventHandler("onClientPedsProcessed", root, streamer.private.onBoneUpdate)
                else
                    streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer:destroy()
                end
            end
            streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = nil
        end
    end
    return true
end

streamer.private.onEntityStream = function(streamBuffer)
    if not streamBuffer then return false end
    for i, j in imports.pairs(streamBuffer) do
        if j then
            local isStreamed = false
            for k = 1, #i.occlusions, 1 do
                local v = i.occlusions[k]
                if imports.isElementOnScreen(v) then
                    isStreamed = true
                    break
                end
            end
            local isStreamAltered = isStreamed ~= i.isStreamed
            if isStreamAltered then imports.setElementDimension(i.streamer, (isStreamed and streamer.private.cache.clientWorld.dimension) or settings.streamer.unsyncDimension) end
            if streamer.private.allocator.validStreams[(i.streamType)] and streamer.private.allocator.validStreams[(i.streamType)].dynamicStreamAllocation then
                if not isStreamed then
                    if isStreamAltered then
                        i:deallocate()
                    end
                else
                    local viewDistance = math.findDistance3D(streamer.private.cache.cameraLocation.x, streamer.private.cache.cameraLocation.y, streamer.private.cache.cameraLocation.z, imports.getElementPosition(i.streamer)) - settings.streamer.streamDelimiter[1]
                    local syncRate = ((viewDistance <= 0) and 0) or math.min(settings.streamer.streamRate, math.round(((viewDistance/settings.streamer.streamDelimiter[2])*settings.streamer.streamRate)/settings.streamer.streamDelimiter[3])*settings.streamer.streamDelimiter[3])
                    if syncRate ~= i.syncRate then
                        i:deallocate()
                        i.syncRate = syncRate
                        i:allocate()
                    end
                end
            end
            i.isStreamed = isStreamed
        end
        if settings.streamer.syncCoolDownRate then streamer.private.cache.clientThread:sleep(settings.streamer.syncCoolDownRate) end
    end
    return true
end

streamer.private.onBoneStream = function(streamBuffer)
    if not streamBuffer then return false end
    attacher.bone.cache.streamTick = imports.getTickCount()
    for i, j in imports.pairs(streamBuffer) do
        if j and i.isStreamed then
            attacher.bone.update(attacher.bone.buffer.element[(i.streamer)])
        end
    end
    return true
end

streamer.private.onBoneUpdate = function(syncRate, streamType)
    local streamBuffer = (syncRate and streamType and streamer.private.allocator[syncRate][streamType]) or false
    streamBuffer = streamBuffer or (streamer.private.allocator[0] and streamer.private.allocator[0]["bone"]) or false
    local clientDimension, clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
    if streamBuffer and streamBuffer[clientDimension] and streamBuffer[clientDimension][clientInterior] then
        streamer.private.onBoneStream(streamBuffer[clientDimension][clientInterior])
    end
    return true
end

network:fetch("Assetify:onLoad"):on(function()
    streamer.public:update(imports.getElementDimension(localPlayer))
    thread:createHeartbeat(function()
        if not streamer.private.cache.isCameraTranslated then
            local velX, velY, velZ = imports.getElementVelocity(streamer.private.cache.clientCamera)
            streamer.private.cache.isCameraTranslated = ((velX ~= 0) and true) or ((velY ~= 0) and true) or ((velZ ~= 0) and true) or false
        end
        return true
    end, function() end, settings.streamer.cameraRate)

    streamer.private.cache.clientThread = thread:createHeartbeat(function()
        if streamer.private.cache.isCameraTranslated then
            streamer.private.cache.cameraLocation = streamer.private.cache.cameraLocation or {}
            streamer.private.cache.cameraLocation.x, streamer.private.cache.cameraLocation.y, streamer.private.cache.cameraLocation.z = imports.getElementPosition(streamer.private.cache.clientCamera)
            local clientDimension, clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
            if streamer.private.buffer[clientDimension] and streamer.private.buffer[clientDimension][clientInterior] then
                for i, j in imports.pairs(streamer.private.buffer[clientDimension][clientInterior]) do
                    streamer.private.onEntityStream(j)
                end
            end
            if streamer.private.buffer[-1] and streamer.private.buffer[-1][clientInterior] then
                for i, j in imports.pairs(streamer.private.buffer[-1][clientInterior]) do
                    streamer.private.onEntityStream(j)
                end
            end
            streamer.private.cache.isCameraTranslated = false
        end
        return true
    end, function() end, settings.streamer.syncRate)
end)


---------------------
--[[ API Syncers ]]--
---------------------

imports.addEventHandler("onClientElementDimensionChange", localPlayer, function(dimension) streamer.public:update(dimension) end)
imports.addEventHandler("onClientElementInteriorChange", localPlayer, function(interior) streamer.public:update(_, interior) end)
imports.addEventHandler("onClientElementInteriorChange", localPlayer, function(interior) streamer.public:update(_, interior) end)
imports.addDebugHook("postFunction", function(_, _, _, _, _, element)
    streamer.private.updateAttachments(element)
end, {"setElementMatrix", "setElementPosition", "setElementRotation"})
network:fetch("Assetify:onElementDestroy"):on(function(source)
    if not syncer.isLibraryBooted or not source then return false end
    streamer.public:detachElements(source)
end)