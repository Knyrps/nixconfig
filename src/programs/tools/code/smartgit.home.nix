{ pkgs, ... }:

{
  home.packages = [
    (pkgs.smartgit.overrideAttrs (old: {
      src = old.src.overrideAttrs (_: {
        outputHash = "sha256-2KjUNabcN56cIBORN++YZlx2JuiuN/JMEDVjHo0wqw8=";
      });
    }))
  ];
}
