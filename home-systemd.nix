{ pkgs, ... }:
{
  systemd = {
    user.services = {
      start-tmux-server = {
        Unit = {
          description = "Auto starts the tmux server on DE load.";
        };
        Service = {
          script = ''
            #!usr/bin/env bash
            ${pkgs.tmux}/bin/tmux start-server
          '';
          wantedBy = [ "multi-user.target" ]; # starts after login
        };
      };
    };
  };
}
