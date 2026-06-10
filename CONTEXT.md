# Dotfiles

A personal, portable development environment managed with **home-manager standalone**.
One config (`home.nix`) provides the same dev environment — CLI tools, shell, git,
app configs — on any machine (macOS or Linux), without managing the system itself.

## Language

**Tool config**:
The set of configuration files for one tool (zsh, git, wezterm, etc.). Some are now
expressed natively in `home.nix`; others are symlinked from their directory.
_Avoid_: Module (reserved for the Nix meaning below)

**Module**:
A Nix configuration unit (here, home-manager) exposing `options`/`config`. Always
the Nix sense, never a tool config directory.
_Avoid_: Using "module" for a tool config

**Home config**:
A `homeConfigurations.<system>` output, built/activated with `home-manager switch`.
Keyed by system arch (e.g. `aarch64-darwin`) so one definition serves every machine.
_Avoid_: Host (this setup does not manage whole machines)

**Portable**:
The guiding stance: the same `home.nix` works for any user on any machine. Machine-
or OS-specific bits are guarded (e.g. `lib.optionalString pkgs.stdenv.isDarwin`) or
left out of Nix entirely (GUI apps, system services).
