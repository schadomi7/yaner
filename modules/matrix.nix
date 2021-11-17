{ mkModule
, lib
, liftToNamespace
, extractFromNamespace
, config
, pkgs
, ... }:
with lib;

mkModule {

  options = cfg: liftToNamespace {

    baseDomain = mkOption {
      type = types.str;
      default = "0jb.de";
    };

    matrixDomain = mkOption {
      type = types.str;
      default = "matrix.${cfg.baseDomain}";
    };

    elementDomain = mkOption {
      type = types.str;
      default = "element.${cfg.baseDomain}";
    };

    nginxBaseVirtualhost = mkOption {
      type = types.str;
      default = cfg.baseDomain;
    };

    useACMEHost = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    secretsFile = mkOption {
      type = types.str;
      default = "${config.services.matrix-synapse.dataDir}/secrets.yml";
    };

  };

  config = cfg: {

    # Matrix Server
    services.matrix-synapse = {
      enable = true;
      database_type = "sqlite3";
      server_name = cfg.baseDomain;
      no_tls = true;
      listeners = [{
        bind_address = "::1";
        port = 8008;
        resources = [
          { compress = false; names = [ "client" "federation" ]; }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }];

      allow_guest_access = false;
      enable_registration = false;
      url_preview_enabled = true;
      expire_access_token = true;

      extraConfigFiles = [
        cfg.secretsFile
      ];
    };

    # Matrix availability
    services.nginx.virtualHosts.${cfg.matrixDomain} = {
      forceSSL = true;
      useACMEHost = cfg.useACMEHost;
      locations."/".extraConfig = "return 302 'https://${cfg.elementDomain}/';";
      locations."/_matrix".proxyPass = "http://[::1]:8008";
    };

    # Element Web
    services.nginx.virtualHosts.${cfg.elementDomain} = let
      config = {
        default_server_name = cfg.baseDomain;
        disable_login_language_selector = true;
        disable_3pid_login = true;
        disable_custom_urls = true;
        disable_guests = true;
        showLabsSettings = true;
        enable_presence_by_hs_url = {
          "https://matrix-client.matrix.org" = false;
          "https://matrix.org" = false;
        };
      };
    in {
      forceSSL = true;
      useACMEHost = cfg.useACMEHost;
      root = pkgs.element-web;
      locations."/config.json".extraConfig = ''
        default_type application/json;
        return 200 '${builtins.toJSON config}';
      '';
    };

    # Well known connectivity
    services.nginx.virtualHosts.${cfg.nginxBaseVirtualhost}.locations = let
      wellKnownClient = {
        "m.homeserver".base_url = "https://${cfg.matrixDomain}";
        "m.identity_server".base_url = "";
      };
      wellKnownServer = {
        "m.server" = "${cfg.matrixDomain}:443";
      };
      headers = ''
        default_type application/json;
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'X-Requested-With, Content-Type, Authorization';
      '';
    in {
      "/.well-known/matrix/client".extraConfig = ''
        ${headers}
        return 200 '${builtins.toJSON wellKnownClient}';
      '';
      "/.well-known/matrix/server".extraConfig = ''
        ${headers}
        return 200 '${builtins.toJSON wellKnownServer}';
      '';
    };

  };

}
