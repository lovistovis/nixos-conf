{pkgs, ...}: {
  programs = {
  };

  home.packages = with pkgs; [
    lshw
  ];
}
