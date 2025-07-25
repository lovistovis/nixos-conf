{ lib, config, pkgs, ... }:
let
  path = builtins.toString ./.;
  username = import ./username.nix;
  hostname = import ./hostname.nix;
  tmux-sessionizer = import ./scripts/tmux-sessionizer.nix { inherit pkgs; };
  tmux-create = import ./scripts/tmux-create.nix { inherit pkgs; };
  tmux-delete = import ./scripts/tmux-delete.nix { inherit pkgs; };
  rebuild = import ./scripts/rebuild.nix { inherit pkgs path; };
  logger = import ./scripts/logger.nix { inherit pkgs; };
  # stable = import <nixos-stable> { config = { allowUnfree = true; }; };
  nixvim = import (builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "nixos-${import ./version.nix}";
  });
  stylix = import (builtins.fetchGit {
      url = "https://github.com/danth/stylix";
      ref = "release-${import ./version.nix}";
  });
  wallpaper = ./wallpapers/landscape.jpg;
in {
  imports = [
    nixvim.homeModules.nixvim
    (import stylix).homeModules.stylix
  ];

  stylix = {
    enable = true;
    image = wallpaper;
    polarity = "dark";
    targets = {
      firefox = {
        enable = true;
        profileNames = [ "${username}" ];
      };
      nixvim = {
        enable = true;
      };
      vesktop = {
        enable = true;
      };
    };
  };

  programs = {
    nixvim = {
      enable = true;
      # colorschemes.tokyonight.enable = true;
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        have_nerd_font = false;
      };
      plugins = {
        none-ls = {
          sources = {
            diagnostics = {
              golangci_lint.enable = true;
            };
            formatting = {
              gofmt.enable = true;
            };
          };
        };
        lsp = {
          enable = true;
          servers = {
            gopls.enable = true;
            pyright.enable = true;
          };
        };
      };
      extraConfigLua = (builtins.readFile ./config/nvim/init.lua);
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        update = "sudo nixos-rebuild switch";
        fupdate = "sudo nixos-rebuild switch --fast";
        upgrade = "sudo nix-channel --update; update";
        clean = "nix-collect-garbage --delete-older-than 1d; sudo nix-collect-garbage --delete-older-than 1d";
        clean-hard = "nix-collect-garbage --delete-old; sudo nix-collect-garbage --delete-old";
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
      # prezto = {
      #   enable = true;
      #   python.virtualenvAutoSwitch = true;
      #   python.virtualenvInitialize = true;
      # };
      plugins = [
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
      # initExtra = ''
      #   function shellExit {
      #     tmux-store save
      #   }
      #   trap shellExit EXIT
      # '';
    };
    alacritty = {
      enable = true;
      settings = {
        window.opacity = lib.mkForce 0.97;
        # shell = { program = "${pkgs.zsh}/bin/zsh"; args = [ "-c tmux" ]; };
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
            # set -g @resurrect-strategy-nvim 'session'
            # set -g @resurrect-processes '"~nvim->nvim *"'

            run '${auto-restore}/bin/auto-restore'

            set-hook -g 'client-detached' "run-shell ${tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh" # auto save

            # resurrect_dir="$(show resurrect-dir)"
            # resurrect_dir="$HOME/.tmux/resurrect"
            # set -g @resurrect-dir $resurrect_dir
            # set -g @resurrect-hook-post-save-all 'sed -i "s/*nvim/nvim/" $resurrect_dir/last'
            # show -g @resurrect-dir
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            # set -g @continuum-restore 'on'
            # set -g @continuum-save-interval '20' # minutes
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
        "**/Session.vim.meta"
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
          # "*".installation_mode = "blocked";
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
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
        "${username}" = {
          id = 0;
          isDefault = true;

          # TODO: add nix search engines defined at nixos wiki firefox

          userChrome = import ./user-chrome.nix;
        };
      };
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
      ];
    };
    waybar = {
      enable = true;
      style = lib.mkAfter ''
        * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-size: 12px;
        }

        #workspaces button {
          background: transparent;
          min-width: 9px;
        }

        #workspaces button.focused {
          background: @base0D;
        }

        #workspaces button.urgent {
          background: @base0E;
        }
      '';
      settings = {
        mainBar = {
          layer = "top";
          position = "bottom";
          height = 10;
          modules-left = [ "sway/workspaces" "sway/mode" ];
          # modules-center = [ "sway/window" ];
          modules-right = [ "network" "disk" "memory" "temperature" "battery" "clock" "tray" ];

          "sway/workspaces" = {
            disable-scroll = true;
            disable-mouse = true;
            all-outputs = true;
          };

          "network" = {
            interval = 1;
            format = "{ifname}";
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "{ipaddr}/{cidr}";
            format-disconnected = "";
          };

          "disk" = {
            interval = 5;
            format = "{free}";
          };

          "memory" = {
            interval = 5;
            format = "{avail}GiB";
          };

          "temperature" = {
            thermal-zone = 1;
            interval = 5;
          };

          "battery" = {
            interval = 5;
            format-charging = "{capacity}% {time} chr";
            format-discharging = "{capacity}% {time} bat";
            format-full = "{capacity}% max";
          };

          "clock" = {
            interval = 1;
            tooltip = true;
            format = "{:%H:%M:%S}";
            tooltip-format = "{:%Y-%m-%d}";
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    # Scripts
    tmux-sessionizer
    tmux-create
    tmux-delete
    rebuild
    logger

    # System
    go
    gcc
    dbus
    tree
    tmux
    unzip
    ripgrep
    brightnessctl
    git-credential-oauth

    # GUI
    pavucontrol
    qdirstat
    sonobus
    wineWowPackages.stable
    qbittorrent
    gimp
    vlc
    vesktop
    unityhub
    spotdl
    steam
    tor-browser
    # chromium
    # nur.repos.nltch.spotify-adblock
    # opentoonz
    # jetbrains.rider
    # dotnetCorePackages.dotnet_9.sdk
    # dotnetCorePackages.dotnet_9.aspnetcore
    # dotnetCorePackages.dotnet_9.runtime
    # powershell
  ];

  home.sessionVariables = rec {
    EDITOR = "nvim";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "${BROWSER}";
    TERMINAL = "alacritty";
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-decoration-layout = "menu:";
    # theme = {
    #   name = "Tokyonight-Dark-B";
    #   package = pkgs.tokyo-night-gtk;
    # };
    # iconTheme = {
    #   name = "Tokyonight-Dark";
    # };
    # cursorTheme = {
    #   name = gtkCursorTheme;
    #   package = pkgs.bibata-cursors;
    # };
  };

  wayland.windowManager.sway = with {
      mod = "Mod4";
      term = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux"; }; {
    enable = true;
    config = {
      modifier = mod;
      terminal = term;
      menu = "j4-dmenu-desktop";
      input = {
        "*" = {
          xkb_layout = "se";
        };
        "type:touchpad" = {
          dwt = "disabled";
          tap = "enabled";
          middle_emulation = "enabled";
        };
      };
      bars = [
        {
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];
      # How to override colors:
      # colors = {
      #   unfocused = with config.lib.stylix.colors.withHashtag; {
      #     border = lib.mkForce base0A;
      #     childBorder = lib.mkForce base0A;
      #   };
      # };
    };
    extraConfig = ''
      workspace "1" output primary

      gaps inner 5

      bindsym ${mod}+Shift+w sticky toggle

      bindsym ${mod}+Shift+s exec 'grim -g "$(slurp)" - | wl-copy'

      bindsym ${mod}+Control+l exec 'swaylock --image ${wallpaper}'

      # Brightness
      bindsym XF86MonBrightnessDown exec 'brightnessctl set 1%-'
      bindsym ${mod}+F3 exec 'brightnessctl set 1'
      bindsym XF86MonBrightnessUp exec 'brightnessctl set +1%'
      bindsym ${mod}+F4 exec 'brightnessctl set 100%'

      # Volume
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'

      # To find window class ids use either
      # swaymsg -t get_tree | grep app_id
      # for wayland or
      # wmctrl -lx
      # for xwayland apps. Use "app_id" for
      # wayland apps and "class" for xwayland apps

      assign [app_id="firefox"] 2
      assign [class="vesktop"] 3
      assign [app_id="org.pulseaudio.pavucontrol"] 10
      assign [app_id=".blueman-manager-wrapped"] 10

      # exec ${pkgs.tmux}/bin/tmux start-server # avoid the wait for restoring sessions
      exec --no-startup-id swaymsg 'workspace 1; exec --no-startup-id ${term}'
      exec --no-startup-id firefox
      exec --no-startup-id vesktop
      exec --no-startup-id pavucontrol
      exec --no-startup-id blueman-manager
    '';
  };

  # xdg.configFile."awesome".source = ./config/awesome;
  # xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${path}/config/nvim";
  # TODO: xdg.configFile."vesktop/themes".source = ./config/vencord-themes;

  # DMZ white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

  # home.file.".background-image".source = ./wallpapers;
}
