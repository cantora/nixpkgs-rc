{ pkgs, ... }:

let
  callPackage = pkgs.lib.callPackageWith (
    pkgs // { inherit cantora; }
  );
  cantora = {
    xorgconfig = callPackage ./xorg.conf {};
    dwm        = callPackage ./dwm {};
    dmenu      = callPackage ./dmenu {};
    xinit      = callPackage ./xinit {};
    categories = callPackage ./categories {};
    i18n       = callPackage ./i18n {};
  };
in cantora
