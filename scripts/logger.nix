{
  pkgs,
  my,
}:
pkgs.writeShellScriptBin "logger" ''
  nohup ${
    (pkgs.python3.withPackages (python-pkgs:
      with python-pkgs; [
        isort
        cryptography
        rsa
        pyperclip
        keyboard
      ]))
  }/bin/python /home/${my.username}/projects/logger/main.py
''
