pragma Singleton

import QtQuick
import qs.utils

QtObject {
    id: root

    readonly property list<var> pages: [
        // Appearance
        {
            label: "Fondo y estilo",
            icon: "palette",
            description: Strings.localizeEnglishSpelling("Fondo, fuentes, colores"),
            category: "appearance"
        },

        // Connectivity
        // TODO
        // {
        //     label: "Pantalla",
        //     icon: "monitor",
        //     description: "Configuración de salida",
        //     category: "connectivity"
        // },
        {
            label: "Red",
            icon: "wifi",
            description: "Wi-Fi, ethernet",
            category: "connectivity"
        },
        {
            label: "Dispositivos conectados",
            icon: "devices_other",
            description: "Bluetooth, emparejamiento",
            category: "connectivity",
            noFill: true
        },
        {
            label: "Audio",
            icon: "volume_up",
            description: "Volumen de apps, dispositivos",
            category: "connectivity"
        },

        // System
        {
            label: "Actualizaciones",
            icon: "update",
            description: "Actualizaciones del sistema",
            category: "system"
        },
        {
            label: "Plugins",
            icon: "extension",
            description: "Gestionar plugins",
            category: "system"
        },

        // Shell
        {
            label: "Paneles",
            icon: "dock_to_bottom",
            description: "Panel, barra, lanzador, lateral",
            category: "shell"
        },
        {
            label: "Aplicaciones",
            icon: "apps",
            description: Strings.localizeEnglishSpelling("Apps predeterminadas, favoritas, ocultas"),
            category: "shell"
        },
        {
            label: "Servicios",
            icon: "build",
            description: "Intervalos, motor de letras",
            category: "shell"
        },
        {
            label: "Idioma y región",
            icon: "globe",
            description: "Idioma, ubicación, unidades",
            category: "shell"
        },

        // About
        {
            label: "Acerca de",
            icon: "info",
            description: "Info del sistema, créditos",
            category: "about"
        },
    ]
}
