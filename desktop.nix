{ pkgs, ... }:
let
  tmux-sessionizer = import ./scripts/tmux-sessionizer.nix { inherit pkgs; };
in
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      #autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        update = "sudo nixos-rebuild switch";
      };
      history.size = 10000;
      oh-my-zsh = {
        enable = true;
	plugins = [ "git" ];
	theme = "robbyrussell";
      };
    };
    alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.3;
	font.size = 8.0;
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitFull;
      userName = "Love Lysell Berglund";
      userEmail = "lovistovis0@gmail.com";
      extraConfig = {
        core = {
	  editor = "nvim";
	};
        credential.helper = "oauth";
      };
    };
    firefox = let
      lock-false = {
        Value = false;
        Status = "locked";
      };
      lock-true = {
        Value = true;
        Status = "locked";
      };
    in {
      enable = true;
      # languagePacks = [ "en-US" ];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        ExtensionSettings = {
          "*".installation_mode = "blocked";
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-MnnxcxisPBnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          "malito:darkreaderapp@gmail.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences = {
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
        };
      };
      profiles = {
        "mogos" = {
          id = 0;
          isDefault = true;

          # TODO: add nix search engines defined at nixos wiki firefox

          userChrome = import ./user-chrome.nix;
        };
      };
    };
  };

  home.packages = with pkgs; [
    tmux
    pavucontrol
    neofetch
    gimp
    discord
    neovim
    tree
    kitty
  # chromium
    st
    qdirstat
    nerdfonts
    davinci-resolve
    unityhub
    vlc
    spotify
    tor-browser-bundle-bin
    git-credential-oauth
    xsel
    tmux-sessionizer
  ];

  xsession = {
    windowManager.i3 = {
      enable = true;
    };
  };

  home.sessionVariables = rec {
    EDITOR = "nvim";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "${BROWSER}";
    TERMINAL = "alacritty";
  };

  xdg.configFile."awesome".source = ./config/awesome;

  # DMZ white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

  home.file.".background-image".source = ./wallpapers;
}
