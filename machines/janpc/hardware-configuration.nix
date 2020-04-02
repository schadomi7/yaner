# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "nvme" "xhci_pci" "firewire_ohci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/34bf068a-14a0-44e1-a347-ef19d58bf073";
      fsType = "btrfs";
      options = [ "subvol=janpc" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4AE0-CA7F";
      fsType = "vfat";
    };

  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/A165-5893";
  #     fsType = "vfat";
  #   };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/1c148efd-c808-4dac-9ac6-33de8583a3ac"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  # i18n.consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
