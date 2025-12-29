{ pkgs, lib, inputs, ... }:
let
  vscode-extensions = inputs.nix-vscode-extensions.extensions.aarch64-darwin;
  additionalJDKs = with pkgs; [ temurin-bin-21 temurin-bin-17 ];
in {
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
    mutableExtensionsDir = true;
    profiles.default.extensions =
      (with pkgs.vscode-extensions; [ dracula-theme.theme-dracula ])
      ++ (with vscode-extensions.vscode-marketplace; [
        jnoortheen.nix-ide
        kamikillerto.vscode-colorize
        tamasfe.even-better-toml
      ]);
  };

  programs.fzf = { enable = true; };

  programs.git = {
    enable = true;
    userName = "Roman Bartusiak";
    userEmail = "roman.bartusiak@ext.us.panasonic.com";
    extraConfig = {
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      push.default = "current";
      core.sshCommand = "ssh -i ~/.ssh/id_riomus";
    };
    lfs.enable = true;
    aliases = {
      amd = "!git add . && git commit --amend --no-edit";
      pf = "!git push --force";
      amdpf = "!git amd && git pf";
    };
    signing = {
      key = "1C7199BF";
      signByDefault = true;
    };
    includes = [
      {
        condition = "gitdir:~/git/riomus/";
        contents = {
          user.name = "Roman Bartusiak";
          user.email = "riomus@gmail.com";
          user.signingKey = "620928E8";
          core.sshCommand = "ssh -i ~/.ssh/id_riomus";
        };
      }
      {
        condition = "gitdir:~/git/panasonic/";
        contents = {
          user.name = "Roman Bartusiak";
          user.email = "roman.bartusiak@ext.us.panasonic.com";
          user.signingKey = "1C7199BF";
          core.sshCommand = "ssh -i ~/.ssh/id_panasonic";
        };
      }
    ];
  };

  programs.starship = { enable = true; };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    zplug = {
      enable = true;
      plugins = [{ name = "loiccoyle/zsh-github-copilot"; }];
    };
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" "docker" "kubectl" "aws" ];
    };
    shellAliases = {
      ls = "exa";
      nixu =
        "nix flake update --flake ~/.config/nix && sudo  nix run nix-darwin -- switch --flake  ~/.config/nix";
      cat = "bat";
    };
    initContent = ''
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init -)"
      bindkey '«' zsh_gh_copilot_suggest
      bindkey '»' zsh_gh_copilot_explain
    '';
  };

  programs.pyenv.enable = true;
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
  programs.navi.enable = true;

  home.packages = with pkgs;
    [
      # Some basics
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
      nixfmt
    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ] ++ [
      (import ./raycast.nix { inherit pkgs; })
      (import ./jetbrains-toolbox.nix { inherit pkgs; })
      (import ./vlc.nix { inherit pkgs; })
      (import ./sketchybar-app-font.nix { inherit pkgs; })
    ];

  home.sessionPath = [
    "/Users/romanbartusiak/Library/Python/3.9/bin"
    "/Users/romanbartusiak/.local/bin"
  ];
  home.sessionVariables = { EDITOR = "vim"; };

  # Yabai configuration
  xdg.configFile."yabai/yabairc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh

      # config
      yabai -m config focus_follows_mouse autoraise
      yabai -m config mouse_follows_focus off
      yabai -m config window_placement second_child
      yabai -m config window_shadow none
      yabai -m config split_ratio 0.50
      yabai -m config auto_balance off
      yabai -m config mouse_modifier ctrl
      yabai -m config mouse_action1 move
      yabai -m config mouse_action2 resize
      yabai -m config layout bsp
      yabai -m config top_padding 10
      yabai -m config bottom_padding 10
      yabai -m config left_padding 10
      yabai -m config right_padding 10
      yabai -m config window_gap 10
      yabai -m config external_bar all:35:0

      # rules
      yabai -m rule --add app="^(Telegram)$" space=3;
      yabai -m rule --add app='Ustawienia systemowe' manage=off;
      apps="^(IntelliJ IDEA|WebStorm|RubyMine|PyCharm|DataGrip)$";
      yabai -m rule --add app="^(Spotify)$" space=8;
      yabai -m rule --add app="^(Slack)$" space=10;
      yabai -m rule --add app="^(Discord)$" space=10;
      yabai -m rule --add app="^(Messanger)$" space=9;
      yabai -m rule --add app="^(WhatsApp)$" space=9;

      yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
      yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
      yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
    '';
  };

  # skhd configuration
  xdg.configFile."skhd/skhdrc".text = ''
    ctrl - return : open -na /Applications/kitty.app --args -c /Users/romanbartusiak/.config/kitty/kitty.conf -T term /Users/romanbartusiak

    ctrl - b : /opt/homebrew/bin/yabai -m space --layout bsp
    ctrl - s : /opt/homebrew/bin/yabai -m space --layout stack

    ctrl - down : /opt/homebrew/bin/yabai -m window --focus stack.next || /opt/homebrew/bin/yabai -m window --focus south
    ctrl - up : /opt/homebrew/bin/yabai -m window --focus stack.prev || /opt/homebrew/bin/yabai -m window --focus north
    ctrl  - left : /opt/homebrew/bin/yabai -m window --focus west
    ctrl  - right : /opt/homebrew/bin/yabai -m window --focus east

    ctrl + shift - 1 : y/opt/homebrew/bin/yabaiabai -m window --space 1
    ctrl + shift - 2 : /opt/homebrew/bin/yabai -m window --space 2
    ctrl + shift - 3 : /opt/homebrew/bin/yabai -m window --space 3
    ctrl + shift - 4 : /opt/homebrew/bin/yabai -m window --space 4
    ctrl + shift - 5 : /opt/homebrew/bin/yabai -m window --space 5
    ctrl + shift - 6 : /opt/homebrew/bin/yabai -m window --space 6
    ctrl + shift - 7 : /opt/homebrew/bin/yabai -m window --space 7
    ctrl + shift - 8 : /opt/homebrew/bin/yabai -m window --space 8
    ctrl + shift - 9 : /opt/homebrew/bin/yabai -m window --space 9


    ctrl - f : /opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen

    ctrl + shift -right: /opt/homebrew/bin/yabai -m window --warp east
    ctrl + shift -left: /opt/homebrew/bin/yabai -m window --warp west
    ctrl + shift -up: /opt/homebrew/bin/yabai -m window --warp north

    ctrl + shift -down: /opt/homebrew/bin/yabai -m window --warp south

    ctrl - q : /opt/homebrew/bin/yabai -m window --close

    ctrl + shift - q : launchctl kickstart -k "gui/501/org.nixos.yabai"
  '';

  home.file = lib.mkMerge [
    {
      ".config/starship.toml" = { source = ./starship.toml; };
      "Pictures/Backgrounds/1.jpg" = { source = ./bg.jpg; };
      ".config/sketchybar" = {
        source = ./sketchybar;
        recursive = true;
      };

      "Library/Application Support/discord/settings.json".text = ''
        {
          "MIN_WIDTH":0,
          "MIN_HEIGHT":0
        }
      '';

      ".hushlogin".text = "";
    }
    (builtins.listToAttrs (builtins.map (jdk: {
      name = ".jdks/${jdk.version}";
      value = { source = jdk; };
    }) additionalJDKs))
  ];
}
