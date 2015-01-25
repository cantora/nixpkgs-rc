{ cantora,
  terminus_font, ... }:

{
  #i18n = with cantora.i18n; {
  #  inherit consoleFont consoleKeyMap defaultLocale;
  #};

  consoleFont = "${terminus_font}/share/consolefonts/ter-116n.psf.gz";
  consoleKeyMap = "${cantora.keymap}";
  defaultLocale = "en_US.UTF-8";
}
