local EVENT_REFERENCE = "AlluneveLoggerTestSequence"
local DEPENDENCY_REFERENCE = "AlluneveLoggerTestDependency"
local ADDON_IDENTIFIER = "AlluneveLoggerTest"

-- No-op fallback --

local function NoOp() end

---@type AlluneveLoggerAPI
local NOOP_LOGGER_API = {
    Info = NoOp,
    Debug = NoOp,
    Warn = NoOp,
    Error = NoOp,
    SubmitLog = NoOp,
    TriggerRecorder = NoOp
}

---@type AlluneveLoggerAPI
local loggerAPI = NOOP_LOGGER_API

-- State --

local boundDependency
local disabledDependency
local firstTick
local step = 1
local running = false

-- Test sequence --

local steps = {
    {
        tick = 100,
        run = function()
            loggerAPI.Info("Delayed INFO test")
            loggerAPI.Debug("Delayed DEBUG test")
            loggerAPI.Warn("Delayed WARN test")
            print("[be.alluneve.runescape.logger Test] Three messages logged")
        end
    },
    {
        tick = 200,
        run = function()
            loggerAPI.SubmitLog()
            print("[be.alluneve.runescape.logger Test] Requested settings-filtered report")
        end
    },
    {
        tick = 300,
        run = function()
            loggerAPI.Error("Triggered flight recorder test")
            print("[be.alluneve.runescape.logger Test] Triggered flight recorder")
        end
    },
    {
        tick = 350,
        run = function()
            loggerAPI.Info("Post-trigger entry")
        end
    },
    {
        tick = 850,
        run = function()
            print("[be.alluneve.runescape.logger Test] Flight recorder deadline should have passed")
        end
    },
    {
        tick = 900,
        run = function()
            loggerAPI.SubmitLog()
            print("[be.alluneve.runescape.logger Test] Requested final report")
        end
    },
    {
        tick = 950, -- ~19 seconds
        run = function()
            local lines = {}

            for i = 1, 200 do
                lines[#lines + 1] = string.format(
                    "Large report test - Line %03d | %s",
                    i,
                    string.rep("0123456789 ", 7)
                )
            end

            loggerAPI.Warn(table.concat(lines, "\n"))
            loggerAPI.SubmitLog()

            print("[be.alluneve.runescape.logger Test] Requested large multiline report (200 lines)")
        end
    }
}

-- Dependency management --

local function StopTest()
    running = false
    firstTick = nil
    step = 1
end

local function UnbindLogger()
    StopTest()
    loggerAPI = NOOP_LOGGER_API
    boundDependency = nil
end

local function TryRegister()
    local dependency = AlluneveLogger

    if type(dependency) ~= "table"
        or type(dependency.RegisterYourself) ~= "function"
        or dependency == disabledDependency then
        if boundDependency then
            UnbindLogger()
            print("[be.alluneve.runescape.logger Test] Dependency unavailable; using no-op API")
        end

        return
    end

    -- Already registered against this dependency instance.
    if dependency == boundDependency then
        return
    end

    local success, result = pcall(
        dependency.RegisterYourself,
        ADDON_IDENTIFIER
    )

    if not success then
        print("[be.alluneve.runescape.logger Test] Registration failed:", result)
        return
    end

    if type(result) ~= "table" then
        print("[be.alluneve.runescape.logger Test] Registration returned no API")
        return
    end

    loggerAPI = result
    boundDependency = dependency

    firstTick = nil
    step = 1
    running = true

    print("[be.alluneve.runescape.logger Test] Registered; test sequence scheduled")
end

-- Logic scheduler --

local function OnLogic(event)
    -- Also detects availability if a dependency event is missed.
    TryRegister()

    if not running then
        return
    end

    firstTick = firstTick or event.logicTick
    local elapsed = event.logicTick - firstTick

    while running and steps[step] and elapsed >= steps[step].tick do
        steps[step].run()
        step = step + 1
    end

    if running and not steps[step] then
        running = false
        print("[be.alluneve.runescape.logger Test] Sequence complete")
    end
end

-- Optional dependency events --

local function OnDependencyChanged(event)
    print(
        "[be.alluneve.runescape.logger Test] Dependency event:",
        event.pluginIdentifier,
        event.enabled
    )

    if event.pluginIdentifier ~= "AlluneveLogger"
        and event.pluginIdentifier ~= "be.alluneve.runescape.logger" then
        return
    end

    if event.enabled then
        disabledDependency = nil
        -- Retry registration on the next logic tick.
    else
        disabledDependency = AlluneveLogger
        UnbindLogger()
        print("[be.alluneve.runescape.logger Test] Switched to no-op API")
    end
end

-- Lifecycle --

Event.OptionalDependencyChanged.Subscribe(
    DEPENDENCY_REFERENCE,
    OnDependencyChanged
)

Event.Logic.Subscribe(EVENT_REFERENCE, OnLogic)

function PluginShutdown()
    Event.Logic.Unsubscribe(EVENT_REFERENCE)
    Event.OptionalDependencyChanged.Unsubscribe(DEPENDENCY_REFERENCE)
    UnbindLogger()
end

-- Initial registration attempt.
TryRegister()

if not boundDependency then
    print("[be.alluneve.runescape.logger Test] Waiting for be.alluneve.runescape.logger")
end