{
  description = "Roman darwin system";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other sources
    comma = { url = github:Shopify/comma; flake = false; };
    
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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
  };

  outputs = { self, darwin, nixpkgs, home-manager, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-bufbuild, nix-vscode-extensions, ... }@inputs:
  let 

    inherit (darwin.lib) darwinSystem;
    inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

    # Configuration for `nixpkgs`
    nixpkgsConfig = {
      config = { allowUnfree = true; };
      overlays = attrValues self.overlays ++ singleton (
        # Sub in x86 version of packages that don't build on Apple Silicon yet
        final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          inherit (final.pkgs-x86)
            idris2
            niv
            purescript;
        })
      );
    }; 
  in
  {
    # My `nix-darwin` configs
      
    darwinConfigurations = rec {
     Romans-MacBook-Pro = darwinSystem {
        system = "aarch64-darwin";
        modules =  [ 
          # Main `nix-darwin` config
          ./configuration.nix
          # `home-manager` module
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.romanbartusiak = import ./home.nix{ nix-vscode-extensions = nix-vscode-extensions;};            
          }

          #homebrew module
            nix-homebrew.darwinModules.nix-homebrew
  {
    nix-homebrew = {
      enable = true;

      enableRosetta = true;

      user = "romanbartusiak";

      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
        "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        "bufbuild/homebrew-buf" = inputs.homebrew-bufbuild;
      };

      mutableTaps = false;
    };
  }
        ];

      };
    };

    # Overlays --------------------------------------------------------------- {{{

    overlays = {
      # Overlays to add various packages into package set
        comma = final: prev: {
          comma = import inputs.comma { inherit (prev) pkgs; };
        };  

      # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          # Add access to x86 packages system is running Apple Silicon
          pkgs-x86 = import inputs.nixpkgs-unstable {
            system = "x86_64-darwin";
            inherit (nixpkgsConfig) config;
          };
        }; 
      };

    };
}
