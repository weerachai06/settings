# Migrate dotfiles from shell scripts to a cross-platform Nix flake

## Status

superseded by ADR-0002 (the nix-darwin + NixOS host architecture was replaced
with home-manager standalone). The migration *off* shell scripts and onto Nix
still holds; the cross-platform-via-system-hosts decision does not.

## Context

The repo provisions machines with shell scripts: a `bootstrap.sh` chain of `curl | sh` installers (Homebrew, Oh My Zsh, rustup, bun, opencode), per-tool-config `install.sh` files that call `brew_install` and symlink dotfiles via a `link` helper in `lib.sh`, and a gitignored `homebrew/.local` file of `SKIP_<NAME>=1` flags for per-machine opt-outs. This is imperative, unpinned, and macOS-only in practice.

## Decision

Migrate to a single **Nix flake** exposing both `darwinConfigurations` (macOS, via nix-darwin) and `nixosConfigurations` (NixOS), sharing one **home-manager** layer for the user environment. Two hosts, both public-repo-safe, each declaring its own package set (replacing the `SKIP_` opt-out flags with per-host allow-lists).

Key sub-decisions:

- **Cross-platform = macOS + NixOS.** The Linux target is full NixOS, not standalone home-manager on a generic distro.
- **Portable-first.** NixOS receives only functionality that ports cleanly. macOS-only features (`gh-pr-notifier`, `global-protect`) stay Darwin-only until a later parity pass.
- **Hybrid config style.** Native home-manager program modules where Nix adds real value and translation is clean (`programs.git`, `programs.zsh` incl. Oh My Zsh + fnm); `home.file`/`xdg.configFile` symlinks for files better left native (wezterm.lua, zed JSON, opencode, claude, instructions).
- **Homebrew survives on macOS as a cask escape hatch**, declared *through* nix-darwin (`homebrew.casks`). CLI tools move to nixpkgs (shared layer). GUI apps stay as Homebrew casks on macOS but use nixpkgs builds on NixOS.
- **Toolchains:** stable Rust (`rustc`/`cargo`) and `bun` from nixpkgs; no rustup. Nix itself installed via the Determinate Systems installer.
- **Incremental, macOS-first migration.** Stand up the flake alongside the existing scripts, port one tool config at a time, and remove each shell script only after its replacement verifies. Develop on macOS (the at-risk working machine), then bring NixOS up on the proven shared layer.

## Considered Options

- **macOS-only (nix-darwin + home-manager).** Rejected: a second machine running NixOS needs provisioning from this repo.
- **Standalone home-manager on generic Linux.** Rejected: the Linux machine is NixOS, so the full distro integration is available and wanted.
- **All-symlink or all-native config.** Rejected in favor of hybrid: all-symlink forgoes Nix's value for git/zsh; all-native makes wezterm.lua and zed JSON painful and lossy.
- **Big-bang cutover.** Rejected: leaves nothing working until everything works and is hard to bisect.

## Consequences

- macOS-first development means the shared layer is only exercised on Darwin until NixOS comes online, so cross-platform breakage (Linux-incompatible packages, darwin-only options leaking into the shared layer) stays hidden. Mitigation: keep strict layer boundaries and eval-build the NixOS config continuously without deploying — `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- `bootstrap.sh` collapses to: install Nix (Determinate), then `darwin-rebuild`/`nixos-rebuild switch --flake .#<host>`.
- Per-machine choices move from a gitignored skip-list into committed per-host config.
