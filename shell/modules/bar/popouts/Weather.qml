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
            text: "Pronóstico por hora"
            font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
            color: Colours.palette.m3primary
        }

        Flow {
            id: forecastFlow

            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Repeater {
                model: Weather.hourlyForecast

                delegate: ColumnLayout {
                    required property var modelData
                    required property int index

                    spacing: Tokens.spacing.extraSmall

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            const h = modelData.hour;
                            if (h === 0) return "12 AM";
                            if (h < 12) return `${h} AM`;
                            if (h === 12) return "12 PM";
                            return `${h - 12} PM`;
                        }
                        font: Tokens.font.body.builders.small.weight(Font.DemiBold).build()
                        color: Colours.palette.m3primary
                    }

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.icon
                        color: Colours.palette.m3secondary
                        fontStyle: Tokens.font.icon.builders.small.build()
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: `${modelData.tempC}°`
                        font: Tokens.font.body.small
                        color: Colours.palette.m3tertiary
                    }

                    Loader {
                        Layout.alignment: Qt.AlignHCenter
                        active: modelData.precipChance !== undefined && modelData.precipChance > 0
                        visible: active

                        sourceComponent: StyledText {
                            text: `${modelData.precipChance}%`
                            font: Tokens.font.body.builders.small.scale(0.8).build()
                            color: Colours.palette.m3tertiary
                        }
                    }
                }
            }
        }
    ]
}
