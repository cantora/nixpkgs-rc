{ stdenv, fetchgit, xlibs, ...}:
 
stdenv.mkDerivation {
  name = "cantora-dwm";

  src = fetchgit {
    url       = "https://github.com/cantora/dwm.git";
    rev       = "refs/heads/cantora";
    sha256    = "0dv0z365qbl9g97m2zsd42c5j20barfgx3rz8q449spx6ifz404y";
  };

  buildInputs = with xlibs; [ libX11 libXinerama ];

  prePatch = ''
    sed -i "s@PREFIX = /home/\$(USER)@PREFIX = $out@" config.mk
  '';

  buildPhase = " make ";
}
