pragma Singleton
import QtQuick

QtObject {
    property string mode: "light"
    property bool systemDark: Qt.application && Qt.application.styleHints ? Qt.application.styleHints.colorScheme === Qt.ColorScheme.Dark : false
    property bool dark: mode === "dark" || (mode === "system" && systemDark)

    property color background: dark ? "#0F1115" : "#F6F7FB"
    property color surface: dark ? "#151923" : "#FFFFFF"
    property color surfaceAlt: dark ? "#1B2030" : "#F0F2F7"
    property color card: dark ? "#171C28" : "#FFFFFF"
    property color cardHover: dark ? "#1C2233" : "#F7F8FC"
    property color text: dark ? "#E8EAF0" : "#1E2330"
    property color textMuted: dark ? "#AAB2C0" : "#5B6372"
    property color textSubtle: dark ? "#8891A1" : "#7A8291"
    property color border: dark ? "#2A3142" : "#E3E6EE"
    property color primary: dark ? "#5B8CFF" : "#2F6BFF"
    property color primaryStrong: dark ? "#3F6FE0" : "#1D4ED8"
    property color primaryOn: "#FFFFFF"
    property color highlight: dark ? "#22314D" : "#E9F1FF"
    property color success: dark ? "#36C28A" : "#16A34A"
    property color warning: dark ? "#F5A524" : "#F59E0B"
}
