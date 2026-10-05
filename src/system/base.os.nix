{ ... }:

{
  environment.variables.EDITOR = "nano";

  # ~700 MB, screen readers only
  services.speechd.enable = false;
}
