{ config, pkgs, stdenv, ... }:
let
  path = builtins.toString ./.;
  tmux-sessionizer = import ./scripts/tmux-sessionizer.nix { inherit pkgs; };
  tmux-create = import ./scripts/tmux-create.nix { inherit pkgs; };
  tmux-delete = import ./scripts/tmux-delete.nix { inherit pkgs; };
  rebuild = import ./scripts/rebuild.nix { inherit pkgs path; };
  stable = import <nixos-stable> { config = { allowUnfree = true; }; };
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
        clean = "nix-collect-garbage --delete-old; sudo nix-collect-garbage --delete-old";
        reload-systemd = "systemctl reload systemd-logind.service";
        n = "if [[ -f \"Session.vim\" ]]; then nvim -S; else nvim .; fi";
        rustshell = "nix-shell ${path}/shell/rust.nix";
        zigshell = "nix-shell ${path}/shell/zig.nix";
        hdmi1 = "xrandr --output HDMI1 --auto";
        hdmi1-off = "xrandr --output HDMI1 --off";
        shu = "shutdown now";
        reb = "sudo reboot now";
        hib = "systemctl hibernate";
        ryujinx-portable = "ryujinx -r ~/ryujinx-data";
      };
      history.size = 10000;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
      prezto = {
        # enable = true;
        # python.virtualenvAutoSwitch = true;
        # python.virtualenvInitialize = true;
      };
      plugins = [ # currenly not working out rust
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.8.0";
            sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
          };
        }
      ];
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
        #window.opacity = 0.95;
        font.size = 8.0;
        colors.primary = {
          background = "#000000";
        };
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
        inherit pkgs config;
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
        "**/shell.nix"
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
          #"*".installation_mode = "blocked";
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
    # dolphin
    tmux
    pavucontrol
    neofetch
    gimp
    # opentoonz
    discord
    vesktop
    # discordo
    neovim
    # chromium
    ffmpeg
    st
    qdirstat
    # steam
    # stable.davinci-resolve
    unityhub
    vlc
    nur.repos.nltch.spotify-adblock
    # tor-browser-bundle-bin
    git-credential-oauth
    xsel
    spotdl
    brightnessctl
    # xorg.xev
    # stable.renpy
    ripgrep
    # pipenv
    # python3
    # nodejs
    # gcc
    # llvm
    # vscodium
    # audacity
    # jetbrains-toolbox
    # ryujinx
    # blender
    yt-dlp
    sonobus
    # transmission-gtk
    steam-run
    dotnetCorePackages.sdk_8_0
    # dotnetCorePackages.runtime_8_0
    jetbrains.rider
    tmux-sessionizer
    tmux-create
    tmux-delete
    rebuild
  ];

  # nixpkgs.overlays = [ (final: prev: {
  #     neovim = prev.neovim.override {
  #       configure = {
  #         customRC = ''
  #           if filereadable($HOME . "/.vimrc")
  #             source ~/.vimrc
  #           endif
  #           let $RUST_SRC_PATH = '${stdenv.mkDerivation {
  #             inherit (rustc) src;
  #             inherit (rustc.src) name;
  #             phases = ["unpackPhase" "installPhase"];
  #             installPhase = ''cp -r library $out'';
  #           }}'
  #         '';
  #       };
  #     };
  #   })
  # ];

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };

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
    windowManager.i3 = with { mod = "Mod4"; }; {
      enable = true;
      config = {
        modifier = mod;
        terminal = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux"; # ugly fix but ok
        menu = "i3-dmenu-desktop";
      };
      extraConfig = ''
        workspace "1" output primary

        bindsym ${mod}+Shift+w sticky toggle

        assign [class="Pavucontrol"] 10
        assign [class=".blueman-manager-wrapped"] 10
        #assign [class="Discord"] 4
        #assign [class="vesktop"] 4

        exec ${pkgs.tmux}/bin/tmux start-server # avoid the wait for restoring sessions
        exec pavucontrol
        exec blueman-manager
        #exec vesktop
      '';
    };
  };

  #xdg.configFile."awesome".source = ./config/awesome;
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${path}/config/nvim";
  xdg.configFile."vesktop/themes".source = ./config/vencord-themes;

  # DMZ white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

  home.file.".background-image".source = ./wallpapers;
}
