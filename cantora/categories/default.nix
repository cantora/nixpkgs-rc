{pkgs, cantora, ...}:

let
  collectLists = pkgs.lib.attrsets.collect builtins.isList;
  recListConcat = attrs: pkgs.lib.lists.flatten (collectLists attrs);

  categories = with pkgs; {
    editors = [
      vim
      emacs
    ];
  
    terminal = [
      tmux
      screen
    ];
  
    util = {
      basic = [
        tree
        file
        bzip2
      ];
  
      net = [
        tcpdump
        wget
      ];
  
      dev = [
        gitAndTools.gitFull
        gnumake
        autobuild
        autoconf
        automake
        gcc
        gdb
      ];
    };
  
    container = [
      lxc
      shadow
    ];
  
    font = [
      terminus_font
    ];
  
    application = [
      firefox
    ];
  
    display = [
      cantora.dmenu
      cantora.xinit
      cantora.dwm
    ];
  
    nix = [    
      nix-repl
    ];
  };

in categories // {
  all = recListConcat categories;
}
