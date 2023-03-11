{ config, pkgs, lib, ... }:
{
  system.stateVersion = "22.11";

  environment.noXlibs = lib.mkForce true;
  environment.defaultPackages = lib.mkForce [];

  environment.systemPackages = with pkgs; [
    ms-sys
    mkpasswd

    vim
    htop
    zip
    unzip
    lz4
    bzip2
    tree
    wget

    file

    ethtool
    dhcpcd
    wpa_supplicant
    tcpdump

    screen
    inetutils

    testdisk
    efibootmgr
    efivar
    parted

    fuse
    fuse3
    sshfs-fuse
    socat

    usbutils

    dosfstools
    mtools
    f2fs-tools
  ];

  networking.hostName = "rpi";
  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];
  time.timeZone = "Europe/Kiev";

  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
    extraConfig = ''
      AuthenticationMethods password
    '';
  };
  services.udisks2.enable = lib.mkForce false;
  services.dbus.enable = true;
  services.xserver.enable = lib.mkForce false;

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.splix ];
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.allowFrom = [ "all" ];
  services.printing.defaultShared = true;

  networking.firewall.allowedUDPPorts = [ 631 ];
  networking.firewall.allowedTCPPorts = [ 631 ];

  users = {
    groups.pi = {
      gid = 1000;
    };
    users.pi = {
      isNormalUser = true;
      uid = 1000;
      hashedPassword = import ./password.nix {};
      home = "/home/pi";
      extraGroups = [ "wheel" "pi" ];
    };
  };

  environment.interactiveShellInit = ''
    export EDITOR=vim
    export TERM=xterm-256color
    export PS1="\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
  '';

  environment.etc."inputrc".text = ''
    "\e[1;5C": forward-word
    "\e[1;5D": backward-word
    "\e[5C": forward-word
    "\e[5D": backward-word
    "\e\e[C": forward-word
    "\e\e[D": backward-word
  '';

  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;

  programs.command-not-found.enable = lib.mkForce false;
}
