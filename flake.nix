{
  nixConfig = {
    extra-substituters = [ "https://cache.soopy.moe" ];
    extra-trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
  };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discord-sc = {
      url = "github:oparada1988/DiscordSC";
      flake = false;
    };
    t2fanrd = {
      url = "github:GnomedDev/T2FanRD";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:soopyc/nixos-hardware/apple-t2-updates";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, t2fanrd, ... }@inputs:
  let
    mkHost = name: extraModules: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${name}/configuration.nix
        ./core.nix
        { networking.hostName = name; }
        { nixpkgs.overlays = [ inputs.nur.overlays.default ]; }
        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.knyrps.imports = [ ./home.nix ]
              ++ nixpkgs.lib.optional (builtins.pathExists ./hosts/${name}/home.nix) ./hosts/${name}/home.nix;
            backupFileExtension = "hm-bak";
          };
        }
      ] ++ extraModules;
    };
  in {
    nixosConfigurations = {
      knyrps-precision = mkHost "knyrps-precision" [ ];
      knyrps-mbp       = mkHost "knyrps-mbp" [
        nixos-hardware.nixosModules.apple-t2
        t2fanrd.nixosModules.t2fanrd
      ];
      headless         = mkHost "headless" [ ];
    };
  };
}
