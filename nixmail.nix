{ config, pkgs, ... }:

let release = "nixos-21.05";
in
{
  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      sha256 = "1fwhb7a5v9c98nzhf3dyqf3a5ianqh7k50zizj8v5nmj3blxw4pi";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.YouDomain.com";
    domains = [ "YouDomain.com" ];
    # A list of all login accounts. To create the password hashes, use
    # nix-shell - p apacheHttpd - -run  'htpasswd - nbB "" "super secret password"' | cut - d: -f2 > /var/vmail/User_Passwd
    loginAccounts = {
      "User@YouDomain.com" = {
        hashedPasswordFile = "/var/vmail/User_Passwd";
        aliases = [
          "Alias1@YouDomain.com"
          "Alias2@YouDomain.com"
        ];
      };
    }; 

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = 3;
  };
  
  security.acme = {
      acceptTerms = true;
      email = "User@YouDomain.com";
    };
}
