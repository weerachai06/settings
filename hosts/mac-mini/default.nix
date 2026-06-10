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

  # Phase 6: casks managed declaratively through nix-darwin (the cask escape
  # hatch). CLI tools + zsh plugins now come from nixpkgs, so they leave Homebrew.
  # cleanup="none" so undeclared formulae/casks are left untouched (coexistence).
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";
    taps = [
      "hashicorp/tap"
      "steipete/tap"
    ];
    # vault (unfree) and minikube stay on Homebrew for now.
    brews = [
      "hashicorp/tap/vault"
      "minikube"
    ];
    casks = [
      "orbstack"
      "wezterm"
      "zed"
      "android-platform-tools"
      "blackhole-2ch"
      "blackhole-64ch"
      "font-meslo-lg-nerd-font"
      "localsend"
      "steipete/tap/codexbar"
    ];
  };
}
