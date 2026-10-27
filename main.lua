local database = require("lib/backend/db/Database")

-- Load persisted reports and settings before importing the backend.
database.Load()

local RollingLog = require("lib/backend/db/RollingLog")
local Debug = require("lib/backend/Debug")
local FlightRecorder = require("lib/backend/FlightRecorder")
local Settings = require("lib/ui/Settings")
local Content = require("lib/ui/Content")


local Severity = RollingLog.Severity
local RegisteredAddons = {}
Content.SetRegisteredAddons(RegisteredAddons)
local API = {}

---@class AlluneveLoggerAPI
---@field Info fun(...: any)
---@field Debug fun(...: any)
---@field Warn fun(...: any)
---@field Error fun(...: any)
---@field SubmitLog fun()
---@field TriggerRecorder fun()

---@param addonIdentifier string
---@return AlluneveLoggerAPI
function API.RegisterYourself(addonIdentifier)
    assert(
        type(addonIdentifier) == "string" and addonIdentifier ~= "",
        "be.alluneve.runescape.logger: Invalid addon identifier"
    )

    if RegisteredAddons[addonIdentifier] then
        return RegisteredAddons[addonIdentifier]
    end

    ---@type AlluneveLoggerAPI
    local addonAPI = {
        Info = function(...)
            Debug.Log(addonIdentifier, Severity.INFO, ...)
        end,
        Debug = function(...)
            Debug.Log(addonIdentifier, Severity.DEBUG, ...)
        end,
        Warn = function(...)
            Debug.Log(addonIdentifier, Severity.WARN, ...)
        end,
        Error = function(...)
            Debug.Log(addonIdentifier, Severity.ERROR, ...)
            FlightRecorder.Trigger(addonIdentifier)
        end,
        SubmitLog = function()
            Debug.SubmitLog(addonIdentifier)
        end,
        TriggerRecorder = function()
            FlightRecorder.Trigger(addonIdentifier)
        end
    }

    RegisteredAddons[addonIdentifier] = addonAPI
    return addonAPI
end

-- The client calls this global on plugin disable/reload/shutdown.
function PluginShutdown()
    Settings.Shutdown()
    FlightRecorder.Shutdown()
    Content.Shutdown()
    if not database.Save() then
        print("be.alluneve.runescape.logger: Failed to save database.")
    end
end

print("be.alluneve.runescape.logger: Loaded.")

return API