--!nonstrict
-- Claude Dim service - the headless [[service]] entry.
--
-- Owns all state: the persisted enabled flag, the set of busy Claude Code
-- sessions, and whether the monitor is currently dimmed. The monitor is dimmed
-- while enabled and at least one session is busy, and restored otherwise.
--
-- Published to noctalia.state for the shortcut and bar entries:
--   enabled (bool), dimmed (bool), busy (number of busy sessions)
-- Commands from those entries arrive on the "cmd" state key as "<cmd>:<nonce>".
--
-- IPC: noctalia msg plugin vboysepe/claude-dim:service all <event> [payload]
--   busy [session]   a Claude session started working (or is still working)
--   idle [session]   a session stopped / needs input
--   toggle | enable | disable
--   restore          forget all busy sessions and restore brightness now
--   test             dim for a few seconds, then restore

local TEST_MS = 3000

noctalia.setUpdateInterval(1000)

---- Persisted enabled flag (noctalia.state is in-memory only)
local dataDir = noctalia.pluginDataDir()
local enabledPath = if dataDir then `{dataDir}/enabled` else nil

local function loadEnabled()
  if not enabledPath then
    return true
  end
  local contents = noctalia.readFile(enabledPath)
  if contents == nil then
    return true
  end
  return noctalia.string.trim(contents) ~= "0"
end

local function saveEnabled(value)
  if not enabledPath then
    return
  end
  local ok, err = noctalia.writeFile(enabledPath, if value then "1" else "0")
  if not ok then
    noctalia.log(`claude-dim: cannot save enabled flag: {err}`)
  end
end

---- Config
local cfg = {}

local function readConfig()
  cfg.monitor = noctalia.string.trim(noctalia.getConfig("monitor") or "")
  cfg.dim = noctalia.getConfig("dim_level") or 15
  cfg.restore = noctalia.getConfig("restore_level") or 100
  cfg.timeoutMs = (noctalia.getConfig("timeout_minutes") or 30) * 60000
end

readConfig()

---- State
local enabled = loadEnabled()
local dimmed = false
local sessions = {} -- session id -> last busy event (ms)
local testUntil = nil

local function sessionCount()
  local n = 0
  for _ in sessions do
    n += 1
  end
  return n
end

local function publish()
  noctalia.state.set("enabled", enabled)
  noctalia.state.set("dimmed", dimmed)
  noctalia.state.set("busy", sessionCount())
end

local function setBrightness(level)
  local argv = { "noctalia", "msg", "brightness-set" }
  if cfg.monitor ~= "" then
    table.insert(argv, cfg.monitor)
  end
  table.insert(argv, tostring(level))
  noctalia.runAsync(argv, function(res)
    if res.exitCode ~= 0 then
      noctalia.log(`claude-dim: brightness-set failed ({res.exitCode}): {res.stderr}`)
    end
  end, 10000)
end

-- Bring the monitor in line with the desired state.
local function reconcile()
  local want = testUntil ~= nil or (enabled and sessionCount() > 0)
  if want and not dimmed then
    setBrightness(cfg.dim)
    dimmed = true
  elseif not want and dimmed then
    setBrightness(cfg.restore)
    dimmed = false
  end
  publish()
end

local function setEnabled(value)
  enabled = value
  saveEnabled(value)
  reconcile()
end

local function restoreNow()
  table.clear(sessions)
  testUntil = nil
  reconcile()
end

local actions = {
  toggle = function()
    setEnabled(not enabled)
  end,
  enable = function()
    setEnabled(true)
  end,
  disable = function()
    setEnabled(false)
  end,
  restore = restoreNow,
  test = function()
    testUntil = noctalia.nowMs() + TEST_MS
    reconcile()
  end,
}

local function sessionId(payload)
  if payload == nil or payload == "" or payload == "null" then
    return "default"
  end
  return payload
end

function onIpc(event, payload)
  if event == "busy" then
    sessions[sessionId(payload)] = noctalia.nowMs()
    reconcile()
  elseif event == "idle" then
    sessions[sessionId(payload)] = nil
    reconcile()
  elseif actions[event] then
    actions[event]()
  else
    noctalia.log(`claude-dim: unknown IPC event '{event}'`)
  end
end

noctalia.state.watch("cmd", function(value)
  if type(value) ~= "string" then
    return
  end
  local cmd = string.match(value, "^([^:]+)")
  local action = cmd and actions[cmd]
  if action then
    action()
  end
end)

-- Expire stale sessions (interrupted turns never send idle) and end tests.
function update()
  local now = noctalia.nowMs()
  local changed = false
  if testUntil and now >= testUntil then
    testUntil = nil
    changed = true
  end
  if cfg.timeoutMs > 0 then
    for id, seen in sessions do
      if now - seen > cfg.timeoutMs then
        sessions[id] = nil
        changed = true
      end
    end
  end
  if changed then
    reconcile()
  end
end

function onConfigChanged()
  local wasDimmed = dimmed
  readConfig()
  -- Re-apply the new dim level (or monitor) if we are currently dimmed.
  if wasDimmed then
    setBrightness(cfg.dim)
  end
end

-- Never leave the monitor dim when the plugin goes away.
function onExit(signal, reason)
  if dimmed then
    setBrightness(cfg.restore)
    dimmed = false
  end
end

publish()
