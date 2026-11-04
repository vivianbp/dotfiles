{ pkgsUnstable, ... }:
{
  home.packages = [ pkgsUnstable.lan-mouse ];

  systemd.user.services.lan-mouse = {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Service.ExecStart = "${pkgsUnstable.lan-mouse}/bin/lan-mouse daemon";
    Service.Restart = "on-failure";
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
