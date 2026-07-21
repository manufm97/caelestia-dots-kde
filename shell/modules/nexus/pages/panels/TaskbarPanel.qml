pragma ComponentBehavior: Bound

import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property list<MenuItem> positionItems: [
        MenuItem {
            property string value: "top"

            text: "Arriba"
        },
        MenuItem {
            property string value: "bottom"

            text: "Abajo"
        },
        MenuItem {
            property string value: "left"

            text: "Izquierda"
        },
        MenuItem {
            property string value: "right"

            text: "Derecha"
        }
    ]

    title: "Barra de tareas"
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Behaviour
        SectionHeader {
            first: true
            text: Strings.localizeEnglishSpelling("Comportamiento")
        }

        ToggleRow {
            first: true
            text: "Persistente"
            subtext: "Mantener la barra siempre visible"
            checked: GlobalConfig.bar.persistent
            onToggled: GlobalConfig.bar.persistent = checked
        }

        SelectRow {
            Layout.fillWidth: true
            label: "Posición"
            subtext: "Borde de la pantalla donde colocar la barra"
            active: {
                for (let i = 0; i < positionItems.length; i++) {
                    if (positionItems[i].value === GlobalConfig.bar.position)
                        return positionItems[i];
                }
                return positionItems[0];
            }
            menuItems: positionItems
            onSelected: item => GlobalConfig.bar.position = item.value
        }

        ToggleRow {
            text: "Mostrar al pasar"
            subtext: "Revelar la barra al llegar al borde"
            checked: GlobalConfig.bar.showOnHover
            onToggled: GlobalConfig.bar.showOnHover = checked
        }

        StepperRow {
            last: true
            label: qsTr("Drag threshold")
            subtext: qsTr("Pixels dragged before the bar reveals")
            value: GlobalConfig.bar.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.bar.dragThreshold = v
        }

        SectionHeader {
            text: Strings.localizeEnglishSpelling(qsTr("Scaling"))
        }

        StepperRow {
            first: true
            label: qsTr("Bar scale")
            subtext: qsTr("Scales taskbar thickness and component sizing")
            value: GlobalConfig.bar.scale
            from: 0.6
            to: 1.6
            stepSize: 0.05
            onMoved: v => GlobalConfig.bar.scale = v
        }

        StepperRow {
            label: "Escala de vista previa"
            subtext: "Escala las vistas previas al pasar"
            value: GlobalConfig.bar.previewScale
            from: 0.5
            to: 1.6
            stepSize: 0.05
            onMoved: v => GlobalConfig.bar.previewScale = v
        }

        ToggleRow {
            text: "Escalar con el tamaño de la barra"
            subtext: "Multiplica la escala de vista previa con la de la barra"
            checked: GlobalConfig.bar.previewScaleWithBar
            onToggled: GlobalConfig.bar.previewScaleWithBar = checked
        }

        StepperRow {
            label: "Ajuste de escala de fuente"
            subtext: "Escala el texto en ventanas emergentes"
            value: GlobalConfig.bar.fontScaleOffset
            from: -1.0; to: 1.0; stepSize: 0.05
            onMoved: v => GlobalConfig.bar.fontScaleOffset = v
        }

        NavRow {
            last: true
            icon: "aspect_ratio"
            label: qsTr("Per-element scaling offsets")
            status: qsTr("Customize scale and font for each popout type")
            onClicked: root.nState.openSubPage(14)
        }

        // Components
        SectionHeader {
            text: "Componentes"
        }

        NavRow {
            first: true
            icon: "view_agenda"
            label: qsTr("Toggle & Rearrange")
            status: qsTr("Add, remove or reorder components")
            onClicked: root.nState.openSubPage(6)
        }

        NavRow {
            last: true
            icon: "tune"
            label: qsTr("Elements & Modules")
            status: qsTr("Workspaces, tray, status icons, clock, dock and more")
            onClicked: root.nState.openSubPage(15)
        }

        // Scroll actions
        SectionHeader {
            text: "Acciones de scroll"
        }

        ToggleRow {
            first: true
            text: "Espacios de trabajo"
            subtext: "Desplázate sobre el indicador para cambiar de espacio"
            checked: GlobalConfig.bar.scrollActions.workspaces
            onToggled: GlobalConfig.bar.scrollActions.workspaces = checked
        }

        ToggleRow {
            text: "Volumen"
            subtext: "Desplázate en la mitad superior de la barra para ajustar volumen"
            checked: GlobalConfig.bar.scrollActions.volume
            onToggled: GlobalConfig.bar.scrollActions.volume = checked
        }

        ToggleRow {
            last: true
            text: "Brillo"
            subtext: "Desplázate en la mitad inferior de la barra para ajustar brillo"
            checked: GlobalConfig.bar.scrollActions.brightness
            onToggled: GlobalConfig.bar.scrollActions.brightness = checked
        }
    }
}
