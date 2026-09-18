{ pkgs, ... }: {
  home.packages = with pkgs; [ nh ];

  programs.nh = {
    enable = true;
  };
}
