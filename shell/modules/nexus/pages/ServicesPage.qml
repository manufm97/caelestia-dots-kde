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

    property bool idleSuspendEnabledState: false
    property int idleSuspendMinutesState: 10

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

    function isSuspendIdleAction(action: var): bool {
        if (!action)
            return false;

        if (typeof action === "string") {
            const normalized = action.trim().toLowerCase();
            return normalized === "suspendthenhibernate" || normalized === "suspend" || normalized === "suspend-then-hibernate" || normalized === "systemctl suspend" || normalized === "systemctl suspend-then-hibernate";
        }

        const isArrayLike = action instanceof Array || (typeof action === "object" && action.length !== undefined);
        if (isArrayLike) {
            for (const a of action) {
                if (root.isSuspendIdleAction(a))
                    return true;
            }
        }

        return false;
    }

    function cloneEntry(entry: var): var {
        const out = {};
        for (const k in entry)
            out[k] = entry[k];
        return out;
    }

    function clonedIdleTimeouts(): var {
        const source = GlobalConfig.general.idle.timeouts ?? [];
        const copy = [];

        for (const entry of source)
            copy.push(root.cloneEntry(entry));

        return copy;
    }

    function refreshIdleSuspendState(): void {
        root.idleSuspendEnabledState = root.suspendTimeoutEnabled();
        root.idleSuspendMinutesState = root.suspendTimeoutMinutes();
    }

    function suspendTimeoutMinutes(): int {
        const entries = GlobalConfig.general.idle.timeouts ?? [];

        for (const entry of entries) {
            if (root.isSuspendIdleAction(entry.idleAction)) {
                const seconds = Number(entry.timeout);
                if (isFinite(seconds) && seconds > 0)
                    return Math.max(1, Math.round(seconds / 60));
            }
        }

        return 10;
    }

    function suspendTimeoutEnabled(): bool {
        const entries = GlobalConfig.general.idle.timeouts ?? [];

        for (const entry of entries) {
            if (root.isSuspendIdleAction(entry.idleAction))
                return entry.enabled ?? true;
        }

        return false;
    }

    function setSuspendTimeoutMinutes(minutes: int): void {
        const sanitizedMinutes = Math.max(1, Math.min(180, Math.round(minutes)));
        const timeoutSeconds = sanitizedMinutes * 60;
        const updated = root.clonedIdleTimeouts();
        let found = false;

        for (let i = 0; i < updated.length; i++) {
            if (!root.isSuspendIdleAction(updated[i].idleAction))
                continue;

            updated[i].timeout = timeoutSeconds;
            if (updated[i].enabled === undefined)
                updated[i].enabled = true;
            found = true;
        }

        if (!found) {
            updated.push({
                timeout: timeoutSeconds,
                idleAction: ["suspendThenHibernate"],
                enabled: true,
                respectInhibitors: true
            });
        }

        GlobalConfig.general.idle.timeouts = updated;
        root.refreshIdleSuspendState();
    }

    function setSuspendTimeoutEnabled(enabled: bool): void {
        const updated = root.clonedIdleTimeouts();
        let found = false;

        for (let i = 0; i < updated.length; i++) {
            if (!root.isSuspendIdleAction(updated[i].idleAction))
                continue;

            updated[i].enabled = enabled;
            found = true;
        }

        if (!found && enabled) {
            updated.push({
                timeout: 600,
                idleAction: ["suspendThenHibernate"],
                enabled: true,
                respectInhibitors: true
            });
        }

        GlobalConfig.general.idle.timeouts = updated;
        root.refreshIdleSuspendState();
    }

    Component.onCompleted: root.refreshIdleSuspendState()

    title: "Servicios"

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

        // Notifications
        SectionHeader {
            first: true
            text: "Notificaciones"
        }

        NavRow {
            first: true
            last: true
            icon: "notifications"
            label: "Notificaciones"
            status: "Notificaciones, toasts, tiempos"
            onClicked: root.nState.openSubPage(1)
        }

        // Connections
        SectionHeader {
            text: "Intervalos"
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

        // Idle behavior
        SectionHeader {
            text: "Inactividad y suspensión"
        }

        ToggleRow {
            first: true
            text: "Suspensión por inactividad"
            subtext: "Suspender el sistema tras inactividad"
            checked: root.idleSuspendEnabledState
            onToggled: root.setSuspendTimeoutEnabled(checked)
        }

        StepperRow {
            last: true
            enabled: root.idleSuspendEnabledState
            label: "Temporizador de suspensión"
            subtext: root.idleSuspendEnabledState
                     ? "Suspender tras %1 minuto(s) de inactividad".arg(root.idleSuspendMinutesState)
                     : "Activar suspensión para aplicar un temporizador"
            value: root.idleSuspendMinutesState
            from: 1
            to: 180
            stepSize: 1
            onMoved: v => {
                if (root.idleSuspendEnabledState)
                    root.setSuspendTimeoutMinutes(v)
            }
        }

        // Service tuning
        SectionHeader {
            text: "Ajustes de servicio"
        }

        NavRow {
            first: true
            icon: "sports_esports"
            label: "Modo juego"
            status: "Gestionar comportamiento de Caelestia durante juegos"
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "chat" // Using chat since discord icon might not be available in Material icons
            label: "Presencia de Discord"
            status: "Transmitir tu estado a Vesktop"
            onClicked: root.nState.openSubPage(4)
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
