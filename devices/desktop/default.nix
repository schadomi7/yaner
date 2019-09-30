{ config, options, pkgs, ... }:

{

  imports = [
    ../box
    ./pulseaudio.nix
    ./sway/unstable
  ];


  hardware.opengl.enable = true;
  
  hardware.u2f.enable = true;

  programs = {
    chromium.enable = true;
  };

  networking.networkmanager = {
    enable = true;
  };

  users.users.beinke = {
    extraGroups = [ "networkmanager" "video" "audio" ];
    packages = with pkgs; [
      chromium
      python3
      kitty
      alacritty
      mpv
      youtube-dl
    ];
  };

  fonts.fonts = with pkgs; [
    fira-code
    font-awesome-ttf
  ];

  environment.systemPackages = with pkgs; [
    pinentry
    glxinfo
  ];

}
