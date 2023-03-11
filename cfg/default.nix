{ config, pkgs, lib ? pkgs.lib, ... }:

with lib;

let
  cups-cfg-printers = pkgs.stdenv.mkDerivation {
      pname = "cups-cfg-printers";
      version = "1.0";
      src = ./.;
      unpackPhase = ''
        echo unpack
      '';
      installPhase = ''
        mkdir -p $out
        cp $src/printers.conf $out/
        cp $src/Samsung_ML-191x_252x_Series.ppd $out/
        cp $src/Samsung_ML-1640_Series.ppd $out/
      '';
    };
  cups-cfg-copy = pkgs.writeScriptBin "copy-cups-cfg" ''
    #!${pkgs.bash}/bin/bash
    if [ ! -f /etc/cups/printers.conf ]; then
      cp ${cups-cfg-printers}/printers.conf /etc/cups/
      chown root:lp /etc/cups/printers.conf
      chmod 0600 /etc/cups/printers.conf
    fi
    if [ -z "$(ls /etc/cups/ppd)" ]; then
      cp ${cups-cfg-printers}/*.ppd /etc/cups/ppd/
      chown root:lp /etc/cups/ppd/*
      chmod 0666 /etc/cups/ppd/*
    fi
  '';
in
{
  config = {
    environment.systemPackages = [ cups-cfg-printers cups-cfg-copy ];
    systemd.services.cups-cfg-copy = {
      enable = true;
      description = "Copy CUPS default config";
      wantedBy = [ "default.target" ];
      before = [ "sshd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cups-cfg-copy}/bin/copy-cups-cfg";
        User = "root";
      };
    };
  };
}
