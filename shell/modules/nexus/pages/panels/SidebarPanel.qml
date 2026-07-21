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

        // AI Assistant
        SectionHeader {
            text: "Asistente IA"
        }

        PopupRow {
            Layout.fillWidth: true
            first: true
            icon: "info"
            label: "Instrucciones y configuración"

            StyledText {
                width: parent.width
                wrapMode: Text.Wrap
                text: "El asistente IA de Caelestia funciona localmente con Ollama para máxima privacidad. ¡No requiere claves API!\n\nPara activarlo:\n1. Instala Ollama (ej. \'sudo pacman -S ollama\')\n2. Inicia el servicio de Ollama\n3. Descarga un modelo (ej. \'ollama run llama3\')\n\nCuando Ollama esté activo en el puerto 11434, el asistente se conecta automáticamente."
            }
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: "Activar asistente"
            subtext: "Mostrar asistente IA en la barra lateral"
            checked: GlobalConfig.ai.enableOllama
            onToggled: GlobalConfig.ai.enableOllama = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            last: true
            text: "Activar uso de herramientas"
            subtext: "Permitir al asistente buscar en la web, tomar capturas, etc."
            checked: GlobalConfig.ai.enableCelestialMode
            onToggled: GlobalConfig.ai.enableCelestialMode = checked
        }

        // OSD Sliders
        SectionHeader {
            text: "Controles OSD"
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: "Control de volumen"
            subtext: "Mostrar control deslizante de volumen"
            checked: Config.osd.enableVolume
            onToggled: GlobalConfig.osd.enableVolume = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: "Control de micrófono"
            subtext: "Mostrar control deslizante de micrófono"
            checked: Config.osd.enableMicrophone
            onToggled: GlobalConfig.osd.enableMicrophone = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            last: true
            text: "Control de brillo"
            subtext: "Mostrar control deslizante de brillo"
            checked: Config.osd.enableBrightness
            onToggled: GlobalConfig.osd.enableBrightness = checked
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

        // Utilities Panel
        SectionHeader {
            text: "Panel de utilidades"
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: "Mostrar No dormir"
            subtext: "Mostrar tarjeta No dormir"
            checked: Config.utilities.showKeepAwake
            onToggled: GlobalConfig.utilities.showKeepAwake = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: "Mostrar Grabador de pantalla"
            subtext: "Mostrar tarjeta de grabación"
            checked: Config.utilities.showScreenRecorder
            onToggled: GlobalConfig.utilities.showScreenRecorder = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            last: true
            text: "Mostrar accesos rápidos"
            subtext: "Mostrar tarjeta de accesos rápidos"
            checked: Config.utilities.showQuickToggles
            onToggled: GlobalConfig.utilities.showQuickToggles = checked
        }

        // Quick Toggles
        SectionHeader {
            text: "Accesos rápidos"
        }

        Repeater {
            id: toggleRepeater
            model: [
                { id: "wifi",           label: "Wi-Fi" },
                { id: "bluetooth",      label: "Bluetooth" },
                { id: "mic",            label: "Micrófono" },
                { id: "settings",       label: "Ajustes" },
                { id: "colorpicker",    label: Strings.localizeEnglishSpelling("Selector de color") },
                { id: "dnd",            label: "No molestar" },
                { id: "vpn",            label: "VPN" },
                { id: "wallpaper",      label: "Fondo" },
                { id: "badapple",       label: "Bad Apple" },
                { id: "pauseWallpaper", label: "Pausar fondo" },
            ]

            delegate: ToggleRow {
                required property var modelData
                required property int index

                Layout.fillWidth: true
                first: index === 0
                last: index === toggleRepeater.count - 1
                Layout.topMargin: index === 0 ? 0 : Tokens.spacing.extraSmall / 2 - parent.spacing
                text: modelData.label
                checked: {
                    const arr = Config.utilities.quickToggles || [];
                    const item = arr.find(t => t.id === modelData.id);
                    return item ? item.enabled !== false : true;
                }
                onToggled: {
                    const arr = JSON.parse(JSON.stringify(GlobalConfig.utilities.quickToggles || []));
                    const idx = arr.findIndex(t => t.id === modelData.id);
                    if (idx >= 0) {
                        arr[idx].enabled = checked;
                    } else {
                        arr.push({ id: modelData.id, enabled: checked });
                    }
                    GlobalConfig.utilities.quickToggles = arr;
                }
            }
        }
    }
}
