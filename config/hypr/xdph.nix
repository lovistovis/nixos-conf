{pkgs}:
with {
  share-picker-cached = import ../../scripts/share-picker-cached.nix {
    inherit pkgs;
  };
} in ''
  screencopy {
      # Keep OFF — see Failure 3.
      allow_token_by_default = false

      # Dedupe the picker: Chromium/Electron opens several portal sessions per
      # share and each pops a dialog; the wrapper replays the first selection.
      custom_picker_binary = ${share-picker-cached}/bin/share-picker-cached
  }
''
