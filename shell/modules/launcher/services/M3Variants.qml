pragma Singleton

import ".."
import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.services
import qs.utils

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(`${GlobalConfig.launcher.actionPrefix}variant `.length);
    }

    function previewVariant(variant: string): void {
        const cmd = `import json\nfrom caelestia.utils.scheme import get_scheme\nscheme = get_scheme()\nscheme._variant = "${variant}"\nscheme._update_colours()\nprint(json.dumps({"name": scheme.name, "flavour": scheme.flavour, "mode": scheme.mode, "variant": scheme.variant, "colours": scheme.colours}))`;
        getPreviewColoursProc.command = ["python3", "-c", cmd];
        getPreviewColoursProc.running = true;
    }

    Process {
        id: getPreviewColoursProc
        stdout: StdioCollector {
            onStreamFinished: {
                Colours.load(text, true);
                Colours.showPreview = true;
            }
        }
    }

    list: [
        Variant {
            variant: "vibrant"
            icon: "sentiment_very_dissatisfied"
            name: "Vibrante"
            description: "Paleta de croma alto. El croma de la paleta primaria está al máximo."
        },
        Variant {
            variant: "tonalspot"
            icon: "android"
            name: "Tono puntual"
            description: Strings.localizeEnglishSpelling("Por defecto para tema Material. Paleta pastel con croma bajo.")
        },
        Variant {
            variant: "expressive"
            icon: "compare_arrows"
            name: "Expresivo"
            description: Strings.localizeEnglishSpelling("Paleta de croma medio. El tono primario difiere del color semilla para variedad.")
        },
        Variant {
            variant: "fidelity"
            icon: "compare"
            name: "Fidelidad"
            description: Strings.localizeEnglishSpelling("Coincide con el color semilla, incluso si es muy brillante.")
        },
        Variant {
            variant: "content"
            icon: "sentiment_calm"
            name: "Contenido"
            description: "Casi idéntico a fidelidad."
        },
        Variant {
            variant: "fruitsalad"
            icon: "nutrition"
            name: "Macedonia"
            description: Strings.localizeEnglishSpelling("Un tema divertido: el tono del color semilla no aparece en el tema.")
        },
        Variant {
            variant: "rainbow"
            icon: "looks"
            name: "Arcoíris"
            description: Strings.localizeEnglishSpelling("Un tema divertido: el tono del color semilla no aparece en el tema.")
        },
        Variant {
            variant: "neutral"
            icon: "contrast"
            name: "Neutral"
            description: "Cerca de escala de grises, con un toque de croma."
        },
        Variant {
            variant: "monochrome"
            icon: "filter_b_and_w"
            name: "Monocromo"
            description: Strings.localizeEnglishSpelling("Todos los colores en escala de grises, sin croma.")
        }
    ]
    useFuzzy: GlobalConfig.launcher.useFuzzy.variants

    component Variant: QtObject {
        required property string variant
        required property string icon
        required property string name
        required property string description

        function onClicked(list: var): void {
            if (list) {
                list.visibilities.launcher = false;
            }
            Quickshell.execDetached(["caelestia", "scheme", "set", "-v", variant]);
        }
    }
}
