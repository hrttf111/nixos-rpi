{ config, pkgs, lib, ... }:
{
  system.stateVersion = "24.11";

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
  networking.firewall.allowedUDPPorts = [ 631 ];
  networking.firewall.allowedTCPPorts = [ 631 ];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];
  time.timeZone = "Europe/Kiev";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.KbdInteractiveAuthentication = false;
    extraConfig = ''
      AuthenticationMethods password
    '';
  };
  services.udisks2.enable = lib.mkForce false;
  services.dbus.enable = true;
  services.xserver.enable = lib.mkForce false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.userServices = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.splix ];
    browsing = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    defaultShared = true;
    startWhenNeeded = false;
  };

  systemd.services.avahi-daemon.serviceConfig.CapabilityBoundingSet = lib.mkForce [];
  systemd.services.avahi-daemon.serviceConfig.SystemCallFilter = lib.mkForce [];
  systemd.services.avahi-daemon.serviceConfig.SystemCallArchitectures = lib.mkForce "";

  security.audit.enable = lib.mkForce false;
  security.apparmor.enable = lib.mkForce false;

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

  programs.ssh.setXAuthLocation = false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  fonts.fontconfig.enable = false;
}
