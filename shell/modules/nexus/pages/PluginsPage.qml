pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.modules.nexus.common

PageBase {
    id: root
    
    title: "Plugins"

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            text: "Actualizaciones automáticas"
        }

        ToggleRow {
            first: true
            last: true
            text: "Buscar actualizaciones en segundo plano"
            subtext: "Buscar actualizaciones de Caelestia periódicamente"
            checked: GlobalConfig.general.checkUpdates
            onClicked: GlobalConfig.general.checkUpdates = !GlobalConfig.general.checkUpdates
        }

        SectionHeader {
            text: "Plugins instalados"
        }

        ConnectedRect {
            first: true
            last: true
            Layout.fillWidth: true
            implicitHeight: Tokens.padding.extraLarge * 4

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.padding.extraSmall

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "extension"
                    color: Colours.palette.m3outlineVariant
                    fontStyle: Tokens.font.icon.extraLarge
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Sin plugins de terceros instalados"
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.body.large
                }
            }
        }
    }
}
