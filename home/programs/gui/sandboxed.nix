# GUI apps sandboxed with nixpak (see ../../lib/sandbox.nix): minimal permissions per app
{
  inputs,
  pkgs,
  ...
}: let
  mkSandbox = import ../../lib/sandbox.nix {inherit inputs pkgs;};
  inHome = sloth: map (d: sloth.concat' sloth.homeDir "/${d}");

  # No network, no D-Bus, reads the user dirs, writes only its own state
  vlc = mkSandbox.wrap {
    package = pkgs.vlc;
    gui = true;
    config = {sloth, ...}: {
      flatpak = {
        appId = "org.videolan.VLC";
        desktopFile = "vlc.desktop";
      };
      bubblewrap = {
        bind.ro = inHome sloth ["Cyber" "Documents" "Downloads" "Music" "Pictures" "Videos"];
        bind.rw = inHome sloth [".config/vlc" ".local/share/vlc" ".cache/vlc"];
        sockets = {
          pipewire = true;
          pulse = true;
        };
      };
    };
  };

  # Network, its own data, Documents and Downloads (attachments)
  signal = mkSandbox.wrap {
    package = pkgs.signal-desktop;
    gui = true;
    config = {sloth, ...}: {
      dbus = {
        enable = true;
        policies = {
          "org.freedesktop.Notifications" = "talk";
          "org.freedesktop.secrets" = "talk"; # database key, stored in the keyring
          # Tray icon: Signal starts minimized to the tray, without it the window can't be reopened
          "org.kde.StatusNotifierWatcher" = "talk";
          "org.kde.*" = "own";
        };
      };
      bubblewrap = {
        network = true;
        bind.rw = inHome sloth [".config/Signal" "Documents" "Downloads"];
        sockets = {
          pipewire = true; # calls, voice notes
          pulse = true;
        };
        # Webcam for video calls (Chromium opens the V4L2 devices directly)
        bind.dev = ["/dev/video0" "/dev/video1" "/dev/video2" "/dev/video3"];
        bind.ro = ["/sys/class/video4linux"];
      };
    };
  };

  # Network (community plugins), only its config and ~/Notes
  obsidian = mkSandbox.wrap {
    package = pkgs.obsidian;
    gui = true;
    config = {sloth, ...}: {
      dbus.enable = true; # portal: links, file chooser
      bubblewrap = {
        network = true;
        bind.rw = inHome sloth [".config/obsidian" "Notes"];
      };
    };
  };

  # No network, ~/Pictures, anything else through the file chooser
  pinta = mkSandbox.wrap {
    package = pkgs.pinta;
    gui = true;
    config = {sloth, ...}: {
      flatpak.appId = "com.github.PintaProject.Pinta"; # = its .desktop ID, for files handed over by the portal
      dbus.enable = true; # portal: file chooser
      bubblewrap.bind.rw = inHome sloth [".config/Pinta" "Pictures"];
    };
  };
  # Folders readable by apps that open documents (same list as the XDG user dirs)
  userDirs = ["Cyber" "Desktop" "Documents" "Downloads" "Music" "Notes" "Pictures" "Projects" "Videos"];

  # No network, no D-Bus, reads the user dirs, writes only its history and bookmarks.
  # No D-Bus means no vimtex synctex backward search from the viewer.
  zathura = mkSandbox.wrap {
    package = pkgs.zathura;
    gui = true;
    config = {sloth, ...}: {
      flatpak = {
        appId = "org.pwmt.zathura";
        desktopFile = "org.pwmt.zathura.desktop";
      };
      bubblewrap = {
        bind.ro = inHome sloth userDirs;
        bind.rw = inHome sloth [".local/share/zathura"];
      };
    };
  };

  # nixpak can't rewrite libreoffice's bin/* (symlinks into lib/): wrap a real executable instead.
  # Only `libreoffice` is exposed, so swriter & co can't bypass the sandbox.
  libreofficeEntry =
    pkgs.runCommand "libreoffice-entry" {
      meta.mainProgram = "libreoffice";
    } ''
      mkdir -p $out/bin $out/share
      printf '#!${pkgs.runtimeShell}\nexec ${pkgs.libreoffice}/bin/libreoffice "$@"\n' > $out/bin/libreoffice
      chmod +x $out/bin/libreoffice
      cp -rL ${pkgs.libreoffice}/share/applications ${pkgs.libreoffice}/share/icons $out/share/
    '';

  # No network, no D-Bus, reads the user dirs, writes ~/Documents and ~/Downloads
  libreoffice = mkSandbox.wrap {
    package = libreofficeEntry;
    gui = true;
    config = {sloth, ...}: {
      flatpak.appId = "org.libreoffice.LibreOffice";
      bubblewrap = {
        bind.ro = inHome sloth (builtins.filter (d: d != "Documents" && d != "Downloads") userDirs);
        bind.rw = inHome sloth [".config/libreoffice" "Documents" "Downloads"];
      };
    };
  };

  # Network, audio, webcam, screen sharing (portal + PipeWire), its own data, ~/Downloads
  discord = mkSandbox.wrap {
    package = pkgs.discord;
    gui = true;
    config = {sloth, ...}: {
      dbus = {
        enable = true;
        policies = {
          "org.freedesktop.Notifications" = "talk";
          "org.freedesktop.secrets" = "talk";
          # Tray icon
          "org.kde.StatusNotifierWatcher" = "talk";
          "org.kde.*" = "own";
        };
      };
      bubblewrap = {
        network = true;
        bind.rw = inHome sloth [".config/discord" "Downloads"];
        bind.ro = inHome sloth ["Documents" "Pictures" "Videos"] ++ ["/sys/class/video4linux"]; # attachments, webcam
        sockets = {
          pipewire = true; # voice, screen sharing
          pulse = true;
        };
        bind.dev = ["/dev/video0" "/dev/video1" "/dev/video2" "/dev/video3"];
      };
    };
  };
in {
  home.packages = [vlc signal obsidian pinta zathura libreoffice discord];

  # Bind sources must exist before the sandbox starts
  systemd.user.tmpfiles.rules = [
    "d %h/.config/vlc 0700 - - -"
    "d %h/.local/share/vlc 0700 - - -"
    "d %h/.cache/vlc 0700 - - -"
    "d %h/.config/Signal 0700 - - -"
    "d %h/.config/obsidian 0700 - - -"
    "d %h/.config/Pinta 0700 - - -"
    "d %h/.local/share/zathura 0700 - - -"
    "d %h/.config/libreoffice 0700 - - -"
    "d %h/.config/discord 0700 - - -"
    "d %h/Notes 0755 - - -"
  ];
}
