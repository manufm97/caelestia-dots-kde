import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    required property HyprlandToplevel client

    anchors.fill: parent
    spacing: Tokens.spacing.small

    Label {
        Layout.topMargin: Tokens.padding.extraLargeIncreased

        text: root.client?.title ?? "Sin cliente activo"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        font: Tokens.font.body.builders.large.weight(Font.Medium).build()
    }

    Label {
        text: root.client?.lastIpcObject.class ?? "Sin cliente activo"
        color: Colours.palette.m3tertiary

        font: Tokens.font.body.large
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.leftMargin: Tokens.padding.extraLargeIncreased
        Layout.rightMargin: Tokens.padding.extraLargeIncreased
        Layout.topMargin: Tokens.spacing.medium
        Layout.bottomMargin: Tokens.spacing.largeIncreased

        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "location_on"
        text: "Dirección: %1".arg(`0x${root.client?.address}` ?? "unknown")
        color: Colours.palette.m3primary
    }

    Detail {
        icon: "location_searching"
        text: "Posición: %1, %2".arg(root.client?.lastIpcObject.at[0] ?? -1).arg(root.client?.lastIpcObject.at[1] ?? -1)
    }

    Detail {
        icon: "resize"
        text: "Tamaño: %1 x %2".arg(root.client?.lastIpcObject.size[0] ?? -1).arg(root.client?.lastIpcObject.size[1] ?? -1)
        color: Colours.palette.m3tertiary
    }

    Detail {
        icon: "workspaces"
        text: "Espacio: %1 (%2)".arg(root.client?.workspace.name ?? -1).arg(root.client?.workspace.id ?? -1)
        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "desktop_windows"
        text: {
            const mon = root.client?.monitor;
            if (mon)
                return "Monitor: %1 (%2) en %3, %4".arg(mon.name).arg(mon.id).arg(mon.x).arg(mon.y);
            return "Monitor: desconocido";
        }
    }

    Detail {
        icon: "page_header"
        text: "Título inicial: %1".arg(root.client?.lastIpcObject.initialTitle ?? "unknown")
        color: Colours.palette.m3tertiary
    }

    Detail {
        icon: "category"
        text: "Clase inicial: %1".arg(root.client?.lastIpcObject.initialClass ?? "unknown")
    }

    Detail {
        icon: "account_tree"
        text: "ID del proceso: %1".arg(root.client?.lastIpcObject.pid ?? -1)
        color: Colours.palette.m3primary
    }

    Detail {
        icon: "picture_in_picture_center"
        text: "Flotante: %1".arg(root.client?.lastIpcObject.floating ? "yes" : "no")
        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "gradient"
        text: "Xwayland: %1".arg(root.client?.lastIpcObject.xwayland ? "yes" : "no")
    }

    Detail {
        icon: "keep"
        text: "Fijado: %1".arg(root.client?.lastIpcObject.pinned ? "yes" : "no")
        color: Colours.palette.m3secondary
    }

    Detail {
        icon: "fullscreen"
        text: {
            const fs = root.client?.lastIpcObject.fullscreen;
            if (fs)
                return "Estado de pantalla completa: %1".arg(fs == 0 ? "off" : fs == 1 ? "maximised" : "on");
            return "Estado de pantalla completa: desconocido";
        }
        color: Colours.palette.m3tertiary
    }

    Item {
        Layout.fillHeight: true
    }

    component Detail: RowLayout {
        id: detail

        required property string icon
        required property string text
        property alias color: icon.color

        Layout.leftMargin: Tokens.padding.large
        Layout.rightMargin: Tokens.padding.large
        Layout.fillWidth: true

        spacing: Tokens.spacing.medium

        MaterialIcon {
            id: icon

            Layout.alignment: Qt.AlignVCenter
            text: detail.icon
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: detail.text
            elide: Text.ElideRight
            font: Tokens.font.body.medium
        }
    }

    component Label: StyledText {
        Layout.leftMargin: Tokens.padding.large
        Layout.rightMargin: Tokens.padding.large
        Layout.fillWidth: true
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        animate: true
    }
}
