#!/usr/bin/env python3
"""
Aplica / actualiza traducciones español a archivos QML de Caelestia.

Primera ejecución: reemplaza texto inglés → español y añade // TR: English
Ejecuciones siguientes: lee el // TR: para re-aplicar si cambió el JSON.
"""
import json, os, re
from pathlib import Path

QML_ROOT = os.path.expanduser("~/.config/quickshell/caelestia")
JSON_PATH = Path(__file__).parent / "traducciones.json"

with open(JSON_PATH, encoding="utf-8") as f:
    all_translations = json.load(f)

# Aplanar: eng -> spa
eng_to_spa = {}
for cat, pairs in all_translations.items():
    eng_to_spa.update(pairs)

# Inverso: spa -> eng (para buscar por TR)
spa_to_eng = {v: k for k, v in eng_to_spa.items()}

TR_PATTERN = re.compile(r'//\s*TR:\s*(.+)$')

stats = {"checked": 0, "new": 0, "updated": 0, "tagged": 0, "files": set()}

for root, dirs, files in os.walk(QML_ROOT):
    for file in files:
        if not file.endswith(".qml"):
            continue
        path = os.path.join(root, file)
        with open(path, encoding="utf-8") as f:
            lines = f.readlines()

        original_text = "".join(lines)
        changed = False

        for i, line in enumerate(lines):
            # Buscar si la línea ya tiene // TR:
            m = TR_PATTERN.search(line)
            if m:
                # Ya traducida: actualizar si cambió
                eng_key = m.group(1).strip()
                new_spa = eng_to_spa.get(eng_key)
                if new_spa is None:
                    continue  # clave ya no está en JSON, dejarla
                # Reemplazar el texto español actual (entre comillas) por el nuevo
                # Busca: comillas + contenido + comillas antes de // TR:
                before_tr = line[:m.start()].strip()
                qmatch = re.search(r'(["\'`])(.+?)\1\s*$', before_tr)
                if qmatch and qmatch.group(2) != new_spa:
                    quote = qmatch.group(1)
                    old_spa = qmatch.group(2)
                    old_line = line
                    lines[i] = line.replace(f'{quote}{old_spa}{quote}', f'{quote}{new_spa}{quote}')
                    if lines[i] != old_line:
                        stats["updated"] += 1
                        changed = True
                continue

            # No tiene TR: intentar traducir texto inglés entre comillas
            # Busca: text: "...", label: "...", placeholderText: "..." etc.
            qmatch = re.search(r'(["\'])([A-Za-z][A-Za-z\s\-,\'!?]+)\1', line)
            if qmatch:
                eng_text = qmatch.group(2).strip()
                spa_text = eng_to_spa.get(eng_text)
                if spa_text is not None:
                    old_line = line
                    quote = qmatch.group(1)
                    lines[i] = line.replace(f'{quote}{eng_text}{quote}', f'{quote}{spa_text}{quote}')
                    if not TR_PATTERN.search(lines[i]):
                        lines[i] = lines[i].rstrip() + f"  // TR: {eng_text}\n"
                    if lines[i] != old_line:
                        stats["new"] += 1
                        changed = True
                    continue

            # Si ya tiene español traducido pero sin TR, buscar en el mapa inverso
            qmatch = re.search(r'(["\'])([^"\']+)\1', line)
            if qmatch:
                current_text = qmatch.group(2).strip()
                eng_key = spa_to_eng.get(current_text)
                if eng_key is not None and not TR_PATTERN.search(line):
                    lines[i] = line.rstrip() + f"  // TR: {eng_key}\n"
                    stats["tagged"] += 1
                    changed = True

        if changed:
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(lines)
            stats["files"].add(path)
        stats["checked"] += 1

print(f"Revisados: {stats['checked']} archivos")
print(f"Nuevas traducciones: {stats['new']}")
print(f"Etiquetadas con TR (ya traducidas antes): {stats['tagged']}")
print(f"Actualizadas por cambio en JSON: {stats['updated']}")
print(f"Archivos modificados: {len(stats['files'])}")
