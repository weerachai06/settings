{ config, pkgs, ... }:
{
  # Shared home-manager layer — applies to every host.
  # Tool configs land here incrementally as they migrate off the shell scripts.

  home.username = "weerachaiplodkaew";
  home.homeDirectory = "/Users/weerachaiplodkaew";

  # Pins the home-manager state version. Do not change after the first switch.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Phase 2: CLI tools migrated from Homebrew to nixpkgs.
  # Deferred: vault (unfree, needs allowUnfree).
  home.packages = with pkgs; [
    cmake
    fnm
    gh
    jq
    openssl
    uv
  ];

  # Phase 4: zsh portable core (replaces brew-sourced plugins + oh-my-zsh install).
  # Deferred to darwin layer: brew shellenv, orbstack, global-protect.
  # Deferred until their tools migrate: openssl env vars, bun, opencode, cargo env.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;     # replaces brew zsh-autosuggestions
    syntaxHighlighting.enable = true; # replaces brew zsh-syntax-highlighting
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
    '';
  };

  # Phase 3: git as a native module (replaces git/.gitconfig + .gitignore_global).
  # `ignores` generates the global ignore and wires core.excludesFile for us.
  programs.git = {
    enable = true;
    userName = "Weerachai Plodkaew";
    userEmail = "clkeen157@gmail.com";
    aliases.adog = "log --all --decorate --oneline --graph";
    extraConfig.pull.rebase = true;
    ignores = [
      "tmp/"
      ".DS_Store"
      "wiki/"
      "AGENTS.md"
      "CLAUDE.md"
    ];
  };

  # Phase 5: app config files (replaces wezterm/zed/opencode/claude install.sh).
  # App-writable configs use mkOutOfStoreSymlink -> the repo, so the apps can
  # still write them (matching the old `link` behavior). Read-only configs are
  # plain store symlinks. Assumes the repo lives at ~/.dotfiles.
  # instructions/ has no .md files yet, so nothing to link there.
  xdg.configFile = {
    "wezterm/wezterm.lua".source = ../wezterm/wezterm.lua;

    "zed/keymap.json".source = ../zed/keymap.json;
    "zed/tasks.json".source = ../zed/tasks.json;
    "zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/zed/settings.json";

    "opencode/AGENTS.md".source = ../opencode/AGENTS.md;
    "opencode/opencode.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/opencode/opencode.jsonc";
  };

  home.file = {
    ".claude/CLAUDE.md".source = ../claude/CLAUDE.md;
    ".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/claude/settings.json";
  };
}
