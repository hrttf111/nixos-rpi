# nixos-rpi

This repo contains nix derivation which builds Nixos for RaspberryPi 1 (the very first RPI). An SD card image is a result of build. The main purpose of this image is to serve as a print server. Overall project can be used to build Nixos images with arbitrary functionality, limited only by RPI HW.

## flake

Currently flake exposes only a single output - SD image ("./#sd-card").

## Makefile

Makefile contains usefull scripts. Which allow to build SD image and write it to SD card.
REVIEW Makefile before using it!

## Password

Password hash for default user ("pi") is in file "password.nix". Default password is "raspberry". New default password can be generated manually or by deleting "password.nix" and running "make". See Makefile for details.

## configuration-network.nix

This file is supposed to contain network configuration. Since configuration is user-specific, it may contain sensitive data (for example, passwords) or additional network interfaces (USB WIFI dongles), it is empty by default.

## cfg

This directoy contains sample printing configuration and systemd daemon which copies it to CUPS after reboot. Once SD image is built for the first time, it is required to boot it once and then reboot for default CUPS printing config to be applied.

## overlay.nix

Some packages cannot be build by default, overlay.nix contains fixes for them.
