{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  i18n.consoleKeyMap = "de-latin1-nodeadkeys";
  time.timeZone = "Europe/Berlin";

  boot.tmpOnTmpfs = true;

  services = {
    openssh.enable = true;
    dbus.enable    = true;
    acpid.enable   = true;
    avahi.enable   = true;
  };

  programs = {
    less.enable = true;
    mtr.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };

  users.mutableUsers = false;
  users.users.beinke = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$rounds=424242$4XeOOipFMr154yFt$duKTFu2mSR9LnrGILjgumlxl8FltvCo9RBjhWi1N56avEVaAJym3LFlw3y2.JMCVYAO2ZpK75eF7B/7cSu5rR0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCC4cFL1xcZOsIzXg1b/M4b89ofMKErNhg9s+0NdBVC beinke@th1"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCC4cFL1xcZOsIzXg1b/M4b89ofMKErNhg9s+0NdBVC beinke@th1"
  ];

  nix.autoOptimiseStore = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    tig
    gnupg
    inxi
    lm_sensors
    dmidecode
  ];
}
