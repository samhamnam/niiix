flimpy: { pkgs, ... }: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  home.packages = with pkgs; [
    firefox
    (vscode-with-extensions.override {
      vscodeExtensions = with flimpy.inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
        golang.go
        rust-lang.rust-analyzer
        teabyii.ayu
        serayuzgur.crates
        icrawl.discord-vscode
        pkief.material-icon-theme
        jnoortheen.nix-ide
        thenuprojectcontributors.vscode-nushell-lang
      ];
    }
    )
    thunderbird
    discord
    nixpkgs-fmt
    stremio
    neofetch
  ];
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "Samuel Hammersberg";
    userEmail = "samuel.hammersberg@gmail.com";
    includes = [
      { path = "~/.gitconfig.local"; }
    ];
  };

  xdg.configFile."nushell/config.nu".source = ./nushell/config.nu;
  xdg.configFile."Code/User/settings.json".source = ./code/settings.json;
  xdg.configFile."Code/User/keybindings.json".source = ./code/keybindings.json;

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.05";
}