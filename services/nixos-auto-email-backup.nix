{ config, pkgs, lib, ... }:

let
  cfg = config.services.nixos-auto-email-backup;
  name = "nixos-auto-email-backup";
in

with lib;

{
  options.services.nixos-auto-email-backup = with types;{
    enable = mkEnableOption "Auto email backup daily";
    findPackage = mkOption {
      type = package;
      default = pkgs.findutils;
    };
    s3cmdPackage = mkOption {
      type = package;
      default = pkgs.s3cmd;
    };
    tarPackage = mkOption {
      type = package;
      default = pkgs.gnutar;
    };
    gpgPackage = mkOption {
      type = package;
      default = pkgs.gnupg;
    };
    coreutilsPackage = mkOption {
      type = package;
      default = pkgs.coreutils;
    };
  };

  config =
    let
      cfg = config.services.nixos-auto-email-backup;
      findPath = "${cfg.findPackage}/bin/find";
      tarPath = "${cfg.tarPackage}/bin/tar";
      gpgPath = "${cfg.gpgPackage}/bin/gpg";
      s3cmdPath = "${cfg.s3cmdPackage}/bin/s3cmd";
      coreutilsPath = "${cfg.coreutilsPackage}/bin/rm";
      mkStartScript = name: pkgs.writeShellScript "${name}.sh" ''
          set -euo pipefail
          PATH=${makeBinPath (with pkgs;
        [ coreutils inotify-tools s3cmd gzip gnutar gnupg ])}
          VMAIL_PATH=/var/vmail
          VMAIL_BACKUP_PATH=/var/vmail_backup
          ${findPath} $VMAIL_BACKUP_PATH -mindepth 1 -mtime +30 -type f -delete
          ${tarPath} -cvPzf $VMAIL_BACKUP_PATH/vmail_backup.tar.gz $VMAIL_PATH
          ${gpgPath} --output $VMAIL_BACKUP_PATH/vmail_backup_$(date '+%F').tar.gz.gpg --no-tty --armor --symmetric --cipher-algo TWOFISH --pinentry-mode=loopback --passphrase-file $VMAIL_PATH/auth/key.txt $VMAIL_BACKUP_PATH/vmail_backup.tar.gz
          ${s3cmdPath} put $VMAIL_BACKUP_PATH/vmail_backup_`date +%F`.tar.gz.gpg s3://mudreac-vmail-backup
          ${coreutilsPath} -rf $VMAIL_BACKUP_PATH/*.gz
      '';
    in
    mkIf cfg.enable {
      systemd.services.nixos-auto-email-backup = {
        description = "Auto email backup daily";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${mkStartScript name}";
        };
      };

      systemd.timers.nixos-auto-email-backup = {
        description = "Timer for auto daily email backup";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnUnitActiveSec = "1d"; # run daily
        };
      };
    };
}
