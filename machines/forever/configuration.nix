{ pkgs, ... }:
{

  imports = [
    ../../layers/box
  ];

  boot.loader.grub.configurationLimit = 3;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.luks.devices.local_disk = {
    device = "/dev/sda3";
  };

  boot.initrd.preDeviceCommands = "(while sleep 1; do echo DUMMY_PASSWORD | cryptsetup-askpass; done)&";


  networking.useDHCP = false;
  networking.interfaces.ens3 = {
    useDHCP = true;
    ipv6.addresses = [ { address = "2a01:4f8:c2c:e7b1::1"; prefixLength = 64; } ];
  };
  networking.defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };


  networking.firewall.allowedTCPPorts = [
    80
    443
  ];


  services.nginx = {
    enable = true;
    virtualHosts.default = {
      default = true;
      useACMEHost = "forever.0jb.de";
      addSSL = true;
    };
  };

  systemd.services.nginx.wants = [
    "acme-selfsigned-forever.0jb.de.service"
    "acme-forever.0jb.de.service"
  ];
  systemd.services.nginx.after = [ "acme-selfsigned-forever.0jb.de.service" ];
  systemd.services.nginx.before = [ "acme-forever.0jb.de.service" ];


  security.acme = {
    email = "mail+letsencrypt@0jb.de";
    acceptTerms = true;
    certs = {
      "forever.0jb.de" = {
        webroot = "/var/lib/acme/acme-challenge";
        postRun = ''
          systemctl start --failed nginx.service
          systemctl reload nginx.service
        '';
      };
    };
  };

  systemd.services.foo = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      false
    '';
    serviceConfig = {
      Type = "oneshot";
      ExecReload = "${pkgs.coreutils}/bin/true";
    };
  };


  system.stateVersion = "19.09";

}
