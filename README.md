# Personal NixOS Config

Fairly minimal i3 session focused on tmux utilites and functional shortcuts. Per device settings get loaded from the hosts directory depending on the hostname set in configuration.nix.

### Setup
Clone into `~/tmux-conf` and remember to symlink `configuration.nix` to `/etc/nixos/configuration.nix`.
Change the username in configuration.nix

Install [nltch](https://app.cachix.org/cache/nltch)
```
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use nltch
```

Rebuild
```
sudo nixos-rebuild switch
```
