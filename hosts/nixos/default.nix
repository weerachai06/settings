{ pkgs, ... }:
{
  # Phase 8 scaffold: NixOS host on the shared home-manager layer (portable-first).
  # PLACEHOLDERS to confirm: hostname ("nixos") and username (weerachaiplodkaew).
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  # Flakes enabled (NixOS manages nix natively — no Determinate here).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # zsh must be enabled at system level to be a valid login shell.
  programs.zsh.enable = true;

  users.users.weerachaiplodkaew = {
    isNormalUser = true;
    home = "/home/weerachaiplodkaew";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # TODO (on the NixOS box): time zone, locale, networking, GUI apps from
  # nixpkgs (wezterm, zed), and anything else machine-specific.

  # Pins the NixOS state version. Do not change after first switch.
  system.stateVersion = "24.11";
}
