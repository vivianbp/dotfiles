# Claude Dim

Dims a monitor while Claude Code is working and restores it when Claude
finishes or needs input. Claude Code hooks report `busy` / `idle` to this
plugin's service over IPC; the plugin decides whether to dim, so the feature
can be switched on and off from the control center or the bar without touching
the hooks.

## Plugin

| Field | Value |
| --- | --- |
| ID | `vboysepe/claude-dim` |
| Entries | service: `service`; shortcut: `toggle`; bar widget: `bar` |

## Install

Declaratively, with the NixOS module in `../module.nix`:

```nix
imports = [ ./noctaliaplugin/module.nix ];
programs.claude-dim.enable = true;
```

This links `~/.config/noctalia/zz-claude-dim.toml`, which registers this folder as
a `path` source, enables the plugin and adds the control-center tile. It also
installs the Claude Code hooks below as `/etc/claude-code/managed-settings.json`.
Setting `enable = false` (with the module still imported) removes both.

Because noctalia's lists replace rather than merge, the drop-in owns the full
`plugins.enabled`, `plugins.source` and `control_center.shortcuts` lists; use
the module options to add to them. Changes made in the Settings GUI are saved
to `~/.local/state/noctalia/settings.toml`, which overrides the drop-in.

Manually:

```sh
noctalia msg plugins source add local path ~/.config/nixos/noctaliaplugin
noctalia msg plugins enable vboysepe/claude-dim
```

Then add the **Claude Dim** tile from Settings → Control Center shortcuts,
and/or the `bar` widget from the bar's Add-widget picker.

## Usage

- **Control-center tile**: click toggles dimming on/off (remembered across
  restarts); right-click restores brightness immediately.
- **Bar widget**: `sun-off` = off, `sun` = on and idle, `brightness-down`
  (highlighted) = Claude working and monitor dimmed. Click toggles, right-click
  restores. The tooltip shows how many sessions are busy.

Multiple Claude Code sessions are tracked by session id: the monitor stays dim
while any of them is busy.

## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `monitor` | `string` | `DP-5` | Connector passed to `noctalia msg brightness-set`; empty = focused monitor. |
| `dim_level` | `int` | `15` | Brightness while Claude is working. |
| `restore_level` | `int` | `100` | Brightness restored afterwards (noctalia can't read the current value). |
| `timeout_minutes` | `int` | `30` | Forget a session with no `busy` event for this long. 0 = never. |

## IPC

```sh
noctalia msg plugin vboysepe/claude-dim:service all <event> [session_id]
```

| Event | Effect |
| --- | --- |
| `busy [id]` | Mark a session busy (also refreshes its timeout). |
| `idle [id]` | Mark a session idle. |
| `toggle` / `enable` / `disable` | Switch the feature. |
| `restore` | Forget all busy sessions and restore brightness now. |
| `test` | Dim for 3 seconds, then restore (works even when disabled). |

## Claude Code hooks

In `~/.claude/settings.json`. `jq` must run before the `&`: a backgrounded
command's stdin is `/dev/null`, so it would never see the hook's JSON.

```json
"hooks": {
  "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all busy \"$sid\" >/dev/null 2>&1 &" }] }],
  "PostToolUse":      [{ "hooks": [{ "type": "command", "command": "sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all busy \"$sid\" >/dev/null 2>&1 &" }] }],
  "Stop":             [{ "hooks": [{ "type": "command", "command": "sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all idle \"$sid\" >/dev/null 2>&1 &" }] }],
  "Notification":     [{ "hooks": [{ "type": "command", "command": "sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all idle \"$sid\" >/dev/null 2>&1 &" }] }],
  "SessionEnd":       [{ "hooks": [{ "type": "command", "command": "sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all idle \"$sid\" >/dev/null 2>&1 &" }] }],
  "PreToolUse": [{ "matcher": "AskUserQuestion",
                   "hooks": [{ "type": "command", "command": "sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all idle \"$sid\" >/dev/null 2>&1 &" }] }]
}
```

`PostToolUse` is a heartbeat: it keeps long turns from hitting the timeout and
re-dims after you answer a permission prompt or question.

## Known limitations

- Restore is a fixed level, not the brightness you had before dimming.
- `monitor` is a connector name; behind a dock it can change (e.g. `DP-5` →
  `DP-6`) after a replug. If dimming stops working, check `niri msg outputs`
  and update the setting.
- Interrupting a turn (Esc / Ctrl+C) fires no hook, so the monitor stays dim
  until the next prompt's `Stop`, the timeout, or a right-click restore.
- If noctalia restarts while dimmed, `onExit` restores brightness on a
  best-effort basis.
