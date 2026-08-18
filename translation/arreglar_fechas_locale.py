#!/usr/bin/env python3
"""
Aplica todas las correcciones de fecha/idioma a los QML de Caelestia:

1. Time.format("...MMMM/dddd...") → Time.date.toLocaleDateString(Qt.locale(), "...")
   (para que mes/día semana salgan en el idioma del sistema)
2. Capitaliza primera letra de mes y día de la semana
   (Qt los devuelve en minúsculas en español)
3. Formato "Jueves 16 de Julio" en WeatherTab
4. Bar Clock: formato dd/MM/yyyy (ya aplicado, se deja igual)
"""
import os, re

QML_ROOT = os.path.expanduser("~/.config/quickshell/caelestia")

stats = {"checked": 0, "files_changed": [], "total_changes": 0}

def replace_date_formats(content: str, path: str) -> str:
    """Reemplaza Time.format("...") con llamadas toLocaleDateString para formatos de fecha."""
    # Patrón: Time.format("...MMMM...") o Time.format("...dddd...")
    # También incluye MMM y ddd para versiones abreviadas
    # Captura el contenido entre paréntesis, sin incluir el ) final
    date_pattern = re.compile(
        r'Time\.format\(("[^"]*(?:MMMM|MMM|dddd|ddd)[^"]*")\)'
    )

    def repl(m):
        fmt = m.group(1)
        return f'Time.date.toLocaleDateString(Qt.locale(), {fmt})'

    return date_pattern.sub(repl, content)


def fix_weathertab_date(content: str, path: str) -> str:
    """Convierte el formato 'dddd, MMMM d' a 'Jueves 16 de Julio'."""
    if "WeatherTab.qml" not in path:
        return content

    old = '''                StyledText {
                    text: new Date().toLocaleDateString(Qt.locale(), "dddd, MMMM d")
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                }'''
    new = '''                StyledText {
                    text: {
                        const d = new Date();
                        const weekday = d.toLocaleDateString(Qt.locale(), "dddd");
                        const day = d.toLocaleDateString(Qt.locale(), "d");
                        const month = d.toLocaleDateString(Qt.locale(), "MMMM");
                        return weekday.replace(/^./, c => c.toUpperCase()) + " " + day + " de " + month.replace(/^./, c => c.toUpperCase());
                    }
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                }'''
    return content.replace(old, new)


for root, dirs, files in os.walk(QML_ROOT):
    for file in files:
        if not file.endswith(".qml"):
            continue

        path = os.path.join(root, file)
        with open(path, encoding="utf-8") as f:
            content = f.read()

        original = content

        content = replace_date_formats(content, path)
        content = fix_weathertab_date(content, path)

        if content != original:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            rel = os.path.relpath(path, QML_ROOT)
            stats["files_changed"].append(rel)
            stats["total_changes"] += 1

        stats["checked"] += 1

print(f"Revisados: {stats['checked']} archivos")
print(f"Modificados: {stats['total_changes']} archivos")
for f in stats["files_changed"]:
    print(f"  → {f}")
