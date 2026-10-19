# Claude Dim feature: dims a monitor while Claude Code is working.
#
#   imports = [ ./noctaliaplugin/module.nix ];
#   programs.claude-dim.enable = true;
#
# Enabled, it:
#   - links a noctalia drop-in config into ~/.config/noctalia/ that registers the
#     local plugin source, enables vboysepe/claude-dim and adds its control-center tile
#   - installs the Claude Code hooks as managed settings (/etc/claude-code/managed-settings.json)
# Disabled (module still imported), the drop-in is removed and the hooks disappear
# with /etc, so nothing is left behind.
#
# noctalia merges every *.toml in ~/.config/noctalia/ alphabetically and lists
# REPLACE rather than append, so the drop-in carries the full plugin, source and
# shortcut lists (hence the options below). GUI changes land in
# ~/.local/state/noctalia/settings.toml, which overrides this file.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.claude-dim;
  home = config.users.users.${cfg.user}.home;
  target = "${home}/.config/noctalia/zz-claude-dim.toml";

  noctaliaConfig = (pkgs.formats.toml { }).generate "zz-claude-dim.toml" {
    plugins = {
      enabled = [ "vboysepe/claude-dim" ] ++ cfg.extraPlugins;
      source = [
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          enabled = true;
        }
        {
          name = "community";
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          enabled = true;
        }
        {
          name = "local";
          kind = "path";
          location = cfg.pluginSource;
          enabled = true;
        }
      ];
    };
    control_center.shortcuts = map (type: { inherit type; }) cfg.controlCenterShortcuts;
  };

  # jq must run before the `&`: a backgrounded command's stdin is /dev/null.
  hook = event: {
    type = "command";
    command = ''sid=$(jq -r .session_id); noctalia msg plugin vboysepe/claude-dim:service all ${event} "$sid" >/dev/null 2>&1 &'';
  };
  on = event: [ { hooks = [ (hook event) ]; } ];
in
{
  options.programs.claude-dim = {
    enable = lib.mkEnableOption "dimming a monitor while Claude Code is working";

    user = lib.mkOption {
      type = lib.types.str;
      default = "vboysepe";
      description = "User whose noctalia config gets the drop-in.";
    };

    pluginSource = lib.mkOption {
      type = lib.types.str;
      default = "~/.config/nixos/noctaliaplugin";
      description = ''
        Directory registered as the local noctalia plugin source. The live checkout
        hot-reloads plugin edits; use "''${./.}" for a pinned store copy.
      '';
    };

    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Other plugins to keep enabled (the drop-in replaces the whole list).";
    };

    controlCenterShortcuts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "wifi"
        "bluetooth"
        "caffeine"
        "nightlight"
        "power_profile"
        "vboysepe/claude-dim:toggle"
      ];
      description = "Full control-center tile list (the drop-in replaces the default list).";
    };

    claudeHooks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the Claude Code hooks as managed settings.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [ "L+ ${target} - - - - ${noctaliaConfig}" ];
      environment.systemPackages = [ pkgs.jq ];
    })

    (lib.mkIf (cfg.enable && cfg.claudeHooks) {
      environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
        hooks = {
          UserPromptSubmit = on "busy";
          PostToolUse = on "busy"; # heartbeat; re-dims after permission prompts / questions
          Stop = on "idle";
          Notification = on "idle";
          SessionEnd = on "idle";
          PreToolUse = [
            {
              matcher = "AskUserQuestion";
              hooks = [ (hook "idle") ];
            }
          ];
        };
      };
    })

    # Disabled: clean up the drop-in left by a previous generation.
    (lib.mkIf (!cfg.enable) {
      systemd.tmpfiles.rules = [ "r ${target}" ];
    })
  ];
}
