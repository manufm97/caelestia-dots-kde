import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    // Plugin support is not wired up yet; always 0 for now
    readonly property int pluginCount: 0

    property string quickshellVersion
    property string cliVersion

    title: "Acerca de"

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // e.g. "Quickshell 0.3.0 (revision ...)"
        Process {
            running: true
            command: ["quickshell", "--version"]
            stdout: StdioCollector {
                onStreamFinished: root.quickshellVersion = text.trim().split(" ")[1] ?? ""
            }
        }

        // Parsed from the caelestia CLI's package listing; the sh wrapper avoids a
        // warning when the (optional) CLI isn't installed
        Process {
            running: true
            command: ["sh", "-c", "caelestia --version 2>/dev/null"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const m = text.match(/caelestia-cli\S*\s+(\d+(?:\.\d+)*)/);
                    root.cliVersion = m ? m[1] : "";
                }
            }
        }

        // Hero
        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: hero.implicitHeight + Tokens.padding.extraLarge * 2

            ColumnLayout {
                id: hero

                anchors.centerIn: parent
                width: parent.width - Tokens.padding.largeIncreased * 2
                spacing: Tokens.spacing.small

                AnimatedLogo {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Tokens.spacing.small
                    text: "Caelestia"
                    font: Tokens.font.headline.builders.large.width(110).build()
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: CUtils.version ? `v${CUtils.version}` : "…"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.medium
                }
            }
        }

        // System
        SectionHeader {
            text: "Sistema"
        }

        InfoRow {
            first: true
            label: "Nombre del equipo"
            value: SysInfo.hostname
        }

        InfoRow {
            label: "Dispositivo"
            value: SysInfo.device
        }

        InfoRow {
            label: "Distro"
            value: SysInfo.osPrettyName || SysInfo.osName
        }

        InfoRow {
            label: "Kernel"
            value: SysInfo.kernel
        }

        InfoRow {
            last: true
            label: "Firmware"
            value: SysInfo.firmware
        }

        // Software
        SectionHeader {
            text: "Software"
        }

        InfoRow {
            first: true
            label: "Shell"
            value: CUtils.version || "…"
        }

        InfoRow {
            label: "CLI"
            value: root.cliVersion || "…"
        }

        InfoRow {
            label: "Quickshell"
            value: root.quickshellVersion || "…"
        }

        InfoRow {
            last: true
            label: "Qt"
            value: CUtils.qtVersion || "…"
        }

        // Plugins
        SectionHeader {
            text: "Plugins"
        }

        InfoRow {
            first: true
            last: true
            label: "Plugins cargados"
            value: root.pluginCount.toString()
        }

        // Advanced
        SectionHeader {
            text: "Avanzado"
        }

        ToggleRow {
            first: true
            last: true
            text: "Modo depuración"
            subtext: "Activa registros detallados para depuración. Ejecuta 'caelestia shell -l' para verlos."
            checked: GlobalConfig.general.debugLogs
            onClicked: GlobalConfig.general.debugLogs = !GlobalConfig.general.debugLogs
        }
    }
}
