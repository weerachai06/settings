{ ... }:
{
  # Phase 1 scaffold: minimal system config that builds and does almost nothing.
  # Tool configs migrate into here / the shared home layer incrementally.

  networking.hostName = "mac-mini";

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Nix is installed and managed by the Determinate Systems installer, so
  # nix-darwin must NOT also manage /etc/nix — they would conflict.
  nix.enable = false;

  # User-scoped options (incl. home-manager) need a primary user on darwin.
  system.primaryUser = "weerachaiplodkaew";
  users.users.weerachaiplodkaew.home = "/Users/weerachaiplodkaew";

  # Pins the nix-darwin state version. Do not change after the first switch.
  system.stateVersion = 6;
}
