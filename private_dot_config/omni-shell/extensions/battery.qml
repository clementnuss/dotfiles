import QtQuick
import Quickshell.Io

// Stand-in for the bar's Battery module, which hardcodes BAT0 (this machine has BAT1).
QtObject {
    id: root
    property string label: "Battery"
    property string subtitle: "…"
    property string glyph: String.fromCodePoint(0xF0079)
    property bool active: false
    property bool closesPanel: false

    function activate() { poll.running = true; }

    property Process poll: Process {
        running: true
        // capacity status watts; current_now µA × voltage_now µV
        command: ["sh", "-c", "b=$(ls -d /sys/class/power_supply/BAT* | head -n1); [ -n \"$b\" ] || exit; awk -v c=\"$(cat $b/capacity)\" -v s=\"$(cat $b/status)\" -v i=\"$(cat $b/current_now)\" -v u=\"$(cat $b/voltage_now)\" 'BEGIN{printf \"%s %s %.1f\\n\", c, s, i*u/1e12}'"]
        stdout: SplitParser {
            onRead: data => {
                var f = data.trim().split(" ");
                if (f.length < 3) return;
                var cap = parseInt(f[0]), status = f.slice(1, -1).join(" "), w = f[f.length - 1];
                root.active = status === "Charging";
                root.label = cap + "%";
                root.subtitle = status === "Discharging" ? w + " W" : status;
                root.glyph = String.fromCodePoint(status === "Charging" ? 0xF0084
                    : cap >= 90 ? 0xF0079 : 0xF007A + Math.max(0, Math.floor(cap / 10) - 1));
            }
        }
    }

    property Timer timer: Timer {
        interval: 30000; running: true; repeat: true
        onTriggered: root.poll.running = true
    }
}
