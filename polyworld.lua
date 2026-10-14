require("common")
require("polyobject")
local json = require("json")
local zstd = require("zstd")

---Deserializes a compressed .poly world file
---@param path any
---@return table, boolean
local function ParsePolyFile(path)
    local f = io.open(path, "rb")

    if not f then
        errorf("Failed to parse file %s", path)
    end
    ---@cast f file*

    local data = f:read("*a")
    local wasCompressed = false
    if data:sub(1, 1) ~= "{" then
        data = zstd.decompress(data, #data)
        wasCompressed = true
    end

    local result = json.decode(data)
    f:close()
    return result, wasCompressed
end

---@class PolyObjectWrapper
---@field object PolyObject
---@field path string

---@class PolyWorld
---@field private raw table
---@field private wasCompressed boolean
---@field private guidObjectMap {string: PolyObject}
---@field private pathObjectMap {string: PolyObject}
---@field private objectPathMap {PolyObject: string}
local PolyWorld = {}
PolyWorld.__index = PolyWorld

---Deserializes a .poly world file from a file path
---@param filePath string path to file on disk
---@return PolyWorld
function PolyWorld.new(filePath)
    local raw, wasCompressed = ParsePolyFile(filePath)
    ---@type PolyWorld
    local world = {
        raw = raw,
        wasCompressed = wasCompressed,
        guidObjectMap = {},
        pathObjectMap = {},
        objectPathMap = {},
    }

    ---@type [PolyObjectWrapper]
    local queue = {
        {
            object = world.raw.Objects[1],
            path = "",  -- root
        }
    }
    while #queue > 0 do
        ---@type PolyObjectWrapper
        local wrapper = table.remove(queue, 1)
        local object = wrapper.object

        local objectPath = string.format("%s.%s", wrapper.path, object.Name)
        if wrapper.path == "" then
            objectPath = objectPath:sub(2)
        end

        world.guidObjectMap[object.ID] = object
        world.pathObjectMap[objectPath] = object
        world.objectPathMap[object] = objectPath

        for _, child in pairs(object.Children) do
            table.insert(queue, {
                object = child,
                path = objectPath
            })
        end
    end

    return setmetatable(world, PolyWorld)
end

---@param filePath string File path on disk for where to write the world
function PolyWorld:saveToDisk(filePath)
    local data = json.encode(self.raw)

    if self.wasCompressed then
        data = zstd.compress(data)
    end

    local f = io.open(filePath, "wb")
    if not f then
        errorf("Couldn't write world file to disk: failed to open file handle %s", filePath)
    end
    ---@cast f file*

    f:write(data)
    f:close()
end

---@param objectPath string Object hierarchy path, e.g. `World.Environment.BasePlate`
function PolyWorld:getObject(objectPath)
    return self.pathObjectMap[objectPath]
end

---Returns all objects as a key-value map of ID -> PolyObject
---@return { string: PolyObject }
function PolyWorld:getObjectsMap()
    return self.guidObjectMap
end

---@param object PolyObject
function PolyWorld:getObjectPath(object)
    return self.objectPathMap[object]
end

---Add the given object as a child of the object at a given object path
---@param parentObjectPath string Object hierarchy path, e.g. `World.Environment.BasePlate` to parent to the BasePlate
---@param object PolyObject Object to add
function PolyWorld:addChild(parentObjectPath, object)
    local parent = self:getObject(parentObjectPath)
    if not parent then
        errorf("Failed to find parent object: %s", parentObjectPath)
    end

    table.insert(parent.Children, object)

    local objectPath = string.format("%s.%s", parentObjectPath, object.Name)
    self.guidObjectMap[object.ID] = object
    self.pathObjectMap[objectPath] = object
    self.objectPathMap[object] = objectPath
end

---Remove the given object from the world
---@param objectId string
function PolyWorld:removeChild(objectId)
    local object = self.guidObjectMap[objectId]
    if not object then
        errorf("Failed to find object: %s", objectId)
    end

    local objectPath = self.objectPathMap[object]
    local parentObjectPath = string.drop(objectPath, ".")
    local parent = self:getObject(parentObjectPath)
    if not parent then
        --errorf("Failed to find object's parent: %s", parentObjectPath)
        return
    end

    local foundChild = false
    for i, child in pairs(parent.Children) do
        if child.ID == objectId then
            table.remove(parent.Children, i)
            foundChild = true
            break
        end
    end

    if not foundChild then
        errorf("Parent object %s did not contain child object %s", parentObjectPath, objectPath)
    end

    self.guidObjectMap[objectId] = nil
    self.pathObjectMap[objectPath] = nil
    self.objectPathMap[object] = nil
end

---Create a folder object at the given object path.
---@param objectPath string
---@param existOk boolean? if false, throws an error if the object path is already occupied
function PolyWorld:makeFolder(objectPath, existOk)
    if self:getObject(objectPath) then
        if existOk then
            return
        end
        errorf("Cannot make folder: object path %s is occupied", objectPath)
    end

    local parentObjectPath = string.drop(objectPath, ".")

    ---@type PolyObject
    local folder = {
        Children = {},
---@diagnostic disable-next-line: assign-type-mismatch
        ClassName = "Folder",
        ID = uuid(),
        IsLinkedChild = false,
        Name = string.pickup(objectPath, "."),
        Properties = {
            Tags = {},
        },
    }

    self:addChild(parentObjectPath, folder)
end

---Given an object path, create folder objects for non-existent objects in the path.
---@param objectPath string
function PolyWorld:makeFolders(objectPath)
    local searchStartIndex = 1
    while searchStartIndex < #objectPath do
        local matchStart, matchEnd, _ = string.find(objectPath, ".", searchStartIndex, true)
        if not matchStart or not matchEnd then
            break
        end

        local subRootPath = string.sub(objectPath, 1, matchEnd - 1)
        self:makeFolder(subRootPath, true)

        searchStartIndex = matchEnd + 1
    end

    self:makeFolder(objectPath, true)
end

return PolyWorld
