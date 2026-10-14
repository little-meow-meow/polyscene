
---@enum PolyObjectClass
local ObjectClasses = {
    "AchievementsService",
    "Camera",
    "CaptureService",
    "CoreUIService",
    "Environment",
    "Folder",
    "GradientSky",
    "Hidden",
    "Inventory",
    "Lighting",
    "Model",
    "Part",
    "PlayerDefaults",
    "PlayerGUI",
    "Players",
    "PointLight",
    "ScriptService",
    "ServerHidden",
    "ServerScript",
    "SpotLight",
    "Stats",
    "SunLight",
    "Teams",
    "World",
    -- ... incomplete list
}

---@class PolyObject
---@field Name string
---@field ClassName PolyObjectClass
---@field ID string
---@field Properties table
---@field Children [PolyObject]
---@field IsLinkedChild boolean
