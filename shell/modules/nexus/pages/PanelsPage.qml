import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: "Paneles"

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        NavRow {
            first: true
            icon: "dashboard"
            label: "Panel principal"
            status: Config.dashboard.enabled ? "Activado" : "Desactivado"
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "dock_to_bottom"
            label: "Barra de tareas"
            status: Config.bar.persistent ? "Siempre visible" : Config.bar.showOnHover ? "Mostrar al pasar" : "Mostrar al arrastrar"
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "apps"
            label: "Lanzador"
            status: Config.launcher.enabled ? "Activado" : "Desactivado"
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            last: true
            icon: "dock_to_right"
            label: "Barra lateral"
            status: Config.sidebar.enabled ? "Activado" : "Desactivado"
            onClicked: root.nState.openSubPage(4)
        }
    }
}
