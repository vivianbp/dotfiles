--!nonstrict
-- Bar status glyph.
--   sun-off          dimming disabled
--   sun              enabled, Claude idle
--   brightness-down  Claude busy, monitor dimmed (primary color)
--   click            enable / disable dimming
--   right-click      restore brightness now

local enabled = noctalia.state.get("enabled") ~= false
local dimmed = noctalia.state.get("dimmed") == true
local busy = noctalia.state.get("busy") or 0

local function statusText()
  if not enabled then
    return noctalia.tr("status.disabled")
  elseif dimmed then
    return noctalia.tr("status.dimmed")
  end
  return noctalia.tr("status.idle")
end

local function render()
  local glyph = "sun"
  local color = nil
  if not enabled then
    glyph = "sun-off"
  elseif dimmed then
    glyph = "brightness-down"
    color = "primary"
  end

  barWidget.render(ui.row({ align = "center" }, {
    ui.glyph({ name = glyph, color = color }),
  }))
  barWidget.setTooltip({
    { key = noctalia.tr("title"), value = statusText() },
    { key = noctalia.tr("tooltip.sessions"), value = tostring(busy) },
    { key = noctalia.tr("tooltip.hint"), value = noctalia.tr("tooltip.hint_value") },
  })
end

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

noctalia.state.watch("busy", function(value)
  busy = value or 0
  render()
end)

-- Static between state changes; update() only needs to run for the first render.
function update()
  noctalia.setUpdateInterval(60000)
  render()
end

function onClick()
  send("toggle")
end

function onRightClick()
  send("restore")
end
