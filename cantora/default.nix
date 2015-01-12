{ pkgs, system ? builtins.currentSystem, ... }:

let
  callPackage = pkgs.lib.callPackageWith (
    pkgs // { inherit cantora; }
  );
  cantora = {
    xorgconfig = callPackage ./xorg.conf {};
    dwm        = callPackage ./dwm {};
    dmenu      = callPackage ./dmenu {};
    xinit      = callPackage ./xinit {};
  };
in cantora