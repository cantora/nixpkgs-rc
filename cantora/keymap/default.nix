{ stdenv,
  kbd,
  writeText,
  ...}:

let
  console-switch = ''
    # this modifier is not used for anything, so we represent super/OS button with it
    keycode 125 = Control_R
    
    # reset explicit keymaps, allowing any column to be set
    keymaps 0-255
    # switch to console 2 on super+space
    ctrlr keycode 57 = Console_2
  '';
  console-switch-file = writeText 
    "cantora-key-map-console-switch" 
    console-switch;

in stdenv.mkDerivation {
  name = "cantora-keymap.gz";

  buildCommand = ''
    {  cat ${kbd}/share/keymaps/i386/qwerty/us.map.gz \
         | gunzip \
         | sed 's/^keycode  58 = Caps_Lock/keycode  58 = Control/';
       cat ${console-switch-file};
    } | gzip > $out
  '';

}
