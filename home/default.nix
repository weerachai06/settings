{ pkgs, ... }:
{
  # Shared home-manager layer — applies to every host.
  # Tool configs land here incrementally as they migrate off the shell scripts.

  home.username = "weerachaiplodkaew";
  home.homeDirectory = "/Users/weerachaiplodkaew";

  # Pins the home-manager state version. Do not change after the first switch.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Phase 2: CLI tools migrated from Homebrew to nixpkgs.
  # Deferred: fnm (-> programs.fnm in zsh phase), vault (unfree, needs allowUnfree).
  home.packages = with pkgs; [
    cmake
    gh
    jq
    openssl
    uv
  ];
}
