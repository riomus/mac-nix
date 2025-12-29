{ pkgs, lib, inputs, ... }:
{
  # Import nix-homebrew module
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  ids.gids.nixbld = 350;
  system.stateVersion = 5;

  homebrew = {
    enable = true;
    global = {
      autoUpdate = true;
    };
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none";
      extraFlags = [ "--force" ];
    };
    brews = pkgs.callPackage ./brews.nix { };
    casks = pkgs.callPackage ./casks.nix { };
  };

  # Nix configuration ------------------------------------------------------------------------------
  nix.settings.auto-optimise-store = false;
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 7d";
  };
  nix.settings.substituters = [
    "https://cache.nixos.org/"
  ];
  nix.settings.cores = 0;
  nix.settings.max-jobs = "auto";
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.settings.trusted-users = [
    "@admin"
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  users.users.romanbartusiak.home = "/Users/romanbartusiak";

  # Enable experimental nix command and flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  programs.nix-index.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    recursive
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.sauce-code-pro
    source-code-pro
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    proggyfonts
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "romanbartusiak";

    activationScripts.postActivation.text = ''
      ###############################################################################
      # General UI/UX                                                               #
      ###############################################################################
      # Disable the sound effects on boot
      sudo nvram SystemAudioVolume=" "
      # Automatically quit printer app once the print jobs complete
      defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
      # Reveal IP address, hostname, OS version, etc. when clicking the clock
      # in the login window
      sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
      ###############################################################################
      # SSD-specific tweaks                                                         #
      ###############################################################################
      # Disable hibernation (speeds up entering sleep mode)
       sudo pmset -a hibernatemode 0
      ###############################################################################
      # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
      ###############################################################################
      # Shows battery percentage
      defaults write com.apple.menuextra.battery ShowPercent YES; killall SystemUIServer
      # Increase sound quality for Bluetooth headphones/headsets
      defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
      # Follow the keyboard focus while zoomed in
      defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
      # Set language and text formats
      defaults write NSGlobalDomain AppleLanguages -array "pl"
      defaults write NSGlobalDomain AppleLocale -string "pl_PL@currency=PLN"
      defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
      defaults write NSGlobalDomain AppleMetricUnits -bool true
      # Stop iTunes from responding to the keyboard media keys
      launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null
      ###############################################################################
      # Screen                                                                      #
      ###############################################################################
      # Require password immediately after sleep or screen saver begins
      defaults write com.apple.screensaver askForPassword -int 1
      defaults write com.apple.screensaver askForPasswordDelay -int 0
      # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
      defaults write com.apple.screencapture type -string "png"
      # Disable shadow in screenshots
      defaults write com.apple.screencapture disable-shadow -bool true
      # Enable HiDPI display modes (requires restart)
      sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
      ###############################################################################
      # Finder                                                                      #
      ###############################################################################
      # Finder: disable window animations and Get Info animations
      defaults write com.apple.finder DisableAllAnimations -bool true
      # Set Desktop as the default location for new Finder windows
      # For other paths, use `PfLo` and `file:///full/path/here/`
      defaults write com.apple.finder NewWindowTarget -string "PfDe"
      defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Desktop/"
      # Finder: show status bar
      defaults write com.apple.finder ShowStatusBar -bool true
      # Finder: show path bar
      defaults write com.apple.finder ShowPathbar -bool true
      # Keep folders on top when sorting by name
      defaults write com.apple.finder _FXSortFoldersFirst -bool true
      # When performing a search, search the current folder by default
      defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
      # Avoid creating .DS_Store files on network or USB volumes
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
      defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
      # Automatically open a new Finder window when a volume is mounted
      defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
      defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
      defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
      # Use list view in all Finder windows by default
      # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
      defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
      # Disable the warning before emptying the Trash
      defaults write com.apple.finder WarnOnEmptyTrash -bool false
      # Enable AirDrop over Ethernet and on unsupported Macs running Lion
      defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
      # Show the ~/Library folder
      chflags nohidden ~/Library
      # Show the /Volumes folder
      sudo chflags nohidden /Volumes
      # Expand the following File Info panes:
      # “General”, “Open with”, and “Sharing & Permissions”
      defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true
    '';
    defaults = {
      NSGlobalDomain = {
        "com.apple.mouse.tapBehavior" = 1;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;  
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.001;
        _HIHideMenuBar = true;
      };

      dock = {
        autohide = true;
        orientation = "bottom";
      };

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };
    };
  };

  launchd.user.agents.yabai = {
    serviceConfig.ProgramArguments = [ "/opt/homebrew/bin/yabai" ];
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
    serviceConfig.StandardOutPath = "/tmp/yabai.log";
    serviceConfig.StandardErrorPath = "/tmp/yabai.log";
    serviceConfig.EnvironmentVariables = {
      PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH";
    };
  };

  launchd.user.agents.skhd = {
    serviceConfig.ProgramArguments = [ "/opt/homebrew/bin/skhd" ];
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
    serviceConfig.StandardOutPath = "/tmp/skhd.log";
    serviceConfig.StandardErrorPath = "/tmp/skhd.log";
    serviceConfig.EnvironmentVariables = {
      PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH";
    };
  };

  launchd.user.agents.sketchybar = {
    serviceConfig.ProgramArguments = [ "/opt/homebrew/bin/sketchybar" "-c" "/Users/romanbartusiak/.config/sketchybar/sketchybarrc" ];
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
    serviceConfig.StandardOutPath = "/tmp/sketchybar.log";
    serviceConfig.StandardErrorPath = "/tmp/sketchybar.log";
    serviceConfig.EnvironmentVariables = {
      PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH";
    };
  };

  launchd.user.agents.borders = {
    serviceConfig.ProgramArguments = ["${pkgs.jankyborders}/bin/borders" "hidpi=on" "active_color=0xff30aa49" "inactive_color=0x1130aa49" "width=6.0" "blacklist=sketchybar" ];
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };

  launchd.daemons.nix-optimize = {
    serviceConfig.ProgramArguments = [ "${pkgs.nix}/bin/nix" "store" "optimise" ];
    serviceConfig.StartCalendarInterval=[{ Hour = 17; }];
    serviceConfig.StandardOutPath = "/tmp/nix-optimize.log";
    serviceConfig.StandardErrorPath = "/tmp/nix-optimize.log";
  };

  environment.systemPackages = with pkgs; [
    jq
    pipx
  ];

  # add environment variables
  environment.variables = {
     HOMEBREW_UPGRADE_GREEDY = "true";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.romanbartusiak = import ../home-manager/default.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.backupFileExtension = "backup";

  # Nix Homebrew configuration
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "romanbartusiak";
    mutableTaps = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "bufbuild/homebrew-buf" = inputs.homebrew-bufbuild;
      "cockroachdb/homebrew-cockroach" = inputs.homebrew-cocroach;
      "hashicorp/homebrew-hashicorp" = inputs.homebrew-hashicorp;
      "felixkratz/homebrew-formulae" = inputs.homebrew-felixkratz;
      "koekeishiya/homebrew-formulae" = inputs.homebrew-koekeishiya;
    };
  };
}
