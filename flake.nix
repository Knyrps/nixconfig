{
  nixConfig = {
    extra-substituters = [ "https://cache.soopy.moe" "https://noctalia.cachix.org" "https://niri.cachix.org" ];
    extra-trusted-public-keys = [
      "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # niri WM module + package + binary cache. No nixpkgs.follows on purpose:
    # its cache is built against niri-flake's own pinned nixpkgs, so following
    # ours would miss the cache and compile niri from source.
    niri.url = "github:sodiboo/niri-flake";
    discord-sc = {
      url = "github:oparada1988/DiscordSC";
      flake = false;
    };
    t2fanrd = {
      url = "github:GnomedDev/T2FanRD";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:soopyc/nixos-hardware/apple-t2-updates";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    material-theme = {
      url = "github:kuska1/Material-Theme";
      flake = false;
    };
    repo = {
      url = "github:knyrps/repo";
      flake = false;
    };
    # local tiny-dfr fork with the animated touch bar seascape
    tiny-dfr = {
      url = "git+file:///home/knyrps/code/tiny-dfr?ref=oceanwaves";
      flake = false;
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # The one thing that isn't in stable nixpkgs. No nixpkgs.follows on purpose:
    # that keeps Noctalia's own (unstable) nixpkgs so its cachix cache hits.
    noctalia.url = "github:noctalia-dev/noctalia";
    # Greeter is a separate flake (stable nixpkgs has no noctalia-greeter
    # module). Share Noctalia's unstable nixpkgs rather than pull a third.
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "noctalia/nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, t2fanrd, ... }@inputs:
  let
    mkHost = name: extraModules: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${name}/configuration.nix
        ./core.nix
        { networking.hostName = name; }
        # overlay (not the flake's prebuilt packages) so addons inherit the
        # system's nixpkgs.config — notably allowUnfree for e.g. tampermonkey.
        { nixpkgs.overlays = [ inputs.firefox-addons.overlays.default ]; }
        inputs.niri.nixosModules.niri
        inputs.noctalia-greeter.nixosModules.default
        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.knyrps.imports = [ ./home.nix inputs.noctalia.homeModules.default ]
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
      wsl              = mkHost "wsl" [ inputs.nixos-wsl.nixosModules.default ];
    };
  };
}
