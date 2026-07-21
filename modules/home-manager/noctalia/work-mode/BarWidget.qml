import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

// Work Mode toggle bar widget.
// Modeled on Modules/Bar/Widgets/KeepAwake.qml; receives `pluginApi` from BarWidgetLoader.
// Toggling flips the noctalia color scheme via IPC: off -> Gruvbox, on -> Nord.
Item {
  id: root

  // Injected by BarWidgetLoader
  property ShellScreen screen
  property var pluginApi
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  readonly property string offScheme: "Gruvbox"
  readonly property string onScheme: "Nord"
  readonly property bool active: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.enabled === true : false

  implicitWidth: pill.width
  implicitHeight: pill.height

  function applyScheme(name) {
    Quickshell.execDetached(["noctalia-shell", "ipc", "call", "colorScheme", "set", name]);
  }

  // If work mode was left on across a restart, restore its scheme. The off state
  // already matches the nix-declared default scheme, so nothing to do there.
  Component.onCompleted: {
    if (root.active)
      applyScheme(root.onScheme);
  }

  BarPill {
    id: pill

    screen: root.screen
    oppositeDirection: BarService.getPillDirection(root)
    icon: root.active ? "briefcase" : "briefcase-off"
    tooltipText: root.active ? "Work Mode: on" : "Work Mode: off"

    onClicked: {
      var newState = !root.active;
      if (root.pluginApi) {
        root.pluginApi.pluginSettings.enabled = newState;
        root.pluginApi.saveSettings();
      }
      root.applyScheme(newState ? root.onScheme : root.offScheme);
    }
  }
}
