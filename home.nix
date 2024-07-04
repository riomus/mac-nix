flakes: { config, pkgs, lib, ... }:
let
vscode-extensions = flakes.nix-vscode-extensions.extensions.aarch64-darwin;
in
{
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = true;

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
  mutableExtensionsDir = false;
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
    aliases = {
      amd = "!git add . && git commit --amend --no-edit";
      pf = "!git push --force";
      amdpf = "!git amd && git pf";
    };
  };

  programs.starship = {
    enable = true;
  };
  
  programs.zsh= {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      theme = "robbyrussell";
      enable = true;
      plugins = [ "git" "sudo" "docker" "kubectl" "aws"];
    };
    shellAliases = {
      nixu = "nix  --extra-experimental-features nix-command --extra-experimental-features  flakes run nix-darwin -- switch --flake ~/.config/nix --fallback";
      cat = "bat";
      ls = "exa";
    };
  };
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "FiraCode Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 14;
      disable_ligatures = "never";
      scrollback_lines = 100000;
      foreground = "#00ff15";
      background = "#000000";
      background_opacity = "0.8";
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      hide_window_decorations = true;
      copy_on_select = true;
    };
  };
  programs.navi.enable =true;
  home.packages = with pkgs; [
    # Some basics
    awscli
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
    python310
    wrk
    spotify
    gitAndTools.gh
    hyperfine
    neofetch
    asitop
    poetry
    postgresql
    
    discord
    telegram-desktop
    jankyborders
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    m-cli # useful macOS CLI commands
  ] ++ [
  (import ./raycast.nix {inherit pkgs;})
  (import ./jetbrains-toolbox.nix {inherit pkgs;})
  (import ./vlc.nix {inherit pkgs;})
  (import ./sketchybar-app-font.nix {inherit pkgs;})
  ];

  home.file.".config/starship.toml" = {
    source = ./starship.toml;
  };
  home.file."Pictures/Backgrounds/1.jpg" = {
    source = ./bg.jpg;
  };
  home.file.".config/sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };
  home.sessionPath = [
    "/Users/romanbartusiak/Library/Python/3.9/bin"
  ];

  # Misc configuration files --------------------------------------------------------------------{{{

  home.file."Library/Application\ Support/discord/settings.json".text = ''
  {

    "MIN_WIDTH":0,
    "MIN_HEIGHT":0

  }
  '';

  home.file.".hushlogin".text = ''
  '';

  home.sessionVariables = {
    EDITOR= "vim";
  };
     
}
