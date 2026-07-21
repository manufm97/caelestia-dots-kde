pragma ComponentBehavior: Bound

import QtQuick.Layouts
import Caelestia.Config
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: "Iconos de estado"
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Visible icons
        SectionHeader {
            first: true
            text: "Iconos visibles"
        }

        ToggleRow {
            first: true
            text: "Altavoces"
            checked: Config.bar.status.showAudio
            onToggled: GlobalConfig.bar.status.showAudio = checked
        }

        ToggleRow {
            text: "Micrófono"
            checked: Config.bar.status.showMicrophone
            onToggled: GlobalConfig.bar.status.showMicrophone = checked
        }

        ToggleRow {
            text: "Distribución del teclado"
            checked: Config.bar.status.showKbLayout
            onToggled: GlobalConfig.bar.status.showKbLayout = checked
        }

        ToggleRow {
            text: "Red"
            checked: Config.bar.status.showNetwork
            onToggled: GlobalConfig.bar.status.showNetwork = checked
        }

        ToggleRow {
            text: "Wi-Fi"
            checked: Config.bar.status.showWifi
            onToggled: GlobalConfig.bar.status.showWifi = checked
        }

        ToggleRow {
            text: "Bluetooth"
            checked: Config.bar.status.showBluetooth
            onToggled: GlobalConfig.bar.status.showBluetooth = checked
        }

        ToggleRow {
            text: "Batería"
            checked: Config.bar.status.showBattery
            onToggled: GlobalConfig.bar.status.showBattery = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Batería periféricos"
            checked: Config.bar.status.showPeripheralBattery
            onToggled: GlobalConfig.bar.status.showPeripheralBattery = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Bloq Mayús"
            checked: Config.bar.status.showLockStatus
            onToggled: GlobalConfig.bar.status.showLockStatus = checked
        }
        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: "Notificaciones"
            checked: Config.bar.status.showNotifications
            onToggled: GlobalConfig.bar.status.showNotifications = checked
        }

        // Behaviour
        SectionHeader {
            text: Strings.localizeEnglishSpelling("Comportamiento")
        }

        ToggleRow {
            first: true
            last: true
            text: "Ventana emergente al pasar"
            subtext: "Mostrar detalles al pasar sobre iconos"
            checked: Config.bar.popouts.statusIcons
            onToggled: GlobalConfig.bar.popouts.statusIcons = checked
        }
    }
}
