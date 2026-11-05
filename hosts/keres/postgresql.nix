# Service: PostgreSQL
# Dependencies: none
# Data location:
#   Cluster (PostgreSQL 16): /var/lib/postgresql/16
#   Unix socket (runtime): /run/postgresql
{
  nixos = {
    services.postgresql.enable = true;

    # Keep the socket directory's inode stable for Romm's container bind mount
    # when PostgreSQL restarts.
    systemd.services.postgresql.serviceConfig.RuntimeDirectoryPreserve = "yes";
  };
}
