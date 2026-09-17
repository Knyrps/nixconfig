{ pkgs, inputs, ... }:

{
  home.packages = [
    pkgs.streamcontroller
  ];

  xdg.dataFile."StreamController/plugins/DiscordSC".source = inputs.discord-sc;
}
