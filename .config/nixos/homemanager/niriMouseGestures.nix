{ ... }:
{
  # TODO: package niri-mouse-gestures in the flake. It's a hand-built cargo output
  # under ~/projects, which is why this can only run on hosts where it's been built.
  systemd.user.services.niri-mouse-gestures = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionPathExists = "%h/projects/niri/target/release/niri-mouse-gestures";
    };
    Service = {
      ExecStart = "%h/projects/niri/target/release/niri-mouse-gestures --external-trigger --step-threshold 80";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
