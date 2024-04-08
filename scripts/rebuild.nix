{
  pkgs,
  path,
}:
pkgs.writeShellScriptBin "rebuild" ''
  set -e
  pushd ${path}
  ${pkgs.neovim}/bin/nvim .
  ${pkgs.git}/bin/git add .
  ${pkgs.alejandra}/bin/alejandra . &>/dev/null
  ${pkgs.git}/bin/git diff -U0 *.nix
  echo "NixOS Rebuilding..."
  sudo nixos-rebuild switch &>nixos-switch.log || (
   cat nixos-switch.log | grep --color error && false)
  gen=$(nixos-rebuild list-generations | grep current)
  ${pkgs.git}/bin/git commit -am "$gen"
  popd
''
