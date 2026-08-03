{
  description = "Roman darwin system";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other sources
    comma = { url = "github:Shopify/comma"; flake = false; };
    
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;
    overlays = import ./overlays { inherit inputs; };

    # The macOS account name differs per machine, so every path and option that
    # used to hardcode "romanbartusiak" now comes from `username`.
    mkDarwin = { username }: darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs username; };
      modules = [
        ./modules/darwin/default.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [
            overlays.comma
            overlays.apple-silicon
            overlays.modifications
          ];
        }
      ];
    };
  in
  {
    darwinConfigurations."HVX3TJNXW7" = mkDarwin { username = "romanbartusiak"; };
    darwinConfigurations."Romans-MacBook-Pro" = mkDarwin { username = "riomus"; };

    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
