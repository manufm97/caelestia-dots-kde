pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import M3Shapes
import qs.components
import qs.components.controls
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: "Panel principal"
    isSubPage: true

    readonly property list<MenuItem> dashboardShapeItems: [
        MenuItem {
            property int value: MaterialShape.Circle
            text: "Círculo"
        },
        MenuItem {
            property int value: MaterialShape.Square
            text: "Cuadrado"
        },
        MenuItem {
            property int value: MaterialShape.Pill
            text: "Píldora"
        },
        MenuItem {
            property int value: MaterialShape.Diamond
            text: "Rombo"
        },
        MenuItem {
            property int value: MaterialShape.ClamShell
            text: "Concha"
        },
        MenuItem {
            property int value: MaterialShape.Pentagon
            text: "Pentágono"
        },
        MenuItem {
            property int value: MaterialShape.Gem
            text: "Gema"
        },
        MenuItem {
            property int value: MaterialShape.Cookie4Sided
            text: "Galleta 4 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie6Sided
            text: "Galleta 6 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie7Sided
            text: "Galleta 7 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie9Sided
            text: "Galleta 9 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie12Sided
            text: "Galleta 12 lados"
        }
    ]

    readonly property list<MenuItem> lockShapeItems: [
        MenuItem {
            property int value: MaterialShape.Circle
            text: "Círculo"
        },
        MenuItem {
            property int value: MaterialShape.Square
            text: "Cuadrado"
        },
        MenuItem {
            property int value: MaterialShape.Pill
            text: "Píldora"
        },
        MenuItem {
            property int value: MaterialShape.Diamond
            text: "Rombo"
        },
        MenuItem {
            property int value: MaterialShape.ClamShell
            text: "Concha"
        },
        MenuItem {
            property int value: MaterialShape.Pentagon
            text: "Pentágono"
        },
        MenuItem {
            property int value: MaterialShape.Gem
            text: "Gema"
        },
        MenuItem {
            property int value: MaterialShape.Cookie4Sided
            text: "Galleta 4 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie6Sided
            text: "Galleta 6 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie7Sided
            text: "Galleta 7 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie9Sided
            text: "Galleta 9 lados"
        },
        MenuItem {
            property int value: MaterialShape.Cookie12Sided
            text: "Galleta 12 lados"
        }
    ]

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // General
        SectionHeader {
            first: true
            text: "General"
        }

        ToggleRow {
            first: true
            text: "Activado"
            checked: Config.dashboard.enabled
            onToggled: GlobalConfig.dashboard.enabled = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Mostrar al pasar"
            subtext: "Revelar cuando el cursor llegue al borde"
            checked: Config.dashboard.showOnHover
            onToggled: GlobalConfig.dashboard.showOnHover = checked
        }

        SelectRow {
            Layout.fillWidth: true
            label: "Forma de foto de perfil del panel"
            subtext: "Elige la forma de la foto de perfil en el panel"
            fallbackIcon: "person"
            fallbackText: "Píldora"
            active: {
                for (let i = 0; i < dashboardShapeItems.length; i++) {
                    if (dashboardShapeItems[i].value === GlobalConfig.dashboard.profilePicShape)
                        return dashboardShapeItems[i];
                }
                return dashboardShapeItems[0];
            }
            menuItems: dashboardShapeItems
            onSelected: item => {
                GlobalConfig.dashboard.profilePicShape = item.value
            }
        }

        SelectRow {
            Layout.fillWidth: true
            last: true
            label: "Forma de foto de perfil de bloqueo"
            subtext: "Elige la forma en la pantalla de bloqueo"
            fallbackIcon: "lock"
            fallbackText: "Concha"
            active: {
                for (let i = 0; i < lockShapeItems.length; i++) {
                    if (lockShapeItems[i].value === GlobalConfig.lock.profilePicShape)
                        return lockShapeItems[i];
                }
                return lockShapeItems[0];
            }
            menuItems: lockShapeItems
            onSelected: item => {
                GlobalConfig.lock.profilePicShape = item.value
            }
        }

        // Tabs
        SectionHeader {
            text: "Pestañas"
        }

        ToggleRow {
            first: true
            text: "Panel principal"
            checked: Config.dashboard.showDashboard
            onToggled: GlobalConfig.dashboard.showDashboard = checked
        }

        ToggleRow {
            text: "Medios"
            checked: Config.dashboard.showMedia
            onToggled: GlobalConfig.dashboard.showMedia = checked
        }

        ToggleRow {
            text: "Rendimiento"
            checked: Config.dashboard.showPerformance
            onToggled: GlobalConfig.dashboard.showPerformance = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Clima"
            checked: Config.dashboard.showWeather
            onToggled: GlobalConfig.dashboard.showWeather = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Terminal"
            checked: Config.dashboard.showTerminal
            onToggled: GlobalConfig.dashboard.showTerminal = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Strings.localizeEnglishSpelling("Recolorear GIF multimedia")
            subtext: Strings.localizeEnglishSpelling("Aplicar colores del tema al GIF")
            checked: Config.dashboard.colorizeMediaGif
            onToggled: GlobalConfig.dashboard.colorizeMediaGif = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Usar formas Material"
            subtext: "Reemplazar el GIF con formas reactivas al audio"
            checked: Config.dashboard.useMediaShapes
            onToggled: GlobalConfig.dashboard.useMediaShapes = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Strings.localizeEnglishSpelling("Colores de formas aleatorios")
            subtext: Strings.localizeEnglishSpelling("Cambiar colores de formas al morfear")
            checked: Config.dashboard.randomizeMediaShapeColors
            onToggled: GlobalConfig.dashboard.randomizeMediaShapeColors = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: "Sincronizar con música"
            subtext: "Elegir formas al ritmo en lugar de nivel de graves"
            checked: Config.dashboard.syncMediaShapesToBeat
            onToggled: GlobalConfig.dashboard.syncMediaShapesToBeat = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: "Mensaje de Hyprland"
            visible: Quickshell.env("XDG_CURRENT_DESKTOP").includes("Hyprland")
            subtext: "Mostrar texto de bienvenida de Hyprland"
            checked: Config.dashboard.showHyprlandSplash
            onToggled: GlobalConfig.dashboard.showHyprlandSplash = checked
        }

        // Performance widgets
        SectionHeader {
            text: "Widgets de rendimiento"
        }

        ToggleRow {
            first: true
            text: "Batería"
            checked: Config.dashboard.performance.showBattery
            onToggled: GlobalConfig.dashboard.performance.showBattery = checked
        }

        ToggleRow {
            text: "GPU"
            checked: Config.dashboard.performance.showGpu
            onToggled: GlobalConfig.dashboard.performance.showGpu = checked
        }

        ToggleRow {
            text: "CPU"
            checked: Config.dashboard.performance.showCpu
            onToggled: GlobalConfig.dashboard.performance.showCpu = checked
        }

        ToggleRow {
            text: "Memoria"
            checked: Config.dashboard.performance.showMemory
            onToggled: GlobalConfig.dashboard.performance.showMemory = checked
        }

        ToggleRow {
            text: "Almacenamiento"
            checked: Config.dashboard.performance.showStorage
            onToggled: GlobalConfig.dashboard.performance.showStorage = checked
        }

        ToggleRow {
            last: true
            text: "Red"
            checked: Config.dashboard.performance.showNetwork
            onToggled: GlobalConfig.dashboard.performance.showNetwork = checked
        }

        // Behaviour
        SectionHeader {
            text: Strings.localizeEnglishSpelling("Comportamiento")
        }

        StepperRow {
            first: true
            last: true
            label: "Umbral de arrastre"
            subtext: "Píxeles arrastrados antes de abrir el panel"
            value: Config.dashboard.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.dashboard.dragThreshold = v
        }
    }
}
