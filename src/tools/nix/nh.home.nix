{ pkgs, ... }: {
  home.packages = with pkgs; [ nh ];

  programs.nh = {
    enable = true;
    flake = "~/code/nix";
  };
}
