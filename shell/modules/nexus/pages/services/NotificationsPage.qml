import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    // Notification fullscreen visibility, mapped to GlobalConfig.notifs.fullscreen
    readonly property list<MenuItem> notifFullscreenItems: [
        MenuItem {
            text: "Desactivado"
            icon: "notifications_off"
        },
        MenuItem {
            text: "Activado"
            icon: "notifications"
        }
    ]
    readonly property list<string> notifFullscreenValues: ["off", "on"]

    // Toast fullscreen visibility, mapped to GlobalConfig.utilities.toasts.fullscreen
    readonly property list<MenuItem> toastFullscreenItems: [
        MenuItem {
            text: "Desactivado"
            icon: "notifications_off"
        },
        MenuItem {
            text: "Importante"
            icon: "priority_high"
        },
        MenuItem {
            text: "Activado"
            icon: "notifications"
        }
    ]
    readonly property list<string> toastFullscreenValues: ["off", "important", "all"]

    title: qsTr("Notifications")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Notifications
        SectionHeader {
            first: true
            text: "Notificaciones"
        }

        SelectRow {
            first: true
            label: "Mostrar en pantalla completa"
            subtext: "Si las notificaciones aparecen sobre apps a pantalla completa"
            menuItems: root.notifFullscreenItems
            active: root.notifFullscreenItems[Math.max(0, root.notifFullscreenValues.indexOf(GlobalConfig.notifs.fullscreen))]
            onSelected: item => GlobalConfig.notifs.fullscreen = root.notifFullscreenValues[root.notifFullscreenItems.indexOf(item)]
        }

        ToggleRow {
            text: "Expirar automáticamente"
            subtext: "Descartar notificaciones tras su tiempo de espera"
            checked: GlobalConfig.notifs.expire
            onToggled: GlobalConfig.notifs.expire = checked
        }

        ToggleRow {
            text: "Abrir expandidas"
            subtext: "Mostrar notificaciones expandidas por defecto"
            checked: GlobalConfig.notifs.openExpanded
            onToggled: GlobalConfig.notifs.openExpanded = checked
        }

        StepperRow {
            label: "Tiempo de espera predeterminado"
            subtext: "Tiempo antes de descartar una notificación (ms)"
            value: GlobalConfig.notifs.defaultExpireTimeout
            from: 1000
            to: 60000
            stepSize: 500
            onMoved: v => GlobalConfig.notifs.defaultExpireTimeout = Math.round(v)
        }

        StepperRow {
            last: true
            label: "Vista previa de grupo"
            subtext: "Notificaciones mostradas por grupo antes de colapsar"
            value: GlobalConfig.notifs.groupPreviewNum
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.notifs.groupPreviewNum = Math.round(v)
        }

        // Toasts
        SectionHeader {
            text: "Toasts"
        }

        SelectRow {
            first: true
            label: "Mostrar en pantalla completa"
            subtext: "Si los toasts aparecen sobre apps a pantalla completa"
            menuItems: root.toastFullscreenItems
            active: root.toastFullscreenItems[Math.max(0, root.toastFullscreenValues.indexOf(GlobalConfig.utilities.toasts.fullscreen))]
            onSelected: item => GlobalConfig.utilities.toasts.fullscreen = root.toastFullscreenValues[root.toastFullscreenItems.indexOf(item)]
        }

        StepperRow {
            label: "Toasts visibles"
            subtext: "Máximo número de toasts mostrados a la vez"
            value: GlobalConfig.utilities.maxToasts
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => GlobalConfig.utilities.maxToasts = Math.round(v)
        }

        ToggleRow {
            text: "Transparencia de toasts"
            subtext: "Aplicar transparencia y desenfoque a toasts"
            checked: GlobalConfig.utilities.toasts.transparency
            onToggled: GlobalConfig.utilities.toasts.transparency = checked
        }

        SliderRow {
            last: true
            label: "Transparencia base"
            valueLabel: Math.round(value * 100) + "%"
            value: GlobalConfig.utilities.toasts.transparencyBase
            enabled: GlobalConfig.utilities.toasts.transparency
            onMoved: v => GlobalConfig.utilities.toasts.transparencyBase = v
        }

        SectionHeader {
            text: qsTr("Sound")
        }

        SliderRow {
            first: true
            last: true
            icon: "notifications"
            label: qsTr("Notification volume")
            valueLabel: Math.round(value * 100) + "%"
            value: GlobalConfig.audio.sounds.notificationVolume
            enabled: GlobalConfig.audio.sounds.enabled
            onMoved: v => GlobalConfig.audio.sounds.notificationVolume = v
            onInteraction: v => Audio.playNotification()
        }

        SectionHeader {
            text: qsTr("Taskbar indicator")
        }

        ToggleRow {
            first: true
            last: true
            text: qsTr("Show notifications icon")
            subtext: qsTr("Show notifications in taskbar status icons")
            checked: Config.bar.status.showNotifications
            onToggled: GlobalConfig.bar.status.showNotifications = checked
        }

        // Toast events
        SectionHeader {
            text: "Eventos de toast"
        }

        ToggleRow {
            first: true
            text: "Cambios de carga"
            checked: GlobalConfig.utilities.toasts.chargingChanged
            onToggled: GlobalConfig.utilities.toasts.chargingChanged = checked
        }

        ToggleRow {
            text: "Cambios de modo juego"
            checked: GlobalConfig.utilities.toasts.gameModeChanged
            onToggled: GlobalConfig.utilities.toasts.gameModeChanged = checked
        }

        ToggleRow {
            text: "Cambios de No molestar"
            checked: GlobalConfig.utilities.toasts.dndChanged
            onToggled: GlobalConfig.utilities.toasts.dndChanged = checked
        }

        ToggleRow {
            text: "Cambios de salida de audio"
            checked: GlobalConfig.utilities.toasts.audioOutputChanged
            onToggled: GlobalConfig.utilities.toasts.audioOutputChanged = checked
        }

        ToggleRow {
            text: "Cambios de entrada de audio"
            checked: GlobalConfig.utilities.toasts.audioInputChanged
            onToggled: GlobalConfig.utilities.toasts.audioInputChanged = checked
        }

        ToggleRow {
            text: "Cambios de BloqMayús"
            checked: GlobalConfig.utilities.toasts.capsLockChanged
            onToggled: GlobalConfig.utilities.toasts.capsLockChanged = checked
        }

        ToggleRow {
            text: "Cambios de BloqNum"
            checked: GlobalConfig.utilities.toasts.numLockChanged
            onToggled: GlobalConfig.utilities.toasts.numLockChanged = checked
        }

        ToggleRow {
            text: "Cambios de distribución"
            checked: GlobalConfig.utilities.toasts.kbLayoutChanged
            onToggled: GlobalConfig.utilities.toasts.kbLayoutChanged = checked
        }

        ToggleRow {
            text: "Cambios de VPN"
            checked: GlobalConfig.utilities.toasts.vpnChanged
            onToggled: GlobalConfig.utilities.toasts.vpnChanged = checked
        }

        ToggleRow {
            last: true
            text: "Reproduciendo ahora"
            checked: GlobalConfig.utilities.toasts.nowPlaying
            onToggled: GlobalConfig.utilities.toasts.nowPlaying = checked
        }
    }
}
