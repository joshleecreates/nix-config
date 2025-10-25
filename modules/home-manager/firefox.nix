{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.firefox;
in {
  options.modules.firefox = {
    enable = mkEnableOption "Firefox with privacy-focused settings";

    onePasswordIntegration = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 1Password native messaging integration";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts = mkIf cfg.onePasswordIntegration [ pkgs._1password-gui ];
      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          # Disable sponsored content and recommendations
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;

          # Disable Pocket
          "extensions.pocket.enabled" = false;
          "extensions.pocket.showHome" = false;

          # Disable telemetry
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

          # Disable studies
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";

          # Disable crash reports
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          # Privacy improvements
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;

          # Clean new tab page
          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.enabled" = false;

          # Disable annoying features
          "browser.vpn_promo.enabled" = false;
          "browser.promo.focus.enabled" = false;
          "browser.aboutwelcome.enabled" = false;
        };
      };
    };
  };
}
