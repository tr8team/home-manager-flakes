{ pkgs, pkgs-2305, atomi, pkgs-feb-05-24 }:
let

  all = {
    atomipkgs = (
      with atomi;
      {
        inherit
          infisical
          pls;
      }
    );
    nix-2505 = (
      with pkgs;
      {
        inherit
          coreutils
          gnugrep
          bash
          jq
          git
          treefmt
          shellcheck
          ;
      }
    );
  };
in
with all;
atomipkgs //
nix-2505
