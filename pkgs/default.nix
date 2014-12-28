{ system ? builtins.currentSystem }:

#based on sandervanderburg.blogspot.com/2014/07/managing-private-nix-packages-outside.html
let
  pkgs = import <nixpkgs> { inherit system; };
  
  #dont currently need this because we dont override any dependencies
  #callPackage = pkgs.lib.callPackageWith (
  #  pkgs
  #  // pkgs.xlibs
  #  // self
  #);
  #self = rec { };
  callPackage = pkgs.lib.callPackageWith pkgs;

in [
  (callPackage ./dwm { })
  (callPackage ./dmenu { })
]
