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

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-bufbuild ={
      url = "github:bufbuild/homebrew-buf";
      flake = false;
    };
    homebrew-cocroach ={
      url = "github:cockroachdb/homebrew-tap";
      flake = false;
    };
    homebrew-hashicorp ={
      url = "github:hashicorp/homebrew-tap";
      flake = false;
    };
    homebrew-felixkratz = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    homebrew-koekeishiya = {
      url = "github:koekeishiya/homebrew-formulae";
      flake = false;
    };
    homebrew-pulumi = {
      url = "github:pulumi/homebrew-tap";
      flake = false;
    };
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
  let 
    inherit (darwin.lib) darwinSystem;
    overlays = import ./overlays { inherit inputs; };
  in
  {
    darwinConfigurations."HVX3TJNXW7" = darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
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

    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
