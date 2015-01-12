{ stdenv, fetchgit, xlibs, ...}:
 
stdenv.mkDerivation {
  name = "cantora-dwm";

  src = fetchgit {
    url       = "https://github.com/cantora/dwm.git";
    rev       = "refs/heads/cantora";
    sha256    = "1lnhdcnmikmr8i6hkxkgr9haypryx4v4x40rp73fwx8bibkdgn3i";
  };

  buildInputs = with xlibs; [ libX11 libXinerama ];

  prePatch = ''
    sed -i "s@PREFIX = /home/\$(USER)@PREFIX = $out@" config.mk
  '';

  buildPhase = " make ";
}
