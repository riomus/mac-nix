flakes: { config, pkgs, lib, ... }:
let
vscode-extensions = flakes.nix-vscode-extensions.extensions.aarch64-darwin;
  additionalJDKs = with pkgs; [ temurin-bin-21 temurin-bin-17 ];
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
    signing ={
      key = "8BE7383653110620";
      signByDefault = true;
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
      nixu = "nix flake update --flake ~/.config/nix && sudo nix  --extra-experimental-features nix-command --extra-experimental-features  flakes run nix-darwin -- switch --flake ~/.config/nix --fallback";
      cat = "bat";
      ls = "exa";
    };
    initExtra = ''
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init -)"
    '';
  };
  programs.pyenv.enable=true;
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
    # Some basisc
    awscli2
    coreutils
    curl
    wget
    btop
    slack
    bat
    buf
    gnupg
    eza
    duf
    openjdk21
    mtr
    python312
    wrk
    spotify
    gitAndTools.gh
    hyperfine
    neofetch
    asitop
    netcat
    jq
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

  home.sessionPath = [
    "/Users/romanbartusiak/Library/Python/3.9/bin"
    "/Users/romanbartusiak/.local/bin"
  ];
  home.sessionVariables = {
    EDITOR= "vim";
  };



    home.file = lib.mkMerge[
      {


  ".config/starship.toml" = {
    source = ./starship.toml;
  };
  "Pictures/Backgrounds/1.jpg" = {
    source = ./bg.jpg;
  };
  ".config/sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };

  "Library/Application\ Support/discord/settings.json".text = ''
  {

    "MIN_WIDTH":0,
    "MIN_HEIGHT":0

  }
  '';

  ".hushlogin".text = ''
  '';
      }
    (builtins.listToAttrs (builtins.map (jdk: {
    name = ".jdks/${jdk.version}";
    value = { source = jdk; };
  }) additionalJDKs))
    ];
    
     
}
