{ config, lib, pkgs, zen-browser-pkg, ... }:

with lib;

let
  cfg = config.modules.zen-browser;
in {
  options.modules.zen-browser = {
    enable = mkEnableOption "Zen Browser";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.wrapFirefox zen-browser-pkg {
        extraPolicies = {
          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
          ExtensionSettings = {
            # 1Password extension
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            };
          };
        };

        extraPrefs = ''
          // Disable telemetry
          lockPref("browser.newtabpage.activity-stream.feeds.telemetry", false);
          lockPref("browser.newtabpage.activity-stream.telemetry", false);
          lockPref("browser.ping-centre.telemetry", false);
          lockPref("toolkit.telemetry.archive.enabled", false);
          lockPref("toolkit.telemetry.bhrPing.enabled", false);
          lockPref("toolkit.telemetry.enabled", false);
          lockPref("toolkit.telemetry.firstShutdownPing.enabled", false);
          lockPref("toolkit.telemetry.hybridContent.enabled", false);
          lockPref("toolkit.telemetry.newProfilePing.enabled", false);
          lockPref("toolkit.telemetry.reportingpolicy.firstRun", false);
          lockPref("toolkit.telemetry.shutdownPingSender.enabled", false);
          lockPref("toolkit.telemetry.unified", false);
          lockPref("toolkit.telemetry.updatePing.enabled", false);

          // Disable Pocket
          lockPref("extensions.pocket.enabled", false);

          // Privacy settings
          defaultPref("privacy.trackingprotection.enabled", true);
          defaultPref("dom.security.https_only_mode", true);

          // Wayland integration
          defaultPref("widget.use-xdg-desktop-portal.file-picker", 1);
          defaultPref("widget.use-xdg-desktop-portal.mime-handler", 1);
        '';

        extraPrefsFiles = [
          (pkgs.writeText "zen-search-engines.js" ''
            // DuckDuckGo as default search engine
            defaultPref("browser.search.defaultenginename", "DuckDuckGo");
            defaultPref("browser.search.order.1", "DuckDuckGo");
          '')
        ];
      })
    ];

    # Configure DuckDuckGo and @nix search via policies.json
    xdg.configFile."zen-browser/policies/policies.json".text = builtins.toJSON {
      policies = {
        SearchEngines = {
          Default = "DuckDuckGo";
          Add = [
            {
              Name = "Nix Packages";
              Description = "Search NixOS packages";
              Alias = "@nix";
              Method = "GET";
              URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
            }
          ];
        };
      };
    };
  };
}
