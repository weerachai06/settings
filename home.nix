{ config, pkgs, username, gitName, gitEmail, ... }:
let
  repoDir = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Pins the home-manager state version. Do not change after the first switch.
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = gitName;
      user.email = gitEmail;
      alias.adog = "log --all --decorate --oneline --graph";
      pull.rebase = true;
    };
    ignores = [
      "tmp/"
      ".DS_Store"
      "wiki/"
      "AGENTS.md"
      "CLAUDE.md"
      ".scratch"
    ];
  };

  # App config files. App-writable configs use mkOutOfStoreSymlink -> the repo
  # so the apps can still write them; read-only configs are store symlinks.
  xdg.configFile = {
    "wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
    "opencode/AGENTS.md".source = ./opencode/AGENTS.md;
  };

  home.file = {
    ".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
    ".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/claude/settings.json";
    # kiro-cli loads ~/.kiro/steering/**/*.md globally into its default agent
    ".kiro/steering/AGENTS.md".source = ./kiro/AGENTS.md;
  };
}
