{
  description = "Big Neovim Energy";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    nur.url = github:nix-community/NUR;

    neovim = {
      url = github:neovim/neovim?dir=contrib;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    formatter-nvim = { url = github:mhartington/formatter.nvim; flake = false; };
    galaxyline-nvim = { url = github:glepnir/galaxyline.nvim; flake = false; };
    lspkind-nvim = { url = github:onsails/lspkind-nvim; flake = false; };
    lush-nvim = { url = github:rktjmp/lush.nvim; flake = false; };
    nvim-compe = { url = github:hrsh7th/nvim-compe; flake = false; };
    nvim-lspconfig = { url = github:neovim/nvim-lspconfig; flake = false; };
    scrollbar-nvim = { url = github:Xuyuanp/scrollbar.nvim; flake = false; };
    snippets-nvim = { url = github:norcalli/snippets.nvim; flake = false; };
    vim-dadbod-ui = { url = github:kristijanhusak/vim-dadbod-ui; flake = false; };
    vim-prisma = { url = github:pantharshit00/vim-prisma; flake = false; };

  };

  outputs = { self, nixpkgs, neovim, flake-utils, nur, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        vim-plugins-overlay = import ./vim-plugins-overlay.nix;
        neovitality-overlay = import ./neovitality-overlay.nix;

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            (vim-plugins-overlay inputs)
            (neovitality-overlay { pkgs = pkgs; })
            nur.overlay
            (final: prev: {
              neovim-nightly = neovim.defaultPackage.${system};
            })
          ];
        };
      in
      rec {
        defaultPackage = pkgs.neovitality;

        apps = {
          nvim = flake-utils.lib.mkApp {
            drv = pkgs.neovitality;
            name = "nvim";
          };
        };

        defaultApp = apps.nvim;
      }
    );
}
