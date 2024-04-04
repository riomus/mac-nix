{ pkgs, lib, inputs, ... }:
{

homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = pkgs.callPackage ./brews.nix {};
    casks = pkgs.callPackage ./casks.nix {};
  };
  # Nix configuration ------------------------------------------------------------------------------
  nix.settings.auto-optimise-store = true;
nix.gc = {
  automatic = true;
  interval = { Weekday = 0; Hour = 0; Minute = 0; };
  options = "--delete-older-than 7d";
};
  nix.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.trustedUsers = [
    "@admin"
  ];
  users.nix.configureBuildUsers = true;
  users.users.romanbartusiak.home= "/Users/romanbartusiak";

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;




  programs.nix-index.enable = true;

  # Fonts
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
      recursive
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "DroidSansMono" "SourceCodePro"]; })
      source-code-pro
      noto-fonts
      noto-fonts-cjk
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
  security.pam.enableSudoTouchIdAuth = true;


  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  system = {
      activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
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
      # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
      # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
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

 services.yabai = {
    enable = true;
    config = {
      focus_follows_mouse          = "autoraise";
      mouse_follows_focus          = "off";
      window_placement             = "second_child";
      window_shadow                = "none";
      split_ratio                  = "0.50";
      auto_balance                 = "off";
      mouse_modifier               = "ctrl";
      mouse_action1                = "move";
      mouse_action2                = "resize";
      layout                       = "bsp";
      top_padding                  = 10;
      bottom_padding               = 10;
      left_padding                 = 10;
      right_padding                = 10;
      window_gap                   = 10;
      external_bar = all:35:0;
    };


    extraConfig = ''
        # rules
        yabai -m rule --add app="^(Telegram)$" space=3;
        yabai -m rule --add app='Ustawienia systemowe' manage=off;
        apps="^(IntelliJ IDEA|WebStorm|RubyMine|PyCharm|DataGrip)$";
        yabai -m rule --add app="$\{apps\}" space=6
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
    services.skhd = {
      enable =true;
      skhdConfig = ''
        ctrl - return : open -na kitty

        ctrl - b : yabai -m space --layout bsp
        ctrl - s : yabai -m space --layout stack

        ctrl - down : yabai -m window --focus stack.next || yabai -m window --focus south
        ctrl - up : yabai -m window --focus stack.prev || yabai -m window --focus north
        ctrl  - left : yabai -m window --focus west
        ctrl  - right : yabai -m window --focus east

        ctrl + shift - 1 : yabai -m window --space 1
        ctrl + shift - 2 : yabai -m window --space 2
        ctrl + shift - 3 : yabai -m window --space 3
        ctrl + shift - 4 : yabai -m window --space 4
        ctrl + shift - 5 : yabai -m window --space 5
        ctrl + shift - 6 : yabai -m window --space 6
        ctrl + shift - 7 : yabai -m window --space 7
        ctrl + shift - 8 : yabai -m window --space 8
        ctrl + shift - 9 : yabai -m window --space 9
        

        ctrl - f : yabai -m window --toggle zoom-fullscreen

        ctrl + shift -right: yabai -m window --warp east
        ctrl + shift -left: yabai -m window --warp west
        ctrl + shift -up: yabai -m window --warp north


        ctrl + shift -down: yabai -m window --warp south

        ctrl - q : yabai -m window --close
      '';
    };


    services.sketchybar.enable=true;

    launchd.user.agents.borders = {
      serviceConfig.ProgramArguments = ["${pkgs.jankyborders}/bin/borders" "hidpi=on" "active_color=0xff30aa49" "inactive_color=0x1130aa49" "width=6.0" "blacklist=sketchybar" ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;

    }; 

    environment.systemPackages = with pkgs; [
      skhd
      sketchybar
      jq 
    ];

    
}
