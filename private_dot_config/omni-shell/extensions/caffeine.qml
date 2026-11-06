import QtQuick
import Quickshell
import Quickshell.Io

// sleep+idle inhibitor: blocks suspend and every hypridle listener while held
QtObject {
    property string label: "Always On"
    property string subtitle: ""
    property string glyph: "\u2615"
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