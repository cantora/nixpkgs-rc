{ stdenv,
  lib,
  xorg,
  dejavu_fonts,
  freefont_ttf,
  liberation_ttf,
  xkeyboard_config,
  ...}:

with lib;
with lib.trivial;
with lib.attrsets;
with builtins;

let
  fonts = [
    xorg.fontbhttf
    xorg.fontbhlucidatypewriter100dpi
    xorg.fontbhlucidatypewriter75dpi
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    xorg.fontbh100dpi
    xorg.fontmiscmisc
    xorg.fontcursormisc
    xorg.fontadobe100dpi
    xorg.fontadobe75dpi
  ];

  videoDrivers = [
    "ati" "cirrus" "intel" "vesa" "vmware" "modesetting"
  ];

  knownVideoDrivers = {
    nouveau       = { modules = [ xf86_video_nouveau ]; };
    unichrome    = { modules = [ xorgVideoUnichrome ]; };
    virtualbox   = { modules = [ kernelPackages.virtualboxGuestAdditions ]; driverName = "vboxvideo"; };
    ati = { modules = [ xorg.xf86videoati xorg.glamoregl ]; };
    intel-testing = { modules = with xorg; [ xf86videointel-testing glamoregl ]; driverName = "intel"; };
  };

  drivers = map (name:
    let driver =
      attrByPath [name]
        (if xorg ? ${"xf86video" + name}
         then { modules = [xorg.${"xf86video" + name}]; }
         else null)
        knownVideoDrivers;
    in { inherit name; driverName = name; } // driver) videoDrivers ;

  modules =
    concatLists (catAttrs "modules" drivers)
    ++ [ xorg.xorgserver xorg.xf86inputevdev ];

  cfg = {
    serverFlagsSection    = "";
    moduleSection         = "";
    monitorSection        = "";
    xkbModel              = "pc104";
    layout                = "us";
    xkbOptions            = "terminate:ctrl_alt_bksp";
    xkbVariant            = "";
    serverLayoutSection   = "";
    useGlamor             = false;
    deviceSection         = "";
    xrandrHeads           = [];
    screenSection         = "";
    defaultDepth          = 0;
    resolutions           = [];
    extraDisplaySettings  = "";
    virtualScreen         = null;
  };

  xrandrHeads = let
    mkHead = num: output: {
      name = "multihead${toString num}";
      inherit output;
    };
  in imap mkHead cfg.xrandrHeads;

  xrandrDeviceSection = flip concatMapStrings xrandrHeads (h: ''
    Option "monitor-${h.output}" "${h.name}"
  '');

  # Here we chain every monitor from the left to right, so we have:
  # m4 right of m3 right of m2 right of m1   .----.----.----.----.
  # Which will end up in reverse ----------> | m1 | m2 | m3 | m4 |
  #                                          `----^----^----^----'
  xrandrMonitorSections = let
    mkMonitor = previous: current: previous ++ singleton {
      inherit (current) name;
      value = ''
        Section "Monitor"
          Identifier "${current.name}"
          ${optionalString (previous != []) ''
          Option "RightOf" "${(head previous).name}"
          ''}
        EndSection
      '';
    };
    monitors = foldl mkMonitor [] xrandrHeads;
  in concatMapStrings (getAttr "value") monitors;

in stdenv.mkDerivation rec {
  name = "cantora-xorg.conf";

  inherit fonts modules;
  #xinit package needs this for its environment
  ld_library_path = concatStringsSep ":" (
    [ "${xorg.libX11}/lib" "${xorg.libXext}/lib" ]
    ++ concatLists (catAttrs "libPath" drivers)
  );

  xkbDir = "${xkeyboard_config}/etc/X11/xkb";

  config = ''
    Section "ServerFlags"
      Option "AllowMouseOpenFail" "on"
      ${cfg.serverFlagsSection}
    EndSection

    Section "Module"
      ${cfg.moduleSection}
    EndSection

    Section "Monitor"
      Identifier "Monitor[0]"
      ${cfg.monitorSection}
    EndSection

    Section "InputClass"
      Identifier "Keyboard catchall"
      MatchIsKeyboard "on"
      Option "XkbRules" "base"
      Option "XkbModel" "${cfg.xkbModel}"
      Option "XkbLayout" "${cfg.layout}"
      Option "XkbOptions" "${cfg.xkbOptions}"
      Option "XkbVariant" "${cfg.xkbVariant}"
    EndSection

    Section "ServerLayout"
      Identifier "Layout[all]"
      ${cfg.serverLayoutSection}
      # Reference the Screen sections for each driver.  This will
      # cause the X server to try each in turn.
      ''\n${flip
        concatMapStrings
        drivers
        (d: "  Screen \"Screen-${d.name}[0]\"\n")
      }
    EndSection

    ${if cfg.useGlamor then ''
      Section "Module"
        Load "dri2"
        Load "glamoregl"
      EndSection
    '' else ""}

    # For each supported driver, add a "Device" and "Screen"
    # section.
    ${flip concatMapStrings drivers (driver: ''

      Section "Device"
        Identifier "Device-${driver.name}[0]"
        Driver "${driver.driverName or driver.name}"
        ${if cfg.useGlamor then ''Option "AccelMethod" "glamor"'' else ""}
        ${cfg.deviceSection}
        ${xrandrDeviceSection}
      EndSection

      Section "Screen"
        Identifier "Screen-${driver.name}[0]"
        Device "Device-${driver.name}[0]"
        ${optionalString (cfg.monitorSection != "") ''
          Monitor "Monitor[0]"
        ''}

        ${cfg.screenSection}

        ${optionalString (cfg.defaultDepth != 0) ''
          DefaultDepth ${toString cfg.defaultDepth}
        ''}

        ${optionalString
            (driver.name != "virtualbox" &&
             (cfg.resolutions != [] ||
              cfg.extraDisplaySettings != "" ||
              cfg.virtualScreen != null))
          (let
            f = depth:
              ''
                SubSection "Display"
                  Depth ${toString depth}
                  ${optionalString (cfg.resolutions != [])
                    "Modes ${concatMapStrings (res: ''"${toString res.x}x${toString res.y}"'') cfg.resolutions}"}
                  ${cfg.extraDisplaySettings}
                  ${optionalString (cfg.virtualScreen != null)
                    "Virtual ${toString cfg.virtualScreen.x} ${toString cfg.virtualScreen.y}"}
                EndSubSection
              '';
          in concatMapStrings f [8 16 24]
        )}

      EndSection
    '')}

    ${xrandrMonitorSections}
  '';

  buildCommand =
    ''
      echo 'Section "Files"' >> $out

      for i in ${toString fonts}; do
        if test "''${i:0:''${#NIX_STORE}}" == "$NIX_STORE"; then
          for j in $(find $i -name fonts.dir); do
            echo "  FontPath \"$(dirname $j)\"" >> $out
          done
        fi
      done

      for i in $(find ${toString modules} -type d); do
        if test $(echo $i/*.so* | wc -w) -ne 0; then
          echo "  ModulePath \"$i\"" >> $out
        fi
      done

      echo "  XkbDir \"$xkbDir\"" >> $out

      echo 'EndSection' >> $out

      echo "$config" >> $out
    '';
}
