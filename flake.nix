{
  description = "Sampelampans NixOS Flake";

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    grompt.url = "github:samhamnam/grompt";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  # 
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  # 
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # By default, NixOS will try to refer the nixosConfiguration with
      # its hostname, so the system named `nixos-test` will use this one.
      # However, the configuration name can also be specified using:
      #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
      #
      # The `nixpkgs.lib.nixosSystem` function is used to build this
      # configuration, the following attribute set is its parameter.
      #
      # Run the following command in the flake's directory to
      # deploy this configuration on any NixOS system:
      #   sudo nixos-rebuild switch --flake .#nixos-test
      "mango-lemma" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # The Nix module system can modularize configuration,
        # improving the maintainability of configuration.
        #
        # Each parameter in the `modules` is a Nix Module, and
        # there is a partial introduction to it in the nixpkgs manual:
        #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        # It is said to be partial because the documentation is not
        # complete, only some simple introductions.
        # such is the current state of Nix documentation...
        #
        # A Nix Module can be an attribute set, or a function that
        # returns an attribute set. By default, if a Nix Module is a
        # function, this function have the following default parameters:
        #
        #  lib:     the nixpkgs function library, which provides many
        #             useful functions for operating Nix expressions:
        #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
        #  config:  all config options of the current flake, every useful
        #  options: all options defined in all NixOS Modules
        #             in the current flake
        #  pkgs:   a collection of all packages defined in nixpkgs,
        #            plus a set of functions related to packaging.
        #            you can assume its default value is
        #            `nixpkgs.legacyPackages."${system}"` for now.
        #            can be customed by `nixpkgs.pkgs` option
        #  modulesPath: the default path of nixpkgs's modules folder,
        #               used to import some extra modules from nixpkgs.
        #               this parameter is rarely used,
        #               you can ignore it for now.
        #
        # The default parameters mentioned above are automatically
        # generated by Nixpkgs. 
        # However, if you need to pass other non-default parameters
        # to the submodules, 
        # you'll have to manually configure these parameters using
        # `specialArgs`. 
        # you must use `specialArgs` by uncomment the following line:
        #
        # specialArgs = {...};  # pass custom arguments into all sub module.
        specialArgs = { inherit inputs; };
        modules = [
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nix Module,
          ./configuration.nix
          home-manager.nixosModules.home-manager 
          { 
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lemma = import ./home.nix;
          }
        ];
      };
    };
  };
}