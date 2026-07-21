pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: "Audio"

    function addApp() {
        let appName = silenceAppInput.text.trim();
        if (appName !== "") {
            let list = Array.from(GlobalConfig.audio.sounds.disabledNotifApps);
            if (!list.includes(appName)) {
                list.push(appName);
                GlobalConfig.audio.sounds.disabledNotifApps = list;
                GlobalConfig.save();
            }
            silenceAppInput.text = "";
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Output
        SliderRow {
            first: true
            icon: Icons.getVolumeIcon(Audio.volume, Audio.muted)
            label: "Salida"
            valueLabel: Math.round(value * 100) + "%"
            value: Audio.volume
            enabled: !Audio.muted
            onMoved: v => Audio.setVolume(v)
            onReleased: v => Audio.playEffectTick()
        }

        ToggleRow {
            text: "Silenciado"
            checked: Audio.muted
            onToggled: Audio.setStreamMuted(Audio.sink, checked)
        }

        AudioDeviceList {
            nodes: Audio.sinks
            currentId: Audio.sink?.id ?? -1
            iconName: "speaker"
            placeholderIcon: "speaker"
            placeholderText: "Sin dispositivos de salida"
            onSelected: node => Audio.setAudioSink(node)
        }

        // Input
        SliderRow {
            Layout.topMargin: Tokens.spacing.large - parent.spacing
            first: true
            icon: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
            label: "Entrada"
            valueLabel: Math.round(value * 100) + "%"
            value: Audio.sourceVolume
            enabled: !Audio.sourceMuted
            onMoved: v => Audio.setSourceVolume(v)
            onReleased: v => Audio.playEffectTick()
        }

        ToggleRow {
            text: "Silenciado"
            checked: Audio.sourceMuted
            onToggled: Audio.setStreamMuted(Audio.source, checked)
        }

        AudioDeviceList {
            nodes: Audio.sources
            currentId: Audio.source?.id ?? -1
            iconName: "mic"
            placeholderIcon: "mic_off"
            placeholderText: "Sin dispositivos de entrada"
            onSelected: node => Audio.setAudioSource(node)
        }

        // Per-app volumes
        ConnectedRect {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.large - parent.spacing
            implicitHeight: appLayout.implicitHeight + appLayout.anchors.margins * 2
            first: true
            last: true

            StateLayer {
                onClicked: root.nState.openSubPage(1)
            }

            RowLayout {
                id: appLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                anchors.leftMargin: Tokens.padding.largeIncreased
                anchors.rightMargin: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.medium

                MaterialIcon {
                    text: "tune"
                    fontStyle: Tokens.font.icon.medium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: "Volumen de apps"
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Audio.streams.length === 0 ? "Sin apps reproduciendo audio" : Audio.streams.length === 1 ? "1 app reproduciendo audio" : "%1 apps reproduciendo audio".arg(Audio.streams.length)
                        color: Colours.palette.m3outline
                        font: Tokens.font.label.small
                        elide: Text.ElideRight
                        animate: true
                    }
                }

                MaterialIcon {
                    text: "chevron_right"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.medium
                }
            }
        }

        // Sound effects
        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.large - parent.spacing
            text: "Efectos de sonido"
            font: Tokens.font.body.small
            color: Colours.palette.m3primary
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: "Activar efectos de sonido"
            checked: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.enabled = checked
        }

        SliderRow {
            Layout.fillWidth: true
            icon: "volume_up"
            label: "Volumen de efectos"
            valueLabel: Math.round(value * 100) + "%"
            value: GlobalConfig.audio.sounds.sfxVolume
            enabled: GlobalConfig.audio.sounds.enabled
            onMoved: v => GlobalConfig.audio.sounds.sfxVolume = v
            onInteraction: v => Audio.playEffectTick()
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Clic de cámara"
            checked: GlobalConfig.audio.sounds.cameraClick
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.cameraClick = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Carga iniciada"
            checked: GlobalConfig.audio.sounds.chargingStarted
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.chargingStarted = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Tic de volumen"
            checked: GlobalConfig.audio.sounds.effectTick
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.effectTick = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Bloqueo de pantalla"
            checked: GlobalConfig.audio.sounds.lock
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.lock = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Desbloqueo de pantalla"
            checked: GlobalConfig.audio.sounds.unlock
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.unlock = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Batería baja"
            checked: GlobalConfig.audio.sounds.lowBattery
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.lowBattery = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: "Grabación de pantalla"
            checked: GlobalConfig.audio.sounds.screenRecord
            enabled: GlobalConfig.audio.sounds.enabled
            onToggled: GlobalConfig.audio.sounds.screenRecord = checked
        }

        // Notification Silencing
        StyledText {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.large - parent.spacing
            text: "Silenciar notificaciones"
            font: Tokens.font.body.small
            color: Colours.palette.m3primary
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            Layout.bottomMargin: Tokens.spacing.medium
            text: "Silenciar notificaciones de apps específicas"
            color: Colours.palette.m3outline
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            StyledInputField {
                id: silenceAppInput

                Layout.fillWidth: true
                // placeholderText is also not exposed in StyledInputField? Let's check... wait, we can't use it if it's not exposed.
                onEditingFinished: root.addApp()
            }

            IconTextButton {
                text: "Añadir"
                icon: "add"
                onClicked: root.addApp()
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            Repeater {
                model: GlobalConfig.audio.sounds.disabledNotifApps
                delegate: StyledRect {
                    required property string modelData
                    required property int index

                    width: implicitWidth
                    height: implicitHeight
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    radius: Tokens.rounding.large
                    implicitWidth: chipLayout.implicitWidth + Tokens.padding.medium * 2
                    implicitHeight: chipLayout.implicitHeight + Tokens.padding.extraSmall * 2

                    RowLayout {
                        id: chipLayout

                        x: Tokens.padding.medium
                        y: Tokens.padding.extraSmall
                        spacing: Tokens.spacing.extraSmall

                        StyledText {
                            text: modelData
                        }

                        MaterialIcon {
                            text: "close"
                            font: Tokens.font.icon.small

                            StateLayer {
                                onClicked: {
                                    let list = Array.from(GlobalConfig.audio.sounds.disabledNotifApps);
                                    list.splice(index, 1);
                                    GlobalConfig.audio.sounds.disabledNotifApps = list;
                                    GlobalConfig.save();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
