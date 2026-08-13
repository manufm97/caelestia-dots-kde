import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property PopoutState popouts

    readonly property real masterScale: !isNaN(GlobalConfig.bar.previewScale) ? GlobalConfig.bar.previewScale : 1.0
    readonly property real elementOffset: GlobalConfig.bar.perElementPreviewScale ? (!isNaN(GlobalConfig.bar.previewScales.weather) ? GlobalConfig.bar.previewScales.weather : 0.0) : 0.0
    readonly property real barScaleOffset: GlobalConfig.bar.previewScaleWithBar ? (!isNaN(GlobalConfig.bar.scale) ? GlobalConfig.bar.scale : 1.0) : 1.0
    readonly property real scaleOffset: Math.max(0.1, (masterScale + elementOffset) * barScaleOffset)

    implicitWidth: column.implicitWidth + Tokens.padding.large * 2
    implicitHeight: column.implicitHeight + Tokens.padding.large * 2

    ColumnLayout {
        id: column

        anchors.centerIn: parent
        spacing: Tokens.spacing.medium

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Weather.city
            font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
            color: Colours.palette.m3primary
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: `${Weather.description} - ${Weather.temp}`
            font: Tokens.font.body.small
            color: Colours.palette.m3secondary
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colours.palette.m3outlineVariant
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "Pronóstico de 7 días"
            font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
            color: Colours.palette.m3primary
        }

        ColumnLayout {
            id: dailyForecastColumn

            spacing: Tokens.spacing.small

            Repeater {
                model: Weather.forecast

                delegate: RowLayout {
                    required property int index
                    required property var modelData

                    Layout.preferredWidth: 300
                    spacing: Tokens.spacing.medium

                    StyledText {
                        Layout.preferredWidth: 80
                        text: index === 0 ? "Hoy" : new Date(modelData.date).toLocaleDateString(Qt.locale(), "ddd")
                        font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
                        color: Colours.palette.m3primary
                    }

                    StyledText {
                        Layout.preferredWidth: 60
                        text: new Date(modelData.date).toLocaleDateString(Qt.locale(), "MMM d")
                        font: Tokens.font.body.small
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    MaterialIcon {
                        Layout.alignment: Qt.AlignVCenter
                        text: modelData.icon
                        fontStyle: Tokens.font.icon.builders.small.build()
                        color: Colours.palette.m3secondary
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignVCenter
                        text: `${Weather.formatTemp(modelData.minTempC).slice(0, -1)} / ${Weather.formatTemp(modelData.maxTempC).slice(0, -1)}`
                        font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
                        color: Colours.palette.m3onSurface
                    }
                }
            }
        }
    }
}
