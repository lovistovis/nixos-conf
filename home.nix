{ lib, config, pkgs, buildLua, ... }:
let
  path = toString ./.;
  username = import ./username.nix;
  hostname = import ./hostname.nix;
  tmux-sessionizer = import ./scripts/tmux-sessionizer.nix { inherit pkgs; };
  tmux-create = import ./scripts/tmux-create.nix { inherit pkgs; };
  tmux-delete = import ./scripts/tmux-delete.nix { inherit pkgs; };
  rebuild = import ./scripts/rebuild.nix { inherit pkgs path; };
  logger = import ./scripts/logger.nix { inherit pkgs; };
  nixvim = import (fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "main";
  });
  stylix = import (fetchGit {
      url = "https://github.com/nix-community/stylix";
      ref = "master";
  });
  wallpaper = /etc/nixos/wallpaper.png;
  # nixpkgs-master = import
  #   (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/master)
  #   { config = config.nixpkgs.config; };
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
      nixvim.enable = false;
      vesktop.enable = true;
      waybar.enable = true;
      tofi.enable = true;
    };
  };

  programs = {
    mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        uosc
        chapterskip
        mpv-sub-select
        # (callPackage ./pkgs/mpv/mpv-sub-select.nix {})
      ];
      scriptOpts = {
        chapterskip = {
          skip = "Prologue;Opening;Preview";
        };
        sub_select = {
          config = toString ./config/mpv;
        };
      };
      config = {
        alang = "jpn,eng";
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = true;
    };
    hyprlock.enable = true;
    tofi = {
      enable = true;
      settings = with config.lib.stylix.colors.withHashtag; {
        horizontal = lib.mkForce true;
        anchor = lib.mkForce "top";
        width = lib.mkForce "100%";
        height = lib.mkForce 34;

        outline-width = lib.mkForce 0;
        border-width = lib.mkForce 1;
        min-input-width = lib.mkForce 120;
        result-spacing = lib.mkForce 10;

        padding-top = lib.mkForce 8;
        padding-bottom = lib.mkForce 8;

        border-color = lib.mkForce base03;
      };
    };
    nixvim = {
      enable = true;
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
            clangd.enable = true;
            gopls.enable = true;
            pyright.enable = true;
            jdtls.enable = true;
            roslyn.enable = true;
          };
        };
      };
      extraConfigLua = builtins.readFile ./config/nvim/init.lua;
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
        hib = "nohup ${pkgs.hyprlock}/bin/hyprlock > /dev/null 2>&1 & systemctl hibernate";
        ryujinx-portable = "ryujinx -r ~/ryujinx-data";
      };
      history.size = 10000;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
        theme = "robbyrussell";
      };
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
      dotDir = "${config.home.homeDirectory}/.zsh";
    };
    alacritty = {
      enable = true;
      settings = {
        window.opacity = lib.mkForce 0.50;
        colors.primary.background = lib.mkForce "#000000";
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
      settings = {
        user = {
          name = "Love Lysell Berglund";
          email = "love.lysell.berglund@gmail.com";
          signingkey = "7B54D564D46D9880";
        };
        core = {
          editor = "nvim";
        };
        push.autoSetupRemote = true;
        credential.helper = "oauth";
        commit.gpgsign = true;
        tag.gpgSign = true;
      };
      ignores = [
        "**/nixos-switch.log"
        "**/shell.nix"
        "**/.envrc"
        "**/.direnv"
        "**/Session.vim"
        "**/Session.vim.meta"
      ];
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
          userChrome = import ./user-chrome.nix;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            privacy-badger
            darkreader
            sponsorblock
            youtube-shorts-block
          ];
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
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [ "pulseaudio" "network" "temperature" "disk" "memory" "battery" "clock" "tray" ];

          "hyprland/workspaces" = { };

          "hyprland/window" = {
            format = "{title:.100}";
            rewrite = {
              "(.*) — Mozilla Firefox" = "$1";
              "(.*) — Mozilla Firefox Private Browsing" = "$1";
            };
          };

          "network" = {
            interval = 1;
            format = "{ifname}";
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "{ipaddr}/{cidr}";
            format-disconnected = "";
            on-click = "alacritty -e zsh -c 'sudo nmtui'";
          };

          "temperature" = {
            thermal-zone = 1;
            interval = 5;
          };

          "disk" = {
            interval = 5;
            format = "{free} 🖴";
            on-click = "qdirstat";
          };

          "memory" = {
            interval = 5;
            format = "{avail}GiB 🎟";
            on-click = "alacritty -e zsh -c htop";
          };

          "battery" = {
            interval = 5;
            format-full = "{capacity}%";
            format-charging = "{capacity}% {time} chr";
            format-discharging = "{capacity}% {time} bat";
            format-icons = ["" "" "" "" ""];
          };

          "pulseaudio" = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["" "" ""];
            };
            on-click = "pavucontrol";
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

  services = {
    hyprpaper.settings.splash = false;
    mako = {
      enable = true;
      settings = {
        "actionable=true" = {
          anchor = "top-left";
        };
        actions = true;
        anchor = "top-right";
        default-timeout = 2000;
        ignore-timeout = true;
        icons = true;
      };
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
      inherit pkgs;
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
    gnupg
    unzip
    ripgrep
    brightnessctl
    git-credential-oauth

    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      dbus-python
    ]))

    # GUI
    pavucontrol
    qdirstat
    sonobus
    # wineWowPackages.stable
    qbittorrent
    gimp
    vesktop
    unityhub
    spotdl
    steam
    tor-browser
    prismlauncher
    kdePackages.dolphin
    nur.repos.nltch.spotify-adblock
    protonup-qt
    feh
    # davinci-resolve
    # chromium
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
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      "$mod" = "SUPER";
      "$term" = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux";
      "$menu" = "j4-dmenu-desktop --dmenu=${pkgs.tofi}/bin/tofi";
      bind = [
        "$mod, D, exec, $menu"
        "$mod, Return, exec, $term"
        "$mod, F, fullscreen"
        "$mod Shift, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod Shift, Q, killactive"
        "$mod Shift, Space, togglefloating"
        "$mod Shift, W, pin"
        "$mod Shift, E, exit"
        "$mod Ctrl, L, exec, ${pkgs.hyprlock}/bin/hyprlock"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, F3, exec, brightnessctl set 1"
        "$mod, F4, exec, brightnessctl set 100%"
      ]
      ++ (
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
            ]
          )
          10)
       );
      bindel = [
        ", XF86MonBrightnessDown, exec, brightnessctl set 1%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 1%+"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      general = with config.lib.stylix.colors; let
          rgb = color: "rgb(${color})";
        in {
        gaps_out = 10;
        gaps_in = 5;
        "col.active_border" = lib.mkForce (rgb base03);
        "col.inactive_border" = lib.mkForce (rgb base01);
      };
      input = {
        kb_layout = "se";
        touchpad = {
          disable_while_typing = false;
          tap-to-click = true;
          middle_button_emulation = false;
        };
      };
      decoration = {
        blur = {
          enabled = false;
        };
      };
      animations.enabled = false;
      xwayland = {
        force_zero_scaling = true;
      };
      monitor = ", highres, auto, 1";
      env = [
        "GDK_SCALE,1"
        "XCURSOR_SIZE,32"
      ];
      exec-once = [
        "waybar"
        "alacritty -e zsh -c \"tmux a -t ${username}\""
        "firefox"
        "vesktop"
        "pavucontrol"
        "blueman-manager"
        "iwgtk"
        # "steam -silent"
      ];
      # To find window classes use either
      # hyprctl clients | grep class
      # for wayland or
      # wmctrl -lx
      # for xwayland apps.
      windowrule = [
        "match:class firefox, workspace 2 silent"
        "match:class vesktop, workspace 3 silent"
        "match:class org.pulseaudio.pavucontrol, workspace 10 silent"
        "match:class .blueman-manager-wrapped, workspace 10 silent"
        "match:class org.twosheds.iwgtk, workspace 10 silent"

        "match:float true, no_blur on"
      ];
      ecosystem.no_update_news = true;
    };
  };

  xdg.configFile."vesktop/themes".source = ./config/vencord-themes;

  # dMZ white cursor
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
}
