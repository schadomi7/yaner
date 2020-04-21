{ lib, config, ... }: pkgs:

with pkgs;

# Lists the packages as attribute sets as if you were in
# `<nixpkgs/pkgs/top-level/all-packages.nix>`.
# They will be added to `pkgs` or override the existing ones.
# Of course, packages can depend on each other, as long as there is no cycle.
let

  unstable = import config._module.args.channels."nixos-unstable" {};

  all-hies = import config._module.args.channels."all-hies" { inherit pkgs; };

  yanerpkgs = rec {

    haskell = pkgs.haskell // {
      packageOverrides = self: super:
        ( import ./qbar pkgs self super {} ) // {
        };
    };

    multimc = pkgs.runCommand "multimc" {} ''
      mkdir -p $out/bin
      sed 's|${pkgs.jdk}/bin|${pkgs.openjdk13}/bin|' ${pkgs.multimc}/bin/multimc > $out/bin/multimc
      chmod +x $out/bin/*
    '';

    qbar = haskellPackages.qbar;

    neovim-customized = pkgs.callPackage ./neovim {};

    # redshift-wlr = unstable.redshift-wlr;

    all-hies-latest = all-hies.latest;

  };

in yanerpkgs
