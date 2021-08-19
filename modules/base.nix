{ lib, config, pkgs, mkTrivialModule, ... }:
with lib;

mkTrivialModule {
  boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

  # Restore systemd default
  services.logind.killUserProcesses = mkDefault true;

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1-nodeadkeys";
    # Gruvbox tty colors
    colors = [ "000000" "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" "a89984" "928374" "fb4934" "b8bb26" "fabd2f" "83a598" "d3869b" "8ec07c" "ebdbb2" ];
  };
  time.timeZone = "Europe/Berlin";

  boot.tmpOnTmpfs = true;

  services = {
    dbus.enable = true;
    acpid.enable = true;
    avahi.enable = true;
  };

  services.openssh = {
    enable = mkDefault true;
    passwordAuthentication = mkDefault false;
    challengeResponseAuthentication = mkDefault false;
  };

  programs = {
    less.enable = true;
    mtr.enable = true;
    tmux.enable = true;
  };

  programs.zsh = {
    enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    shellInit = ''
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };

  environment.shellInit = ''
    PATH=~/.local/bin:$PATH
    export PATH
  '';

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
    packages = with pkgs; [
      xdg_utils
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCC4cFL1xcZOsIzXg1b/M4b89ofMKErNhg9s+0NdBVC beinke@th1"
  ];

  nix.autoOptimiseStore = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.package = pkgs.nixUnstable;

  environment.systemPackages = with pkgs; [
    git
    gnupg
    htop
    inxi-full
    kitty.terminfo
    lm_sensors
    magic-wormhole
    neovim-queezle
    reptyr
    ripgrep
    tig
  ];
}
