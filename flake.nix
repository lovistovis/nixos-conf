{
  description = "A minimal hyprland desktop.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      username = import ./username.nix;

      system = "x86_64-linux";

      # Taken from https://dsestu.github.io/knowledge/docs/nixos/multi-host-flake.html
      # Factor out the common bits of a nixosSystem invocation so each host is a one-liner.
      mkHost = hostname: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            ./hosts/${hostname}/hardware-configuration.nix
            ./modules/nixos/common.nix
            home-manager.nixosModules.home-manager
            {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix;
            }
          ] ++ extraModules;
        };
  in {
    nixosConfigurations = {
      nixbox-hp = mkHost "nixbox-hp" [
        ./modules/nixos/hyprland.nix
        ./modules/nixos/nix-ld.nix
      ];
    };

    # Also expose a standalone home-manager config, for hosts that aren't NixOS (Kali, WSL2-Debian).
    homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      modules = [ ./home.nix ];
    };

    # formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
