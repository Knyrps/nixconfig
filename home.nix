{ config, pkgs, lib, ... }:

{
  imports = lib.filter
    (path: lib.hasSuffix ".home.nix" (toString path))
    (lib.filesystem.listFilesRecursive ./src);

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";

  # TODO: Custom Clipboard History Tool
  # services.cliphist = {enable = true;};

  programs.kitty = {enable = true;};

  programs.nushell = {enable = true;};

  programs.zed-editor = {
    enable = true;
  };

  services.playerctld.enable = true;

  home.packages = with pkgs; [
    git
    vim
    alacritty
    vesktop
    whatsapp-electron
    grim
    slurp
    satty
    wl-clipboard
    libnotify
    nautilus
    nil
    nixd
    wev
    pciutils
    jq

    (writeShellScriptBin "zed" ''
        exec ${config.programs.zed-editor.package}/bin/zeditor --add "$@"
    '')
  ];

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
