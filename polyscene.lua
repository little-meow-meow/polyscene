require("common")
local argparse = require("argparse")
local PolyWorld = require("polyworld")

local parser = argparse("polyscene", "transclude the contents of .poly files into other .poly files")
parser:argument("command", "What to do with the scene"):choices({"add", "remove"})
parser:argument("destination", "The .poly file to add the scene into")
parser:argument("source", "The .poly file to add into the target .poly")
parser:option("-y --yes", "Skip prompting the user for confirmation", false):args("?")
parser:option("-x", "Object path relocation, e.g. -x \"World.Environment=World.ServerHidden\" to redirect objects in Environment to ServerHidden"):count("*")
parser:flag("-m --makefolders", "Generate folder objects for non-existent parent paths")

local args = parser:parse()

if not args.yes then
    printf("Write scene %s into destination %s ...? [y/N]", args.source, args.destination)
    if io.read() ~= "y" then
        return
    end
end

----------

local source = PolyWorld.new(args.source)
local destination = PolyWorld.new(args.destination)

local SKIP_CLASSES = {
    ["AchievementsService"] = true,
    ["Camera"] = true,
    ["CaptureService"] = true,
    ["CoreUIService"] = true,
    ["Environment"] = true,
    -- ["GradientSky"] = true,
    ["Hidden"] = true,
    ["Inventory"] = true,
    ["Lighting"] = true,
    -- ["Model"] = true,
    -- ["Part"] = true,
    ["PlayerDefaults"] = true,
    ["PlayerGUI"] = true,
    ["Players"] = true,
    -- ["PointLight"] = true,
    ["ScriptService"] = true,
    ["ServerHidden"] = true,
    -- ["ServerScript"] = true,
    -- ["SpotLight"] = true,
    ["Stats"] = true,
    -- ["SunLight"] = true,
    ["Teams"] = true,
    ["World"] = true,
}

---@type {string: string}
local RelocationMap = {}
for _, relocation in ipairs(args.x) do
    local _, _, from, to = string.find(relocation, "([%w%.]+)=([%w%.]+)")
    RelocationMap[from] = to
end

---@param sourceObject PolyObject
local function addObject(sourceObject)
    if destination:getObjectsMap()[sourceObject.ID] then
        return false
    end

    if SKIP_CLASSES[sourceObject.ClassName] then
        return false
    end

    local sourceObjectPath = source:getObjectPath(sourceObject)
    for from, to in pairs(RelocationMap) do
        if sourceObjectPath:startswith(from) then
            sourceObjectPath = sourceObjectPath:replace(from, to)
            break
        end
    end

    if destination:getObject(sourceObjectPath) ~= nil then
        printf("[WARN] Conflicting object path %s", sourceObjectPath)
        return false
    end

    local sourceParentPath = string.drop(sourceObjectPath, ".")

    if args.makefolders then
        destination:makeFolders(sourceParentPath)
    end

    destination:addChild(sourceParentPath, sourceObject)

    return true
end

local function removeObject(sourceObject)
    if not destination:getObjectsMap()[sourceObject.ID] then
        return false
    end

    if SKIP_CLASSES[sourceObject.ClassName] then
        return false
    end

    destination:removeChild(sourceObject.ID)

    return true
end

local Commands = {
    ["add"] = addObject,
    ["remove"] = removeObject,
}

-----------

local operant = Commands[args.command]

local tally = 0

-- We need to do a breadth first search here, otherwise parents will not exist to hold children.

---@type [PolyObject]
---@diagnostic disable-next-line: invisible
local queue = { source.raw.Objects[1] }
while #queue > 0 do
    ---@type PolyObject
    local sourceObject = table.remove(queue, 1)

    if operant(sourceObject) then
        tally = tally + 1
    end

    for _, child in pairs(sourceObject.Children) do
        table.insert(queue, child)
    end
end

printf("Operated on %d objects", tally)

printf("Saving to file %s", args.destination)
destination:saveToDisk(args.destination)
