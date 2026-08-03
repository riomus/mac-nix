{ pkgs, lib, inputs, username, ... }:
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

  # mise, polyglot runtime/tool version manager (asdf replacement).
  # https://mise.jdx.dev
  programs.mise = { enable = true; };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = "UseKeychain yes";
    matchBlocks = {
      "github.com" = {
        user = "git";
        # identitiesOnly without an explicit key offers nothing to the server,
        # so name the recovered key here.
        identityFile = "~/.ssh/id_riomus";
        identitiesOnly = true;
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Roman Bartusiak";
    userEmail = "riomus@gmail.com";
    extraConfig = {
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      push.default = "current";
      core.sshCommand = "ssh -i ~/.ssh/id_riomus";
      pull.rebase = true;
      rerere.enable = true;
      # Sign commits with SSH instead of GPG — ~10x faster (no gpg-agent
      # round-trip) and uses the keys we already have. The .pub key paths
      # must also be registered as Signing Keys on GitHub for the green
      # "Verified" badge.
      gpg.format = "ssh";
    };
    lfs.enable = true;
    aliases = {
      amd = "!git add . && git commit --amend --no-edit";
      pf = "!git push --force";
      amdpf = "!git amd && git pf";
    };
    signing = {
      key = "/Users/${username}/.ssh/id_riomus.pub";
      signByDefault = true;
    };
    # Per-account overrides. The riomus identity is also the global default
    # above; this block is kept as the template for adding further accounts
    # under ~/git/<account>/.
    includes = [
      {
        condition = "gitdir:~/git/riomus/";
        contents = {
          user.name = "Roman Bartusiak";
          user.email = "riomus@gmail.com";
          user.signingKey = "/Users/${username}/.ssh/id_riomus.pub";
          core.sshCommand = "ssh -i ~/.ssh/id_riomus";
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
    autocd = true;

    # Default compinit rebuilds the dump on every shell start (~1.5s with
    # brew's 182-entry zsh-completions dir in fpath). Use the cached dump
    # and only do a full rebuild once per day. `mh-24` is "modified <24h
    # ago" — the glob qualifier makes this fork-free.
    completionInit = ''
      autoload -Uz compinit
      if [[ -n $HOME/.zcompdump(#qN.mh-24) ]]; then
        compinit -C
      else
        compinit
      fi
    '';

    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      extended = true;
    };

    # Plugins are sourced directly via home-manager rather than zplug —
    # zplug's bookkeeping cost ~150ms per shell start.
    #
    # zsh-github-copilot was removed here: it shells out to
    # `gh copilot suggest -t shell` / `gh copilot explain`, the interface of
    # the old gh-copilot *extension*. gh 2.97 turned `copilot` into a
    # built-in that launches GitHub's Copilot CLI instead, so the extension
    # can no longer even be installed ("copilot" matches the name of a
    # built-in command) and the plugin printed a warning on every new shell.
    # Upstream's last commit is 2025-04-07 and does not account for this.
    plugins = [
      # fzf-tab turns <Tab> into an fzf fuzzy picker. Listed first so it
      # loads right after compinit and before autosuggestions/syntax-
      # highlighting wrap the completion widgets (its load-order rule).
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    shellAliases = {
      ls = "exa";
      cat = "bat";
      nixu =
        "nix flake update --flake ~/git/riomus/mac-nix && sudo  nix run nix-darwin -- switch --flake  ~/git/riomus/mac-nix";

      # git — high-traffic subset of oh-my-zsh's git plugin
      g = "git";
      gst = "git status";
      gco = "git checkout";
      gcb = "git checkout -b";
      gc = "git commit -v";
      gca = "git commit -a -v";
      gcm = "git commit -m";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gl = "git pull";
      gd = "git diff";
      gds = "git diff --staged";
      gb = "git branch";
      gba = "git branch -a";
      ga = "git add";
      gaa = "git add --all";
      glog = "git log --oneline --decorate --graph";
      glo = "git log --oneline --decorate --graph --all";
      gss = "git stash";
      gsp = "git stash pop";
      grb = "git rebase";
      grbi = "git rebase -i";
      grbc = "git rebase --continue";
      gm = "git merge";

      # kubectl
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kgd = "kubectl get deployments";
      kgn = "kubectl get nodes";
      kaf = "kubectl apply -f";
      kdel = "kubectl delete";
      klog = "kubectl logs -f";
      kex = "kubectl exec -it";

      # docker
      d = "docker";
      dps = "docker ps";
      dpsa = "docker ps -a";
      dex = "docker exec -it";
      dlog = "docker logs -f";
      dimg = "docker images";
    };

    # Brew-installed completions (docker, kubectl, helm, …) live under
    # /opt/homebrew/share. They must be in fpath BEFORE compinit runs, so
    # we set them here in .zshenv rather than .zshrc.
    envExtra = ''
      if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
        fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
      fi
      if [[ -d /opt/homebrew/share/zsh-completions ]]; then
        fpath=(/opt/homebrew/share/zsh-completions $fpath)
      fi
    '';

    initContent = ''
      # Interactive completion behaviour — the subset of oh-my-zsh's
      # lib/completion.zsh worth keeping. Pure zsh, no startup cost.
      zmodload zsh/complist
      # Arrow-navigable, highlighted menu instead of a flat list dump.
      zstyle ':completion:*' menu select
      bindkey -M menuselect '^[[Z' reverse-menu-complete   # shift-tab steps back
      # Case-insensitive, then partial-word, then substring matching:
      # `dow<Tab>` → Downloads, `c.t<Tab>` → config.toml.
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      # Colour the listing using the same palette as `ls`.
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      # Group matches under descriptive headers (e.g. "external command",
      # "alias") and show the description line.
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
      # Cache slow completers (apt/brew/etc.) under XDG cache.
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"

      # fzf-tab tuning. menu-select above stays as the fallback if fzf-tab
      # isn't loaded.
      zstyle ':fzf-tab:*' switch-group ',' '.'          # cycle groups with , / .
      zstyle ':fzf-tab:*' use-fzf-default-opts yes
      # Preview directory contents with exa when completing cd/ls targets.
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always --icons $realpath'
      zstyle ':fzf-tab:complete:*:*' fzf-preview \
        '[[ -d $realpath ]] && exa -1 --color=always --icons $realpath || bat --color=always --style=plain $realpath 2>/dev/null || cat $realpath'

      # ESC-ESC prepends `sudo` to the current command (omz sudo plugin replacement).
      __prepend_sudo() {
        [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
        zle end-of-line
      }
      zle -N __prepend_sudo
      bindkey "\e\e" __prepend_sudo

      # aws CLI tab-completion (the binary ships its own completer).
      command -v aws_completer >/dev/null && complete -C aws_completer aws

      # Lazy-load pyenv. `eval "$(pyenv init - zsh)"` costs ~100ms per
      # shell start; deferring it until first python/pip/pyenv invocation
      # makes shells launch instantly. Once the real init runs, shims hit
      # PATH and these stubs delete themselves.
      __pyenv_lazy_init() {
        unset -f pyenv python pip python3 pip3 2>/dev/null
        eval "$(command pyenv init - zsh)"
      }
      pyenv()   { __pyenv_lazy_init; pyenv "$@"; }
      python()  { __pyenv_lazy_init; python "$@"; }
      pip()     { __pyenv_lazy_init; pip "$@"; }
      python3() { __pyenv_lazy_init; python3 "$@"; }
      pip3()    { __pyenv_lazy_init; pip3 "$@"; }

      notify() {
        osascript -e "tell application \"Messages\" to send \"$1\" to buddy \"+48880002457\""
      }

      # Shared claude/codex tmux sessions (ai-start / ai-join / ai-ls).
      [[ -f $HOME/.config/ai-tmux.zsh ]] && source $HOME/.config/ai-tmux.zsh

      # claude-auto-retry: keep this in Home Manager instead of letting the
      # installer mutate ~/.zshrc, which is a /nix/store symlink here.
      unalias claude 2>/dev/null || true
      claude() {
        if [ "''${CLAUDE_AUTO_RETRY_ACTIVE}" = "1" ]; then
          command claude "$@"
          return $?
        fi
        if [ ! -f /opt/homebrew/lib/node_modules/claude-auto-retry/src/launcher.js ]; then
          command claude "$@"
          return $?
        fi
        export CLAUDE_AUTO_RETRY_ACTIVE=1
        local _car_old_int_trap _car_old_term_trap
        _car_old_int_trap=$(trap -p INT)
        _car_old_term_trap=$(trap -p TERM)
        trap 'unset CLAUDE_AUTO_RETRY_ACTIVE' INT TERM
        node /opt/homebrew/lib/node_modules/claude-auto-retry/src/launcher.js "$@"
        local _car_exit=$?
        unset CLAUDE_AUTO_RETRY_ACTIVE
        eval "''${_car_old_int_trap:-trap - INT}"
        eval "''${_car_old_term_trap:-trap - TERM}"
        return $_car_exit
      }
    '';
  };

  # pyenv binary + PYENV_ROOT, but skip the eager `eval "$(pyenv init -)"`
  # that costs ~100ms per shell. The zsh initContent installs lazy stubs
  # that run `pyenv init` only when python/pip/pyenv is first invoked.
  programs.pyenv = {
    enable = true;
    enableZshIntegration = false;
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

  # kitty's __watch_conf__ kitten leaks file descriptors when watching a
  # symlink into /nix/store (observed: ~11k FDs/sec until ENFILE). Replace
  # the home-manager symlink with a real file copy so the watcher sees a
  # stable inode.
  home.activation.removeMaterializedKittyConf =
    lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -f $HOME/.config/kitty/kitty.conf
    '';
  home.activation.materializeKittyConf =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      KITTY_CONF="$HOME/.config/kitty/kitty.conf"
      if [ -L "$KITTY_CONF" ]; then
        TARGET=$(readlink -f "$KITTY_CONF")
        if [ -f "$TARGET" ]; then
          $DRY_RUN_CMD rm -f "$KITTY_CONF"
          $DRY_RUN_CMD install -m 0644 "$TARGET" "$KITTY_CONF"
        fi
      fi
    '';
  # Materializing kitty.conf swaps its inode, so running kitty instances keep
  # reading the old (removed) file and lose their styling after an update.
  # SIGUSR1 tells kitty to reload its config from disk. Match the main "kitty"
  # process only -- never the "kitten" helpers (signalling them is harmful).
  home.activation.reloadKitty =
    lib.hm.dag.entryAfter [ "materializeKittyConf" ] ''
      /bin/ps -Axww -o pid=,args= 2>/dev/null \
        | grep -E '/MacOS/kitty( |$)' \
        | while read -r pid _rest; do
            $DRY_RUN_CMD /bin/kill -USR1 "$pid" 2>/dev/null || true
          done || true
    '';

  programs.navi.enable = true;

  # tmux — backbone for the shared claude/codex sessions reachable from the
  # phone over Tailscale (see ai-start / ai-join in the zsh initContent).
  programs.tmux = {
    enable = true;
    mouse = true;
    historyLimit = 100000;
    escapeTime = 10;             # snappier ESC handling for vim/claude TUIs
    terminal = "tmux-256color";
    extraConfig = ''
      # When laptop + phone attach to the SAME session, size the window to the
      # smallest *currently attached* client so both see an identical mirror.
      # Detach the phone (prefix d) and the laptop snaps back to full size.
      set -g window-size smallest
      setw -g aggressive-resize on
      set -g focus-events on
      set -ga terminal-overrides ",*256col*:Tc"   # truecolor passthrough
    '';
  };

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
      mosh
      python312
      wrk
      spotify
      gitAndTools.gh
      hyperfine
      neofetch
      asitop
      netcat
      jq
      yq-go
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
    "/opt/homebrew/opt/make/libexec/gnubin"
    "/opt/homebrew/opt/helm@4/bin"
    "/Users/${username}/Library/Python/3.9/bin"
    "/Users/${username}/.local/bin"
  ];
  home.sessionVariables = { EDITOR = "vim"; };

  # The wallpaper file is placed under ~/Pictures/Backgrounds by home.file
  # above, but nothing ever selected it — on a fresh machine macOS keeps its
  # own default. Set it on activation so a rebuilt Mac looks right without a
  # manual trip through System Settings. Non-fatal: osascript needs Automation
  # permission, which is not available on the very first headless activation.
  home.activation.setDesktopPicture =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "/Users/${username}/Pictures/Backgrounds/1.jpg"' || true
    '';

  # system.defaults sets NSGlobalDomain._HIHideMenuBar, but writing that pref
  # does not affect a running session — it only takes hold after a logout.
  # Until then macOS still reserves the 38px menu bar while yabai additionally
  # reserves external_bar's 35px, so tiled windows sit ~38px too low. This
  # AppleScript applies the same setting live, making the geometry correct
  # immediately after a rebuild instead of after the next logout.
  home.activation.hideMenuBar =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      /usr/bin/osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true' || true
    '';

  # Yabai configuration
  xdg.configFile."yabai/yabairc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh

      # config
      yabai -m config focus_follows_mouse autoraise
      yabai -m config mouse_follows_focus off
      yabai -m config window_placement second_child
      #yabai -m config window_shadow none
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
    # `open -na` forces a brand-new, fully independent kitty process for every
    # launch. Without it (or with --single-instance) all terminals live inside a
    # single process and closing one window tears down every other window too.
    ctrl - return : /usr/bin/open -na /Applications/kitty.app --args -d /Users/${username} -c /Users/${username}/.config/kitty/kitty.conf -T term

    ctrl - b : /opt/homebrew/bin/yabai -m space --layout bsp
    ctrl - s : /opt/homebrew/bin/yabai -m space --layout stack

    ctrl - down : /opt/homebrew/bin/yabai -m window --focus stack.next || /opt/homebrew/bin/yabai -m window --focus south
    ctrl - up : /opt/homebrew/bin/yabai -m window --focus stack.prev || /opt/homebrew/bin/yabai -m window --focus north
    ctrl  - left : /opt/homebrew/bin/yabai -m window --focus west
    ctrl  - right : /opt/homebrew/bin/yabai -m window --focus east

    ctrl + shift - 1 : /opt/homebrew/bin/yabai -m window --space 1
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
      ".config/ai-tmux.zsh" = { source = ./ai-tmux.zsh; };
      "Pictures/Backgrounds/1.jpg" = { source = ./bg.jpg; };
      ".config/sketchybar" = {
        source = ./sketchybar;
        recursive = true;
      };

      "Library/Application Support/discord/settings.json".text = ''
        {
          "MIN_WIDTH":0,
          "MIN_HEIGHT":0,
          "SKIP_HOST_UPDATE":true
        }
      '';

      ".hushlogin".text = "";

      # Homebrew 6.0 makes tap-trust checks the default
      # (HOMEBREW_REQUIRE_TAP_TRUST). Without trusting them, the `brew bundle`
      # run during `nixu` activation refuses to load formulae from these
      # third-party taps and aborts the rebuild. brew reads this file on every
      # invocation from ~/.homebrew/trust.json (XDG_CONFIG_HOME is unset). Any
      # NEW third-party tap added to brews.nix must also be listed here.
      ".homebrew/trust.json".text = builtins.toJSON {
        trustedtaps = [
          "bufbuild/buf"
          "cockroachdb/tap"
          "felixkratz/formulae"
          "hashicorp/tap"
          # yabai/skhd. The author renamed his GitHub account koekeishiya ->
          # asmvik (same repo: 184 commits back to 2017, all from
          # aasvi93@hotmail.com). brew follows the redirect and rewrites this
          # file to the canonical new name, stripping "koekeishiya/formulae"
          # again on every run — so only the new name is listed here, and
          # brews.nix refers to asmvik/formulae/* to match.
          "asmvik/formulae"
          "pulumi/tap"
        ];
      };
    }
    (builtins.listToAttrs (builtins.map (jdk: {
      name = ".jdks/${jdk.version}";
      value = { source = jdk; };
    }) additionalJDKs))
  ];
}
