{ stdenv, fetchgit, xlibs, ... }:

stdenv.mkDerivation {
  name = "cantora-dmenu";

  src  = fetchgit {
    url     = "https://github.com/cantora/dmenu.git";
    rev     = "refs/heads/master";
    sha256  = "0ajy0xsgg5k1gb91rgqac5agpsi2laxf26p4vm14hwaj2lgikppq";
  };

  buildInputs = with xlibs; [ libX11 libXinerama ];

  prePatch = ''
    sed -re 's!\<(dmenu|dmenu_path)\>!'"$out/bin"'/&!g' dmenu_run \
      && sed -re 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path \
      && sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  buildPhase = " make ";
}
