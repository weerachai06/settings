{
  description = "Portable dev environment (home-manager standalone)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-utils, home-manager, ... }:
    let
      # Private per-machine values (gitignored) — copy env.nix.example -> env.nix
      env = if builtins.pathExists ./env.nix then import ./env.nix else { };

      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "vault" ];
          };
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            # builtins.getEnv requires --impure; returns "" in pure mode → fallback used.
            username =
              let u = builtins.getEnv "USER";
              in if u != "" then u else "weerachaiplodkaew";
            gitName = env.gitName or "Weerachai Plodkaew";
            gitEmail = env.gitEmail or "clkeen157@gmail.com";
          };
        };
    in
    {
      # Linux only on this branch — no Mac setup here.
      homeConfigurations = {
        "x86_64-linux" = mkHome "x86_64-linux"; # Linux / NixOS
        "aarch64-linux" = mkHome "aarch64-linux";
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          # CLI tools, available via `nix develop` (or direnv) instead of the home profile.
          packages = with pkgs; [
            gh
            jq
            openssl
          ];

          shellHook = ''
            echo ""
            echo "  tip: run 'direnv allow' once so this shell auto-activates"
            echo "       next time you cd into this directory."
            echo ""
          '';
        };
      }
    );
}
