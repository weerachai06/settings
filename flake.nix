{
  description = "Portable dev environment (home-manager standalone)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            # builtins.getEnv requires --impure; returns "" in pure mode → fallback used.
            username =
              let u = builtins.getEnv "USER";
              in if u != "" then u else "weerachaiplodkaew";
          };
        };
    in
    {
      # One config, every platform — pick by the machine's system arch.
      homeConfigurations = {
        "aarch64-darwin" = mkHome "aarch64-darwin"; # Mac (Apple Silicon)
        "x86_64-darwin" = mkHome "x86_64-darwin"; # Mac (Intel)
        "x86_64-linux" = mkHome "x86_64-linux"; # Linux / NixOS
        "aarch64-linux" = mkHome "aarch64-linux";
      };
    };
}
