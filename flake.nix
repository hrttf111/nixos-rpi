{
  inputs = rec {
    nixpkgs.url = "nixpkgs/nixos-22.11";
  };
  outputs = { self, nixpkgs, ... }: let
    pkgs_x86 = import nixpkgs {
      system = "x86_64-linux";
    };
    formatModule = { config, lib, pkgs, modulesPath, ... }: let
      i = import "${toString modulesPath}/../modules/installer/sd-card/sd-image.nix" {
        inherit lib config pkgs;
      };
    in i;
    crossModule = {config, pkgs, lib, ...}:
    let
      appOverlay = pkgs_x86.callPackage ./overlay.nix { inherit pkgs_x86; };
      allowMissingKernelModules = (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      });
    in {
      nixpkgs = {
          config.allowUnsupportedSystem = false;
          overlays = [ allowMissingKernelModules appOverlay ];
          crossSystem = lib.systems.examples.raspberryPi;
          localSystem = { system = "x86_64-linux"; };
        };
      };
  in rec {
    nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
      system = "armv6l-unknown-linux-gnueabihf";
      modules = [
        crossModule
        formatModule
        ./cfg
        ./configuration-sd.nix
        ./configuration.nix
        ./configuration-network.nix
      ];
    };
    sd-card = nixosConfigurations.rpi.config.system.build.sdImage;
  };
}
