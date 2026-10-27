import QtQuick
import Quickshell
import Quickshell.Io

// "Keep always on" tile: toggles a systemd sleep+idle inhibitor.
// While held: logind will not suspend (block mode), and hypridle skips
// every idle listener (dim / lock / screen-off / suspend) since they all
// run with ignore_inhibit=false. Releasing the Process kills the fd and
// normal idle behaviour resumes.
QtObject {
    property string label: "Always On"
    property string subtitle: ""
    property string glyph: "\u2615" // U+2615 HOT BEVERAGE - the user chose it
    property string mnemonic: "K"
    property bool active: inhibitor.running
    property bool closesPanel: false

    function activate() {
        inhibitor.running = !inhibitor.running;
    }

    property Process inhibitor: Process {
        command: [
            "systemd-inhibit",
            "--what=idle:sleep",
            "--who=Caffeine",
            "--why=Keep always on (omni-shell tile)",
            "sleep", "infinity"
        ]
    }
}