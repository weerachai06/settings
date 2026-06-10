# Dotfiles

A personal, cross-platform machine configuration repository. Provisions both macOS (via nix-darwin) and NixOS (Linux) from a single Nix flake, sharing a common user-environment layer.

## Language

**Tool config**:
The set of configuration files for one tool (zsh, git, wezterm, etc.). In the shell-script era these were per-tool directories each with an `install.sh`.
_Avoid_: Module (reserved for the Nix meaning below)

**Module**:
A Nix configuration unit (NixOS or home-manager) exposing `options`/`config`. Always refers to the Nix sense, never to a tool config directory.
_Avoid_: Using "module" for a tool config

**Host**:
A specific machine the flake can build a configuration for, named under `darwinConfigurations.<host>` or `nixosConfigurations.<host>`.
_Avoid_: Machine, target (when referring to a named config)

**Shared layer**:
Configuration applied to every host regardless of OS — primarily the home-manager user environment (dotfiles, CLI tools).
_Avoid_: Common, base

**Darwin layer**:
Configuration applied only on macOS hosts (nix-darwin system config plus macOS-only tool configs).
_Avoid_: Mac layer, macOS module

**NixOS layer**:
Configuration applied only on NixOS hosts.
_Avoid_: Linux layer (the repo only targets NixOS, not generic Linux)

**Portable-first**:
The migration stance: NixOS receives only functionality that ports cleanly; macOS-only features (e.g. `gh-pr-notifier`, `global-protect`) stay Darwin-only until a later parity pass.
