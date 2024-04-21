{ pkgs, ... }:
let
  offload = import ./scripts/offload.nix { inherit pkgs; };
in
{
  programs = { };

  home.packages = with pkgs; [
    lshw
    offload
  ];

  services = {
    xidlehook = {
      enable = true;
      environment = {
        "sink_count" = "${pkgs.pulseaudio}/bin/pacmd list-sink-inputs | grep -c 'state: RUNNING'";
      };
      timers = [
        { # quiet-suspend-quick
          delay = 60;
          command = "if [ $sink_count -eq 0 ]; then ${pkgs.systemd}/bin/systemctl suspend; fi";
        }
        { # quiet-hibernate-quick
          delay = 10;
          command = "if [ $sink_count -eq 0 ]; then ${pkgs.systemd}/bin/systemctl hibernate; fi";
        }
        { # always-suspend-slow
          delay = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
        { # always-hibernate-slow
          delay = 3600;
          command = "${pkgs.systemd}/bin/systemctl hibernate";
        }
      ];
    };
  };
}
