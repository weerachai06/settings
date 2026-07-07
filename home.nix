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
  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  # We don't declare any systemd user units; the module still defaults
  # systemctlPath to pkgs.systemd, dragging in its full closure (cryptsetup,
  # lvm2, kmod, kbd, kexec-tools, pam...). Disable it outright.
  systemd.user.enable = false;

  home.packages = with pkgs; [
    fnm
    gh
    vault
    pnpm
  ];

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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # caches nix develop shells
  };

  # Enables home-manager to wire ~/.bashrc so PATH/env vars from this config
  # (and fnm's node bin dir) are available without a manual `source` step
  # after activation. Coder's default login shell is bash.
  programs.bash = {
    enable = true;
    initExtra = ''
      # home-manager only sources hm-session-vars.sh from ~/.profile (login
      # shells). Coder's SSH session spawns a non-login bash that skips it,
      # so ~/.nix-profile/bin (fnm, gh) would otherwise be missing from PATH.
      export PATH="$HOME/.nix-profile/bin:$PATH"
      eval "$(fnm env --use-on-cd)"
    '';
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
