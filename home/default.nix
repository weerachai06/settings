{ ... }:
{
  # Shared home-manager layer — applies to every host.
  # Phase 1: nothing managed yet; tool configs land here incrementally.

  home.username = "weerachaiplodkaew";
  home.homeDirectory = "/Users/weerachaiplodkaew";

  # Pins the home-manager state version. Do not change after the first switch.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
