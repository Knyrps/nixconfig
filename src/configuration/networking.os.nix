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

    # TODO: find a place for this
    extraHosts = "192.168.2.210 DE-S6N0CX038986239 DE-0CX038986239";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
}
