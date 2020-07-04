# entry point for machine configurations:
# (import <repo-path>).<netname>.configurations.<hostname>

with builtins;
let

  # helpers :: { *: ? }
  helpers = import ./helpers.nix;

  # machinesDir :: path
  machinesDir = ./machines;

  # machineNames :: [ string ]
  machineNames = with helpers; (readFilterDir (filterAnd [(not filterDirHidden) filterDirDirs]) machinesDir);

  # extraModules :: [ path ]
  extraModules = with helpers; map (module: ./modules + "/${module}") (readFilterDir (not filterDirHidden) ./modules);

  # channelsDir :: path
  channelsDir = ./channels;

  # allChannels :: { *: path }
  allChannels = with helpers; keysToAttrs (channelname: import (channelsDir + "/${channelname}") channelname) (readFilterDir (filterAnd [(not filterDirHidden) filterDirDirs]) channelsDir);

  # mkMachineChannel :: string -> path
  mkMachineChannel = name:
    (import (machinesDir + "/${name}/channel.nix")) allChannels;

  # machineChannels :: { *: path }
  machineChannels = helpers.keysToAttrs mkMachineChannel machineNames;

  # mkMachineArchitecture :: string -> string
  mkMachineArchitecture = name: with helpers;
    maybe "x86_64-linux" id (tryImport (machinesDir + "/${name}/system.nix"));

  # machineArchitectures :: { *: string }
  machineArchitectures = helpers.keysToAttrs mkMachineArchitecture machineNames;

  # mkMachineConfig :: string -> system_configuration
  mkMachineConfig = with helpers; name: { isIso ? false }:
    let
      path = machinesDir + "/${name}";
      machineConfigs = foldl' (x: y: x ++ maybeToList (toExistingPath y)) [] [
        (path + "/configuration.nix")
        (path + "/hardware-configuration.nix")
      ];
    in { pkgs, config, lib, ... }:

    {
      imports = machineConfigs ++ extraModules;

      _module.args.helpers = helpers;
      _module.args.channels = allChannels;
      _module.args.isIso = isIso;

      nixpkgs.config = {
        packageOverrides = (import ./pkgs/all-packages.nix) { inherit lib config; };
      };

      nix.nixPath = [ "nixpkgs=${machineChannels.${name}}" ];

      networking.hostName = lib.mkDefault name;

    };

  # mkMachineSystemDerivation :: string -> system_derivation
  mkMachineSystemDerivation = name:
    let
      channel = channels.${name};
      configuration = configurations.${name} {};
    in (import "${channel}/nixos" {
      system = machineArchitectures.${name};
      configuration = configuration;
    }).system;

  # mkMachineIsoDerivation :: string -> iso_derivation
  mkMachineIsoDerivation = name:
    let
      channel = channels.${name};
      configuration = { config, ... }:
      {
        imports = [
          (configurations.${name} { isIso = true; })
          <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
          <nixpkgs/nixos/modules/profiles/all-hardware.nix>
          <nixpkgs/nixos/modules/profiles/base.nix>
        ];
        isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-isohost-${name}.iso";
        isoImage.volumeID = substring 0 11 "NIXOS_ISO";
        isoImage.makeEfiBootable = true;
        isoImage.makeUsbBootable = true;
        boot.loader.grub.memtest86.enable = true;
      };
    in (import "${channel}/nixos" {
      system = machineArchitectures.${name};
      configuration = configuration;
    }).config.system.build.isoImage;

  # mkMachineSDCardDerivation :: string -> sdcard_derivation
  mkMachineSDCardDerivation = name:
    let
      channel = channels.${name};
      configuration = { config, ... }:
      {
        imports = [
          (configurations.${name} { isIso = true; })
          <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
          <nixpkgs/nixos/modules/profiles/all-hardware.nix>
          <nixpkgs/nixos/modules/profiles/base.nix>
        ];
        sdImage.populateRootCommands = "";
        sdImage.populateFirmwareCommands = "";
        boot.loader.grub.enable = false;
        boot.loader.generic-extlinux-compatible.enable = true;
        # isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-isohost-${name}.iso";
        # isoImage.volumeID = substring 0 11 "NIXOS_ISO";
        # isoImage.makeEfiBootable = true;
        # isoImage.makeUsbBootable = true;
        # boot.loader.grub.memtest86.enable = true;
      };
    in (import "${channel}/nixos" {
      system = machineArchitectures.${name};
      configuration = configuration;
    }).config.system.build.sdImage;

  # configurations :: { *: ({ ... } -> system_configuration) }
  configurations = helpers.keysToAttrs mkMachineConfig machineNames;

  # systems :: { *: system_derivation }
  systems = helpers.keysToAttrs mkMachineSystemDerivation machineNames;

  # isos :: { *: iso_derivation }
  isos = helpers.keysToAttrs mkMachineIsoDerivation machineNames;

  # sdcards :: { *: sdcard_derivation}
  sdcards = helpers.keysToAttrs mkMachineSDCardDerivation machineNames;

  # channels :: { *: path }
  channels = machineChannels;

in
{
  inherit configurations systems isos sdcards channels;
}
