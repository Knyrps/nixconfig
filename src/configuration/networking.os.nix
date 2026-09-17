{ ... }:

{
  hardware = {
    bluetooth = {
      enable = true;
    };
  };

  networking = {
    # never set hostname here!
    networkmanager = {
      enable = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}
