{ config, lib, pkgs, username, ... }:
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

  # CLI tools (cross-platform). Deferred: vault (unfree, needs allowUnfree).
  home.packages = with pkgs; [
    cmake
    fnm
    gh
    jq
    openssl
    uv
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Weerachai Plodkaew";
      user.email = "clkeen157@gmail.com";
      alias.adog = "log --all --decorate --oneline --graph";
      pull.rebase = true;
    };
    ignores = [
      "tmp/"
      ".DS_Store"
      "wiki/"
      "AGENTS.md"
      "CLAUDE.md"
    ];
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
    initContent = ''
      # fnm (Node version manager) — auto-switch on cd
      eval "$(fnm env --use-on-cd --shell zsh)"
      # uv shell completion
      eval "$(uv generate-shell-completion zsh)"
    ''
    # macOS-only integrations (GUI apps + tools managed outside Nix).
    + lib.optionalString pkgs.stdenv.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
      [ -f "$HOME/global-protect.sh" ] && source "$HOME/global-protect.sh"
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
      export PATH="$HOME/.opencode/bin:$PATH"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';
  };

  # App config files. App-writable configs use mkOutOfStoreSymlink -> the repo
  # so the apps can still write them; read-only configs are store symlinks.
  xdg.configFile = {
    "wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;

    "zed/keymap.json".source = ./zed/keymap.json;
    "zed/tasks.json".source = ./zed/tasks.json;
    "zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/zed/settings.json";

    "opencode/AGENTS.md".source = ./opencode/AGENTS.md;
    "opencode/opencode.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/opencode/opencode.jsonc";
  };

  home.file = {
    ".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
    ".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/claude/settings.json";
  };
}
