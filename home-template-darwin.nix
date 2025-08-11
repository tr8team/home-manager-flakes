{ config, pkgs, atomi, user_config, ... }:

##############################
# Import additional modules  #
##############################

let lib = import ./lib.nix { inherit pkgs; }; in
with (with lib;{ inherit zshCustomPlugins liveAutoComplete; });
with pkgs;
with atomi;

let
  output = {
    # Allow only the unfree package we need
    nixpkgs.config.allowUnfreePredicate = pkg: pkgs.lib.elem (pkgs.lib.getName pkg) [
      "claude-code"
    ];
    home.stateVersion = "25.05";
    home.username = "${user_config.user}";
    home.homeDirectory = "/Users/${user_config.user}";

    #########################
    # Install packages here #
    #########################
    home.packages = [
      # System requirements
      coreutils

      # ESD Tooling
      kubernetes-helm
      kubelogin-oidc
      cachix
      kubectl
      docker
      claude-code
    ];
    ##################################################
    # Addtional environment variables for your shell #
    ##################################################
    home.sessionVariables = { };

    #################################
    # Addtional PATH for your shell #
    #################################
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.krew/bin"
    ];

    ##########################
    # Program Configurations #
    ##########################
    programs = {

      # Git Configurations
      git = {
        enable = true;
        userEmail = "${user_config.email}";
        userName = "${user_config.gituser}";
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = "true";
        };
        lfs = {
          enable = true;
        };
      };

      # Shell Configurations
      zsh = {

        enable = true;
        enableCompletion = false;

        # Add ~/.zshrc here
        initContent = "";

        # Oh-my-zsh configurations
        oh-my-zsh = {
          enable = true;
          extraConfig = ''
            ZSH_CUSTOM="${zshCustomPlugins}"
            zstyle ':completion:*:*:man:*:*' menu select=long search
            zstyle ':autocomplete:*' recent-dirs zoxide
          '';
          plugins = [
            "git"
            "docker"
            "kubectl"
            "pls"
            "aws"
          ];
        };

        # Aliases
        shellAliases = {
          hms = "nix run home-manager/release-25.05 -- switch";
          hmsz = "nix run home-manager/release-25.05 -- switch && source ~/.zshrc";
          configterm = "POWERLEVEL9K_CONFIG_FILE=\"$HOME/home-manager-config/p10k-config/.p10k.zsh\" p10k configure";
        };

        plugins = [
          # p10k config
          {
            name = "powerlevel10k-config";
            src = ./p10k-config;
            file = ".p10k.zsh";
          }
          # live autocomplete
          liveAutoComplete
        ];

        # ZSH ZPlug Plugins
        zplug = {
          enable = true;
          plugins = [
            # alt j to do JQ querry
            {
              name = "reegnz/jq-zsh-plugin";
            }
            # make sound when commands longer than 15 seconds completed
            {
              name = "kevinywlui/zlong_alert.zsh";
            }
            # remind you you have aliases
            {
              name = "djui/alias-tips";
            }
            # themes
            {
              name = "romkatv/powerlevel10k";
              tags = [ as:theme depth:1 ];
            }
          ];
        };
      };

      # Enable GPG
      gpg = {
        enable = true;
      };

      # Enable SSH
      ssh = {
        enable = true;
      };

      # Enable bat
      bat = {
        enable = true;
      };

      # enable exa
      eza = {
        enable = true;
        enableZshIntegration = true;
      };

      # enable fzf
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      # enable zoxide
      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ];
      };
    };
  };
in
output
