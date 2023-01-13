{ config, options, pkgs, ... }:

{

  imports = [
    ../desktop
  ];

  wat.thelegy.steam.enable = true;

  nixpkgs.config.allowUnfree = true;

  boot.kernel.sysctl = options.boot.kernel.sysctl.default // {
    "fs.inotify.max_user_watches" = 524288;
  };

  environment.systemPackages = [ pkgs.man-pages pkgs.man-pages-posix ];
  documentation.dev.enable = true;

  users.users.beinke = {
    packages = with pkgs; [
      cabal-install
      direnv
      file
      fzf
      git-filter-repo
      git-revise
      kicad-small
      ldns
      libfaketime
      nixpkgs-fmt
      rnix-lsp
      signal-desktop
      sops
      stack
      tdesktop
      thunderbird
      vscode
      mumble
    ];
  };

}
