import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config

Scope {
    Connections {
        function onLoaded(): void {
            if (GlobalConfig.utilities.toasts.configLoaded)
                Toaster.toast("Configuración cargada", "Configuración cargada correctamente", "rule_settings");
        }

        function onLoadFailed(error: string, screen: string): void {
            Toaster.toast("Error al analizar configuración%1".arg(screen ? " for " + screen : ""), error, "settings_alert", Toast.Warning);
        }

        function onSaveFailed(error: string, screen: string): void {
            Toaster.toast("Error al guardar configuración%1".arg(screen ? " for " + screen : ""), error, "settings_alert", Toast.Error);
        }

        function onUnknownOption(key: string, screen: string): void {
            Toaster.toast("Opción desconocida en config%1".arg(screen ? " " + screen : ""), key, "question_mark", Toast.Warning);
        }

        target: GlobalConfig
    }

    Connections {
        function onLoadFailed(error: string, screen: string): void {
            Toaster.toast("Error al analizar token config%1".arg(screen ? "for " + screen : ""), error, "settings_alert", Toast.Warning);
        }

        function onUnknownOption(key: string, screen: string): void {
            Toaster.toast("Opción desconocida en token config%1".arg(screen ? " " + screen : ""), key, "question_mark", Toast.Warning);
        }

        target: TokenConfig
    }
}
