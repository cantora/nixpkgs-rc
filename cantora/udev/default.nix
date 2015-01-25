{ pkgs, ... }:

{
  #add this to services.udev.extraRules

  #workaround for kernel bug where font is lost after the console
  #framebuffer driver is changed. see http://cgit.freedesktop.org/systemd/systemd/commit/?id=f6ba8671d83f9fce9a00045d8fa399a1c07ba7fc
  FBFontBugRule = ''
    ACTION=="add", SUBSYSTEM=="graphics", KERNEL=="fbcon", RUN+="${pkgs.systemd}/lib/systemd/systemd-vconsole-setup"
  '';
}
