{ config, pkgs, ... }:
let
  tmux-sessionizer = import ./scripts/tmux-sessionizer.nix { inherit pkgs; };
  #tmux-store = import ./scripts/tmux-store.nix {
  #  inherit pkgs;
  #};
  tmux-start = import ./scripts/tmux-start.nix { inherit pkgs; };
  path = builtins.toString ./.;
  rebuild = import ./scripts/rebuild.nix {
    inherit pkgs;
    inherit path;
  };
in {
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      #autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        update = "sudo nixos-rebuild switch";
	fupdate = "sudo nixos-rebuild switch --fast";
	upgrade = "sudo nix-channel --update; update";
	clean = "sudo nix-collect-garbage --delete-old";
	reload-systemd = "systemctl reload systemd-logind.service";
	n = "if [[ -f \"Session.vim\" ]]; then nvim -S; else nvim .; fi";
	rust = "nix-shell ${path}/shell/rust.nix";
      };
      history.size = 10000;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
      prezto = {
        #enable = true
	#python.virtualenvAutoSwitch = true;
      };
      #plugins = [ # currenly not working out rust
      #  {
      #    name = "zsh-nix-shell";
      #    file = "nix-shell.plugin.zsh";
      #    src = pkgs.fetchFromGitHub {
      #      owner = "chisui";
      #      repo = "zsh-nix-shell";
      #      rev = "v0.8.0";
      #      sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
      #    };
      #  }
      #];
      dotDir = ".zsh"; 
      #initExtra = ''
      #  function shellExit {
      #    tmux-store save
      #  }
      #  trap shellExit EXIT
      #'';
    };
    alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.3;
        font.size = 8.0;
        #shell = { program = "${pkgs.zsh}/bin/zsh"; args = [ "-c tmux" ]; };
      };
    };
    tmux = let
      auto-restore = import ./scripts/auto-restore.nix {
        inherit pkgs;
      };
    in {
      enable = true;
      historyLimit = 10000;
      keyMode = "vi";
      plugins = with pkgs; [
        tmuxPlugins.cpu
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
	    set -g @resurrect-capture-pane-contents 'on'
	    set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-processes '"~nvim->nvim *"'

	    run '${auto-restore}/bin/auto-restore'

            set-hook -g 'client-detached' "run-shell ${tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh" # auto save

            #resurrect_dir="$(show resurrect-dir)"
            #resurrect_dir="$HOME/.tmux/resurrect"
            #set -g @resurrect-dir $resurrect_dir
            #set -g @resurrect-hook-post-save-all 'sed -i "s/*nvim/nvim/" $resurrect_dir/last'
	    #show -g @resurrect-dir
	  '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            #set -g @continuum-restore 'on'
	    set -g @continuum-save-interval '20' # minutes
          '';
        }
      ];
      extraConfig = import ./raw/tmux.nix {
        inherit pkgs;
	inherit config;
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitFull;
      userName = "Love Lysell Berglund";
      userEmail = "lovistovis0@gmail.com";
      ignores = [
        "**/nixos-switch.log"
	"**/Session.vim"
      ];
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
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
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
    dbus
    unzip
    tree
    parted
    tmux
    pavucontrol
    neofetch
    gimp
    opentoonz
    discord
    vesktop
    discordo
    neovim
    kitty
    # chromium
    st
    qdirstat
    # davinci-resolve
    unityhub
    vlc
    nur.repos.nltch.spotify-adblock
    tor-browser-bundle-bin
    git-credential-oauth
    xsel
    tmux-sessionizer
    tmux-start
    rebuild
    spotdl
    brightnessctl
    xorg.xev
    renpy
  ];

  home.sessionVariables = rec {
    EDITOR = "nvim";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "${BROWSER}";
    TERMINAL = "alacritty";
  };

  gtk = {
    enable = true;
    #gtk3.extraConfig.gtk-decoration-layout = "menu:";
    theme = {
      name = "Tokyonight-Dark-B";
      package = pkgs.tokyo-night-gtk;
    };
    iconTheme = {
      name = "Tokyonight-Dark";
    };
    #cursorTheme = {
    #  name = gtkCursorTheme;
    #  package = pkgs.bibata-cursors;
    #};
  };

  xsession = {
    windowManager.i3 = {
      enable = true;
      config = with { mod = "Mod4"; }; {
        modifier = mod;
        terminal = "alacritty -e zsh -c tmux-start"; # ugly fix but ok
      };
      extraConfig = ''
        exec ${pkgs.tmux}/bin/tmux start-server # avoid the wait for restoring sessions
        workspace "1" output eDP-1
      ''; # TODO: Make this work regardless of the display name
    };
  };

  #xdg.configFile."awesome".source = ./config/awesome;
  xdg.configFile."nvim".source = ./config/nvim;
  xdg.configFile."vesktop/themes".source = ./config/vencord-themes;

  # DMZ white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

  home.file.".background-image".source = ./wallpapers;
}
