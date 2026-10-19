--!nonstrict
-- Control-center quick-toggle tile.
--   click        enable / disable dimming
--   right-click  restore brightness now (forgets busy sessions)

local enabled = noctalia.state.get("enabled") ~= false
local dimmed = noctalia.state.get("dimmed") == true

local function render()
  if dimmed then
    shortcut.setLabel(noctalia.tr("shortcut.dimmed"))
  else
    shortcut.setLabel(noctalia.tr("shortcut.label"))
  end
  shortcut.setIcon(if dimmed then "brightness-down" else "sun", "sun-off")
  shortcut.setActive(enabled)
  shortcut.setEnabled(true)
end

-- The service owns state; commands carry a nonce so repeats still fire watchers.
local function send(cmd)
  noctalia.state.set("cmd", `{cmd}:{noctalia.nowMs()}`)
end

noctalia.state.watch("enabled", function(value)
  enabled = value ~= false
  render()
end)

noctalia.state.watch("dimmed", function(value)
  dimmed = value == true
  render()
end)

render()

function onClick()
  send("toggle")
end

function onRightClick()
  send("restore")
end
