{ config, lib, pkgs, ... }:

let
  cfg = config.features.vim;
in
{
  options.features.vim.enable = lib.mkEnableOption "vim" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.vim ];
  };
}
