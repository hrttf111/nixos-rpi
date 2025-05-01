{ lib, fetchurl, fetchFromGitHub, fetchpatch, pkgs_x86, callPackage }:
self: super: {
  cups-filters = super.cups-filters.overrideAttrs (oldAttrs: rec {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-cups-config=${super.cups.dev}/bin/cups-config" ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs_x86.pkg-config super.glib.dev ];
    buildInputs = oldAttrs.buildInputs ++ [ super.cups.dev ];
  });
  splix = super.splix.overrideAttrs (oldAttrs: rec {
    nativeBuildInputs = [ super.cups.dev ];
    buildInputs = oldAttrs.buildInputs ++ [ super.cups.dev ];
    postPatch = oldAttrs.postPatch + ''

      substituteInPlace Makefile \
        --replace 'gcc' $CC \
        --replace 'g++' $CXX

      substituteInPlace rules.mk \
        --replace 'g++' $CXX \
    '';
  });
  efivar = super.efivar.overrideAttrs (oldAttrs: rec {
    CFLAGS = "-Og  -g3 -Wall -Wextra  -std=gnu11";
    NIX_CFLAGS_COMPILE = "-Og  -g3 -Wall -Wextra  -std=gnu11";
  });
  poppler = super.poppler.overrideAttrs (oldAttrs: rec {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs_x86.pkg-config pkgs_x86.glib.dev ];
  });
  pixman = super.pixman.overrideAttrs (oldAttrs: rec {
    pname = "pixman";
    version = "0.44.2";
    src = fetchurl {
      urls = [
        "mirror://xorg/individual/lib/${pname}-${version}.tar.gz"
        "https://cairographics.org/releases/${pname}-${version}.tar.gz"
      ];
      hash = "sha256-Y0kGHOGjOKtpUrkhlNGwN3RyJEII1H/yW++G/HGXNGY=";
    };
    mesonFlags = [];
  });
  ubootRaspberryPi = super.ubootRaspberryPi.overrideAttrs (oldAttrs: rec {
    version = "2022.10";
    src = fetchurl {
      url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
      hash = "sha256-ULRIKlBbwoG6hHDDmaPCbhReKbI1ALw1xQ3r1/pGvfg=";
    };
    patches = [];
  });
  raspberrypifw = super.raspberrypifw.overrideAttrs (oldAttrs: rec {
    version = "1.20221028";
    src = fetchFromGitHub {
      owner = "raspberrypi";
      repo = "firmware";
      rev = version;
      hash = "sha256-GgPAWFCrLrrLiUDM+pt3VV6+IvCljMN9nh7L84vTQJs=";
    };
  });
  linuxKernel = let
    kernelPatches = super.callPackage "${toString super.path}/pkgs/os-specific/linux/kernel/patches.nix" { };
    kernel_6_6_31 = super.callPackage "${toString super.path}/pkgs/os-specific/linux/kernel/linux-rpi.nix" {
      rpiVersion = 1;
      kernelPatches = [
        kernelPatches.bridge_stp_helper
        kernelPatches.request_key_helper
        { name = "fix_kernel.patch"; patch = ./fix_kernel.patch; }
      ];
      argsOverride = rec {
        tag = "stable_20240529";
        src = fetchFromGitHub {
          owner = "raspberrypi";
          repo = "linux";
          rev = tag;
          hash = "sha256-UWUTeCpEN7dlFSQjog6S3HyEWCCnaqiUqV5KxCjYink=";
        };
        modDirVersion = "6.6.31";
        version = "${modDirVersion}-${tag}";
      };
    };
    kernel_6_6_74 = super.callPackage "${toString super.path}/pkgs/os-specific/linux/kernel/linux-rpi.nix" {
      rpiVersion = 1;
      argsOverride = rec {
        tag = "stable_20250127";
        src = fetchFromGitHub {
          owner = "raspberrypi";
          repo = "linux";
          rev = tag;
          hash = "sha256-17PrkPUGBKU+nO40OP+O9dzZeCfRPlKnnk/PJOGamU8=";
        };
        modDirVersion = "6.6.74";
        version = "${modDirVersion}-${tag}";
        kernelPatches = [
          { name = "fix_kernel.patch"; patch = ./fix_kernel.patch; }
        ];
      };
    };
    in
    super.linuxKernel // {
      packages = super.linuxKernel.packages // {
        linux_rpi1_6_6_31 = super.linuxKernel.packagesFor kernel_6_6_31;
        linux_rpi1_6_6_74 = super.linuxKernel.packagesFor kernel_6_6_74;
      };
    };
}
