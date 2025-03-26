{ pkgs }:
pkgs.writeShellScriptBin "logger" ''
nohup ${
  (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
    isort
    cryptography
    rsa
    pyperclip
    keyboard
  ]))
}/bin/python /home/mogos/projects/logger/main.py
''
