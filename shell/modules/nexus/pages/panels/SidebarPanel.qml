pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: "Barra lateral"
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.large

        SectionHeader {
            first: true
            text: "General"
        }

        ToggleRow {
            first: true
            text: "Activado"
            checked: Config.sidebar.enabled
            onToggled: GlobalConfig.sidebar.enabled = checked
        }

        StepperRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            last: true
            label: "Umbral de arrastre"
            subtext: "Píxeles arrastrados antes de abrir la barra lateral"
            value: Config.sidebar.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.sidebar.dragThreshold = v
        }

        // Sidebar Tabs
        SectionHeader {
            text: "Pestañas de barra lateral"
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: "Mostrar pestaña de noticias"
            subtext: "Mostrar noticias en la barra lateral"
            checked: GlobalConfig.ai.showNews
            onToggled: GlobalConfig.ai.showNews = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            last: true
            text: "Mostrar Modo Caelestia"
            subtext: "Mostrar Modo Caelestia al final de notificaciones"
            checked: GlobalConfig.ai.showCaelestiaMode
            onToggled: GlobalConfig.ai.showCaelestiaMode = checked
        }
    }
}
