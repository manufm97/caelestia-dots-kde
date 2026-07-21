pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property var bar

    readonly property color colour: Colours.palette.m3tertiary
    readonly property int padding: Tokens.padding.medium
    readonly property int barThickness: Math.round(Tokens.sizes.bar.innerWidth * Math.max(0.6, !isNaN(Config.bar.scale) ? Config.bar.scale : 1.0))

    readonly property bool isHorizontal: Config.bar.position === "top" || Config.bar.position === "bottom"

    implicitWidth: isHorizontal ? layout.implicitWidth + root.padding * 2 : barThickness
    implicitHeight: isHorizontal ? barThickness : layout.implicitHeight + root.padding * 2

    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0)
    radius: Tokens.rounding.full

    Component.onCompleted: Weather.reload()

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            const popouts = root.bar.popouts;
            if (popouts.hasCurrent && popouts.currentName === "weather") {
                popouts.hasCurrent = false;
            } else {
                popouts.currentName = "weather";
                popouts.currentCenter = isHorizontal ? root.mapToItem(null, root.implicitWidth / 2, 0).x : root.mapToItem(null, 0, root.implicitHeight / 2).y;
                popouts.hasCurrent = true;
            }
        }
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Tokens.spacing.extraSmall

        MaterialIcon {
            Layout.alignment: Qt.AlignVCenter
            animate: true
            text: Weather.icon
            color: root.colour
            fontStyle: Tokens.font.icon.builders.small.build()
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            animate: true
            text: Weather.temp
            font: Tokens.font.body.small
            color: root.colour
        }
    }
}
