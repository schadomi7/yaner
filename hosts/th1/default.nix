{ config, options, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../templates/laptop
  ];


  # Fix the LTE modem not being detected
  systemd.services."network-manager".requires = [ "modem-manager.service" ];

  users.users.beinke.packages = with pkgs; [
    bc  # For my battery script i use for my sway bar
  ];

  hardware.cpu.intel.updateMicrocode = true;


  networking.hostName = "th1";

  system.stateVersion = "19.03";

}
