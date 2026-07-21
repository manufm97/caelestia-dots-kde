import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    property int highlightedLocationIdx: -1
    property var pendingLocation
    readonly property bool compactWeatherPicker: root.cappedWidth < 620

    function selectLocationCandidate(item: var): void {
        if (!item)
            return;

        pendingLocation = item;
        highlightedLocationIdx = -1;
        Weather.locationSearchResults = [];
    }

    function applyPendingLocation(): void {
        if (!pendingLocation)
            return;

        if (Weather.applyLocationResult(pendingLocation)) {
            highlightedLocationIdx = -1;
            Weather.locationSearchResults = [];
            Weather.locationSearchError = "";
            Weather.locationSearchQuery = "";
            locationField.text = "";
        }
    }

    Component.onCompleted: Weather.reload()

    // Temperature units (index 0 = Celsius, 1 = Fahrenheit — matches Weather.formatTemp)
    readonly property list<MenuItem> tempItems: [
        MenuItem {
            text: "°C"
        },
        MenuItem {
            text: "°F"
        }
    ]

    // Clock format (index 0 = 24-hour, 1 = 12-hour — matches Time.useTwelveHourClock)
    readonly property list<MenuItem> clockItems: [
        MenuItem {
            text: "24 horas"
        },
        MenuItem {
            text: "12 horas"
        }
    ]

    title: "Idioma y región"

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Language
        SectionHeader {
            first: true
            text: "Idioma"
        }

        // Read-only: the shell follows the system locale (no in-shell translations yet)
        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: localeLayout.implicitHeight + localeLayout.anchors.margins * 2

            RowLayout {
                id: localeLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                anchors.leftMargin: Tokens.padding.largeIncreased
                anchors.rightMargin: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.medium

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: "Idioma del sistema"
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Sigue la configuración regional (%1)".arg(Qt.locale().name)
                        color: Colours.palette.m3outline
                        font: Tokens.font.label.small
                        elide: Text.ElideRight
                    }
                }

                StyledText {
                    text: Qt.locale().nativeLanguageName || Qt.locale().name
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }
        }

        // Weather
        SectionHeader {
            text: "Clima"
        }

        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: weatherContent.implicitHeight + Tokens.padding.largeIncreased * 2

            ColumnLayout {
                id: weatherContent

                anchors.fill: parent
                anchors.margins: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.medium

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "map"
                    color: Colours.palette.m3outlineVariant
                    fontStyle: Tokens.font.icon.extraLarge
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Selector de ubicación próximamente"
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.title.small
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Elige tu ubicación en un mapa en una futura actualización"
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.body.small
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            visible: root.compactWeatherPicker
        }

        // Units
        SectionHeader {
            text: "Unidades"
        }

        SelectRow {
            first: true
            label: "Temperatura"
            subtext: "Unidades para temperatura del clima"
            menuItems: root.tempItems
            active: root.tempItems[GlobalConfig.services.useFahrenheit ? 1 : 0]
            onSelected: item => GlobalConfig.services.useFahrenheit = root.tempItems.indexOf(item) === 1
        }

        SelectRow {
            last: true
            label: "Temperaturas del sistema"
            subtext: "Unidades para temperatura de CPU y GPU"
            menuItems: root.tempItems
            active: root.tempItems[GlobalConfig.services.useFahrenheitPerformance ? 1 : 0]
            onSelected: item => GlobalConfig.services.useFahrenheitPerformance = root.tempItems.indexOf(item) === 1
        }

        // Time & date
        SectionHeader {
            text: "Hora y fecha"
        }

        SelectRow {
            first: true
            last: true
            label: "Formato de reloj"
            subtext: "Cómo se muestran las horas en el shell"
            menuItems: root.clockItems
            active: root.clockItems[GlobalConfig.services.useTwelveHourClock ? 1 : 0]
            onSelected: item => GlobalConfig.services.useTwelveHourClock = root.clockItems.indexOf(item) === 1
        }
    }
}
