flakes: { config, pkgs, lib, ... }:
let
vscode-extensions = flakes.nix-vscode-extensions.extensions.aarch64-darwin;
in
{
  home.stateVersion = "23.11";

  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
  
  programs.vscode = {
  enable = true;
  immutableExtensionsDir = true;
  extensions = (with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
    ]) ++ (with vscode-extensions.vscode-marketplace; [
      jnoortheen.nix-ide
      github.copilot
      kamikillerto.vscode-colorize
      tamasfe.even-better-toml
    ]);
  };

  programs.fzf = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Roman Bartusiak";
    userEmail = "roman.bartusiak@yohana.com";
    extraConfig = {
       url."ssh://git@github.com/".insteadOf="https://github.com/";
       push.default="current";
    };
  };

  programs.starship = {
    enable = true;
  };
  
  programs.zsh= {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      theme = "robbyrussell";
      enable = true;
      plugins = [ "git" "sudo" "docker" "kubectl" ];
    };
    shellAliases = {
      nixu = "  nix  --extra-experimental-features nix-command --extra-experimental-features  flakes run nix-darwin -- switch --flake ~/.config/nix";
    };
  };
  programs.alacritty= {
    enable=true;
    settings = {
      font = {
        size = 14;
        normal = {
          family = "Source Code Pro";
          style = "Regular";
        };
        bold = {
          family = "Source Code Pro";
          style = "Bold";
        };
        italic = {
          family = "Source Code Pro";
          style = "Italic";
        };
        bold_italic = {
          family = "Source Code Pro";
          style = "Bold Italic";
        };
      };
      scrolling.history = 100000;
      window ={
        opacity = 0.8;
        decorations = "None";
      };
      colors = {
        primary = {
          background = "0x000000";
          foreground = "0x00ff15";
        };
        cursor = {
          text = "0xffffff";
          cursor = "0x00ab0e";
        };
      };
    };
  };
  programs.navi.enable =true;
  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget
    btop
    slack
    bat
    eza
    duf
    openjdk17
    mtr
    python3
    wrk
    spotify
    gitAndTools.gh
    hyperfine
    neofetch
    asitop
    poetry

    discord
    telegram-desktop
    jankyborders
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    m-cli # useful macOS CLI commands
  ] ++ [ 
  (import ./arc.nix {inherit pkgs;}) 
  (import ./capcut.nix {inherit pkgs;}) 
  (import ./raycast.nix {inherit pkgs;})
  (import ./jetbrains-toolbox.nix {inherit pkgs;})
  (import ./vlc.nix {inherit pkgs;})
  (import ./sketchybar-app-font.nix {inherit pkgs;})
  ];

  home.file.".config/starship.toml" = {
    source = ./starship.toml;
  };
  home.file.".config/sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };

  # Misc configuration files --------------------------------------------------------------------{{{

  home.file."Library/Application\ Support/discord/settings.json".text = ''
  {
    "MIN_WIDTH":0,
    "MIN_HEIGHT":0

  }
  '';


  home.sessionVariables = {
    EDITOR= "vim";
  };
     
}
