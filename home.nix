{ config, pkgs, atomi, user_config, upstream, ... }:

let
  linux = import ./home-template-linux.nix {
    inherit config pkgs atomi user_config;
  };
in
let
  darwin = import ./home-template-darwin.nix {
    inherit config pkgs atomi user_config;
  };
in
let outputs = (if user_config.kernel == "linux" then linux else darwin); in
upstream.mutate { inherit outputs user_config; nixpkgs = pkgs; }
