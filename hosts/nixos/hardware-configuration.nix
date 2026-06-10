# PLACEHOLDER — regenerate on the actual NixOS machine with:
#   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
#
# The values below are stubs so the flake EVALUATES. They will NOT boot a real
# machine (the root device label and bootloader are guesses). Do not run
# `nixos-rebuild switch` against this file until it has been regenerated.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
