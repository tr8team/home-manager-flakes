{
  description = "Home Manager configuration for GoTrade";

  inputs = {
    # util
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-2305.url = "nixpkgs/nixos-23.05";
    nixpkgs-feb-05-24.url = "nixpkgs/057f9aecfb71c4437d2b27d3323df7f93c010b7e";
    upstreampkgs.url = "github:tr8team/home-manager-upstream";

    atomipkgs.url = "github:kirinnee/test-nix-repo/v22.2.0";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self

      # utils
    , flake-utils
    , treefmt-nix
    , pre-commit-hooks

    , nixpkgs
    , nixpkgs-2305
    , nixpkgs-feb-05-24
    , atomipkgs
    , upstreampkgs
    , home-manager
    } @inputs:
    let user_config = import ./user_config.nix; in
    let
      system = "${user_config.arch}-${user_config.kernel}";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-2305 = nixpkgs-2305.legacyPackages.${system};
      pkgs-feb-05-24 = nixpkgs-feb-05-24.legacyPackages.${system};
      pre-commit-lib = pre-commit-hooks.lib.${system};
      atomi = atomipkgs.packages.${system};
      upstream = upstreampkgs.lib.${system};
    in
    {
      homeConfigurations = {
        "${user_config.user}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit atomi user_config upstream;
          };
        };
      };
    } // (
      flake-utils.lib.eachDefaultSystem
        (system:
        let
          out = rec {
            lib = {
              mutate = import ./default.nix { inherit atomi; };
            };
            pre-commit = import ./nix/pre-commit.nix {
              inherit pre-commit-lib formatter packages;
            };
            formatter = import ./nix/fmt.nix {
              inherit treefmt-nix pkgs;
            };
            packages = import ./nix/packages.nix {
              inherit pkgs atomi pkgs-2305 pkgs-feb-05-24;
            };
            env = import ./nix/env.nix {
              inherit pkgs packages;
            };
            devShells = import ./nix/shells.nix {
              inherit pkgs env packages;
              shellHook = checks.pre-commit-check.shellHook;
            };
            checks = {
              pre-commit-check = pre-commit;
              format = formatter;
            };
          };
        in
        with out;
        {
          inherit checks formatter packages devShells lib;
        }
        )

    );
}
