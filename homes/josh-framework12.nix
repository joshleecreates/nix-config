{ config, pkgs, lib, ... }:

# Josh's Framework 12 configuration - full desktop + Framework-specific

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../home/desktop.nix
    ../modules/home-manager/pi.nix
  ];

  # Desktop feature overrides
  modules.gaming.enable = true;
  modules.pi.enable = true;
  modules.zen-browser.enable = true;
  # Disable oh-my-zsh theme, use Starship instead
  programs.zsh.oh-my-zsh.theme = lib.mkForce "";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      palette = "rose_pine";

      palettes.rose_pine = {
        overlay = "#26233a";
        love = "#eb6f92";
        gold = "#f6c177";
        rose = "#ebbcba";
        pine = "#31748f";
        foam = "#9ccfd8";
        iris = "#c4a7e7";
        text = "#e0def4";
        subtle = "#908caa";
        muted = "#6e6a86";
        base = "#191724";
        surface = "#1f1d2e";
      };

      format = "$directory$git_branch$git_status$kubernetes$aws$character";

      directory = {
        style = "bold iris";
        format = "[$path]($style) ";
        truncation_length = 3;
      };

      git_branch = {
        style = "bold foam";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold love";
        format = "([$all_status$ahead_behind]($style) )";
      };

      kubernetes = {
        disabled = false;
        style = "bold pine";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      aws = {
        style = "bold gold";
        format = "[$symbol($profile )(\\($region\\) )]($style)";
      };

      character = {
        success_symbol = "[❯](bold rose)";
        error_symbol = "[❯](bold love)";
      };
    };
  };

  home.packages = with pkgs; [
    beekeeper-studio
    moonlight-qt
    claude-code
    owncloud-client
    vcluster
  ];
}
