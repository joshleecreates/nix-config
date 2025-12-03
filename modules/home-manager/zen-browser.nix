{ config, lib, pkgs, zen-browser-pkg, ... }:

with lib;

let
  cfg = config.modules.zen-browser;
in {
  options.modules.zen-browser = {
    enable = mkEnableOption "Zen Browser with custom configuration";
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

          // Theme and transparency settings
          defaultPref("widget.use-xdg-desktop-portal.file-picker", 1);
          defaultPref("widget.use-xdg-desktop-portal.mime-handler", 1);
          defaultPref("browser.theme.toolbar-theme", 2); // 0=light, 1=dark, 2=system
          defaultPref("browser.theme.content-theme", 2); // 0=light, 1=dark, 2=system
          defaultPref("ui.systemUsesDarkTheme", 1); // Force dark theme
          defaultPref("widget.content.allow-gtk-dark-theme", true);
          defaultPref("widget.disable-workspace-management", true);

          // Transparent Zen mod preferences (by sameerasw)
          // Use lockPref for critical transparency settings to prevent user override
          lockPref("browser.tabs.allow_transparent_browser", true);
          lockPref("zen.widget.linux.transparency", true);
          defaultPref("zen.view.grey-out-inactive-windows", false);
          defaultPref("mod.sameerasw.zen_transparent_sidebar_enabled", true);
          defaultPref("mod.sameerasw.zen_transparent_glance_enabled", true);
          lockPref("mod.sameerasw.zen_bg_color_enabled", true);
          lockPref("mod.sameerasw.zen_transparency_color", "#00000000");
          defaultPref("mod.sameerasw_zen_light_tint", "2");
          defaultPref("mod.sameerasw.zen_no_shadow", false);
          lockPref("mod.sameerasw.zen_bg_img_enabled", false);
          defaultPref("mod.sameerasw.zen_tab_switch_anim", true);
          defaultPref("mod.sameerasw_zen_compact_sidebar_type", "0");
          defaultPref("mod.sameerasw.zen_compact_sidebar_width", "165px");
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

    # XDG portal configuration for file picker
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.config.common.default = "*";

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

    # NOTE: Zen Browser uses ZenMods system for theming, not userChrome.css
    # The Transparent Zen mod should be installed via Zen's built-in mod manager
    # Transparency preferences are configured above in extraPrefs
  };
}
