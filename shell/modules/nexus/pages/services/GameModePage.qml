import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.images
import qs.utils
import qs.services
import qs.modules.nexus.common
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Caelestia

PageBase {
    id: root

    title: "Modo juego"
    isSubPage: true

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: "Reglas de autoactivación"
        }

        ToggleRow {
            first: true
            text: "Activar automáticamente"
            subtext: "Activar modo juego cuando una ventana objetivo esté enfocada o ejecutándose"
            checked: GlobalConfig.utilities.gameMode.autoEnable
            onToggled: GlobalConfig.utilities.gameMode.autoEnable = checked
        }

        NavRow {
            last: true
            icon: "ads_click"
            label: qsTr("Target windows")
            status: qsTr("Add or remove auto-enable targets")
            onClicked: root.nState.openSubPage(2)
        }

        Column {
            Layout.fillWidth: true
            spacing: root.spacing
            visible: Quickshell.env("XDG_CURRENT_DESKTOP").includes("Hyprland")

            SectionHeader {
                text: "Anulaciones de Hyprland"
            }

            ToggleRow {
                Layout.fillWidth: true
                first: true
                text: "Desactivar animaciones"
                checked: GlobalConfig.utilities.gameMode.disableHyprlandAnimations
                onToggled: GlobalConfig.utilities.gameMode.disableHyprlandAnimations = checked
            }
            ToggleRow {
                Layout.fillWidth: true
                text: "Desactivar desenfoque"
                checked: GlobalConfig.utilities.gameMode.disableHyprlandBlur
                onToggled: GlobalConfig.utilities.gameMode.disableHyprlandBlur = checked
            }
            ToggleRow {
                Layout.fillWidth: true
                text: "Desactivar espacios y esquinas"
                checked: GlobalConfig.utilities.gameMode.disableHyprlandGaps
                onToggled: GlobalConfig.utilities.gameMode.disableHyprlandGaps = checked
            }
            ToggleRow {
                Layout.fillWidth: true
                text: "Desactivar sombras"
                checked: GlobalConfig.utilities.gameMode.disableHyprlandShadows
                onToggled: GlobalConfig.utilities.gameMode.disableHyprlandShadows = checked
            }
            ToggleRow {
                Layout.fillWidth: true
                text: "Desactivar transparencia de ventanas"
                last: true
                checked: GlobalConfig.utilities.gameMode.disableWindowTransparency
                onToggled: GlobalConfig.utilities.gameMode.disableWindowTransparency = checked
            }
        }

        SectionHeader {
            text: "Anulaciones de funciones de Caelestia"
        }

        ToggleRow {
            first: true
            text: "Desactivar transparencia del shell"
            checked: GlobalConfig.utilities.gameMode.disableShellTransparency
            onToggled: GlobalConfig.utilities.gameMode.disableShellTransparency = checked
        }
        ToggleRow {
            text: "Desactivar transparencia de notificaciones toast"
            checked: GlobalConfig.utilities.gameMode.disableToastTransparency
            onToggled: GlobalConfig.utilities.gameMode.disableToastTransparency = checked
        }
        ToggleRow {
            text: "Desactivar letras en escritorio"
            checked: GlobalConfig.utilities.gameMode.disableDesktopLyrics
            onToggled: GlobalConfig.utilities.gameMode.disableDesktopLyrics = checked
        }
        ToggleRow {
            text: "Desactivar visualizador"
            checked: GlobalConfig.utilities.gameMode.disableVisualizer
            onToggled: GlobalConfig.utilities.gameMode.disableVisualizer = checked
        }
        ToggleRow {
            text: "Desactivar mascotas shimeji"
            last: true
            checked: GlobalConfig.utilities.gameMode.disableShimeji
            onToggled: GlobalConfig.utilities.gameMode.disableShimeji = checked
        }
    }
}
