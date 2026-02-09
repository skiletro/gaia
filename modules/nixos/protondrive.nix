{
  config,
  lib,
  pkgs,
  ...
}:
{
  # TODO: modularise more.
  options.services.protondrive = {
    enable = lib.mkEnableOption "Rclone Proton Drive Sync";
    passwordPath = lib.mkOption {
      type = lib.types.path;
      default = "";
    };
  };

  config = lib.mkIf config.services.protondrive.enable {
    home-manager.sharedModules = lib.singleton {
      programs.rclone = {
        enable = true;
        remotes.proton = {
          config = {
            type = "protondrive";
            username = "skiletro";
          };
          secrets.password = config.services.protondrive.passwordPath;
        };
      };

      systemd.user = {
        timers."rclone-docs-sync" = {
          Unit = {
            Description = "Sync Documents with Proton Drive";
          };
          Install.WantedBy = [ "timers.target" ];
          Timer = {
            Unit = "rclone-docs-sync.service";
            OnBootSec = "10min";
            OnUnitActiveSec = "30min";
          };
        };

        services."rclone-docs-sync" = {
          Install.WantedBy = [ "multi-user.target" ];
          Service = {
            Type = "oneshot";
            ExecStart = lib.getExe (
              pkgs.writers.writeFishBin "rclone-docs-sync"
                # fish
                ''
                  set HASH_FILE "/tmp/.rclone-protondrive-hash"
                  set REMOTE_DIR "Documents"
                  set SYNC_DIR "/home/jamie/Documents"

                  set CURRENT_HASH (${lib.getExe pkgs.gnutar} fcP - $SYNC_DIR | md5sum)

                  function log -a val
                      echo "RPROTON - $val"
                  end

                  function run_sync
                      log "Running sync..."
                      ${lib.getExe pkgs.rclone} bisync -v --force --min-size 1b proton:$REMOTE_DIR $SYNC_DIR
                      log "Sync command run."
                  end

                  function create_hash_file
                      log "Creating hash file..."
                      echo $CURRENT_HASH >$HASH_FILE
                  end

                  function check_hash
                      log "Checking directory hashes..."
                      set prev_hash (cat $HASH_FILE)
                      if test "$CURRENT_HASH" != "$prev_hash"
                          log "Hash is not the same. Syncing..."
                          run_sync
                          create_hash_file
                      else
                          log "Hash is the same, no need to sync."
                      end
                  end

                  function main
                      log "Checking if previous hash file exists..."
                      if test -f $HASH_FILE
                          log "Hash file exists!"
                          check_hash
                      else
                          log "Hash file does not exist."
                          create_hash_file
                          run_sync
                      end
                  end

                  main
                ''
            );
          };
        };
      };
    };
  };
}
