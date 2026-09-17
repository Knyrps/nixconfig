{ ... }:

{
  # battery status
  services.upower = {enable = true;};

  # power plan
  services.power-profiles-daemon = {enable = true;};

  environment.variables.EDITOR = "nano";
}
