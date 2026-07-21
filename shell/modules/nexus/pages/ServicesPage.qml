import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.components.controls
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    // Lyrics backends, ordered to match LyricsBackend::Backend (Auto, Local, LRCLIB, NetEase)
    readonly property list<MenuItem> lyricsItems: [
        MenuItem {
            text: "Automático"
        },
        MenuItem {
            text: "Local"
        },
        MenuItem {
            text: "LRCLIB"
        },
        MenuItem {
            text: "NetEase"
        }
    ]

    // GPU options + the config string each maps to (see Gpu::parseType)
    readonly property list<MenuItem> gpuItems: [
        MenuItem {
            text: "Automático"
        },
        MenuItem {
            text: "NVIDIA"
        },
        MenuItem {
            text: "Genérico"
        },
        MenuItem {
            text: "Ninguno"
        }
    ]
    readonly property list<string> gpuValues: ["", "NVIDIA", "GENERIC", "None"]

    function gpuKeyToIndex(key: string): int {
        const u = (key ?? "").trim().toUpperCase();
        if (u === "")
            return 0; // Auto
        if (u === "NVIDIA")
            return 1;
        if (u === "GENERIC")
            return 2;
        return 3; // None
    }

    title: qsTr("Services")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Detected running players, used as default-player options
        Variants {
            id: playerVariants

            model: [...new Set(Players.list.map(p => Players.getIdentity(p)).filter(id => id))]

            MenuItem {
                required property string modelData

                text: modelData
                icon: modelData === GlobalConfig.services.defaultPlayer ? "check" : ""
                activeIcon: "music_note"
            }
        }

        // Polling
        SectionHeader {
            first: true
            text: qsTr("Polling")
        }

        StepperRow {
            first: true
            label: "Actualización de medios"
            subtext: "Cada cuánto se actualiza la posición del medio (ms)"
            value: GlobalConfig.dashboard.mediaUpdateInterval
            from: 100
            to: 2000
            stepSize: 50
            onMoved: v => GlobalConfig.dashboard.mediaUpdateInterval = v
        }

        StepperRow {
            label: "Actualización de estadísticas"
            subtext: "Intervalo de actualización de CPU, RAM y GPU (segundos)"
            value: GlobalConfig.dashboard.resourceUpdateInterval / 1000
            from: 0.5
            to: 10
            stepSize: 0.5
            onMoved: v => GlobalConfig.dashboard.resourceUpdateInterval = Math.round(v * 1000)
        }

        StepperRow {
            last: true
            label: "Reescanear Wi-Fi"
            subtext: "Cada cuánto se reescanen las redes (segundos)"
            value: GlobalConfig.nexus.networkRescanInterval / 1000
            from: 5
            to: 120
            stepSize: 5
            onMoved: v => GlobalConfig.nexus.networkRescanInterval = Math.round(v * 1000)
        }

        // Media & lyrics
        SectionHeader {
            text: "Medios y letras"
        }

        SelectRow {
            first: true
            label: "Motor de letras"
            subtext: "Fuente para obtener letras sincronizadas"
            menuItems: root.lyricsItems
            active: root.lyricsItems[Lyrics.preferredBackend] ?? root.lyricsItems[0]
            onSelected: item => Lyrics.preferredBackend = root.lyricsItems.indexOf(item)
        }

        SelectRow {
            last: true
            label: "Reproductor predeterminado"
            subtext: "Reproductor preferido cuando hay varios abiertos"
            menuItems: playerVariants.instances
            active: menuItems.find(i => i.text === GlobalConfig.services.defaultPlayer) ?? null
            fallbackIcon: "music_note"
            fallbackText: GlobalConfig.services.defaultPlayer || "Automático"
            onSelected: item => GlobalConfig.services.defaultPlayer = item.text
        }

        // Input increments
        SectionHeader {
            text: "Incrementos de entrada"
        }

        StepperRow {
            first: true
            label: "Paso de volumen"
            subtext: "Cambio de volumen por scroll (%)"
            value: Math.round(GlobalConfig.services.audioIncrement * 100)
            from: 1
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.services.audioIncrement = v / 100
        }

        StepperRow {
            label: "Paso de brillo"
            subtext: "Cambio de brillo por scroll (%)"
            value: Math.round(GlobalConfig.services.brightnessIncrement * 100)
            from: 1
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.services.brightnessIncrement = v / 100
        }

        StepperRow {
            last: true
            label: "Volumen máximo"
            subtext: "Límite superior de volumen de salida (%)"
            value: Math.round(GlobalConfig.services.maxVolume * 100)
            from: 50
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.services.maxVolume = v / 100
        }

        // Service tuning
        SectionHeader {
            text: "Ajustes de servicio"
        }

        NavRow {
            first: true
            icon: "chat" // Using chat since discord icon might not be available in Material icons
            label: qsTr("Discord Rich Presence")
            status: qsTr("Broadcast your status to Vesktop")
            onClicked: root.nState.openSubPage(1)
        }

        StepperRow {
            label: "Barras del visualizador"
            subtext: "Número de barras en el visualizador"
            value: GlobalConfig.services.visualiserBars
            from: 10
            to: 120
            stepSize: 2
            onMoved: v => GlobalConfig.services.visualiserBars = v
        }

        ToggleRow {
            text: Strings.localizeEnglishSpelling("Esquema de color inteligente")
            subtext: "Derivar modo y variante del tema desde el fondo"
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        SelectRow {
            Layout.fillWidth: true
            last: true
            label: "GPU"
            subtext: Gpu.name ? "Monitoreando: %1".arg(Gpu.name) : "Anulación para tipo de GPU"
            menuOnTop: true
            menuItems: root.gpuItems
            active: root.gpuItems[root.gpuKeyToIndex(GlobalConfig.services.gpuType)]
            onSelected: item => GlobalConfig.services.gpuType = root.gpuValues[root.gpuItems.indexOf(item)]
        }
    }
}
