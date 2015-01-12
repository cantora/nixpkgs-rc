{ stdenv,
  xlibs,
  cantora,
  xorg,
  lib,
  ...}:

let
  xinit      = xlibs.xinit;
  xorgconfig = cantora.xorgconfig;

  defaultserverargs = lib.concatStringsSep " " [
    "-terminate"
    "-logfile $HOME/.xorg.log"
    "-config ${xorgconfig}"
  ];
  ld_library_path = ''
    LD_LIBRARY_PATH=${xorgconfig.ld_library_path}:$LD_LIBRARY_PATH
  '';

  xorg_driver_path = "XORG_DRI_DRIVER_PATH=/run/opengl-driver/lib/dri";
  xkb_bindir       = "XKB_BINDIR=${xorg.xkbcomp}/bin";

in stdenv.lib.overrideDerivation xinit (attrs: {
  prePatch = ''
    sed -i \
        -e 's|^defaultserverargs="|&${defaultserverargs}|' \
        -e '2a export ${ld_library_path}' \
        -e '2a export ${xorg_driver_path}' \
        -e '2a export ${xkb_bindir}' \
        startx.cpp
  '';
})
