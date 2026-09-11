{
  description = "A minimal hyprland desktop.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    stylix,
    nixvim,
    ...
  }: let
    system = "x86_64-linux";

    # Taken from https://dsestu.github.io/knowledge/docs/nixos/multi-host-flake.html
    # Factor out the common bits of a nixosSystem invocation so each host is a one-liner.
    mkHost = hostname: extraModules: extraHomeManagerModules: let
      my = {
        username = import ./username.nix;
        hostname = hostname;
      };
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs my;};
        modules =
          [
            ./hosts/${hostname}/configuration.nix
            ./hosts/${hostname}/hardware-configuration.nix
            ./modules/nixos/common.nix
            home-manager.nixosModules.home-manager
            {
              networking.hostName = hostname;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {inherit inputs my;};
                sharedModules =
                  [
                    stylix.homeModules.stylix
                    nixvim.homeModules.nixvim
                  ]
                  ++ extraHomeManagerModules;
                users.${my.username} = import ./home.nix;
              };
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      nixbox-hp =
        mkHost "nixbox-hp" [
          ./modules/nixos/wayland.nix
          ./modules/nixos/hyprland.nix
          ./modules/nixos/i3.nix
          ./modules/nixos/nix-ld.nix
        ] [
          ./modules/home-manager/hyprland.nix
          ./modules/home-manager/i3.nix
        ];
    };

    # Also expose a standalone home-manager config, for hosts that aren't NixOS (Kali, WSL2-Debian).
    homeConfigurations."${./username.nix}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {inherit system;};
      modules = [
        stylix.homeModules.stylix
        nixvim.homeModules.nixvim
        ./home.nix
      ];
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
