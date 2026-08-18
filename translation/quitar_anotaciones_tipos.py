#!/usr/bin/env python3
"""
Elimina las anotaciones de tipo de las firmas de función en los archivos QML
de Caelestia (~/.config/quickshell/caelestia).

Motivo: el binario `quickshell` instalado (p. ej. el fork noctalia-qs 0.0.12)
no soporta anotaciones de tipo de JS/QML ("Type annotations are not supported"),
lo que impide que el shell cargue. Este script las quita para compatibilidad.

Quita:
  - Anotaciones de tipo en parámetros:  function foo(a: string, b: int = 1)
  - Anotaciones de tipo de retorno:     function foo(): void { ... }

NO toca (correcto en QML):
  - Declaraciones de propiedades:        property list<var> x: [...]
  - Declaraciones de signals:            signal foo(string a, int b)
  - Funciones sin anotaciones

Idempotente: ejecutarlo varias veces no cambia nada.
Antes de modificar crea una copia de seguridad: <caelestia>.bak-sin-anotaciones

Uso:
    python3 quitar_anotaciones_tipos.py [--sin-respaldo]
"""
import os
import re
import shutil
import sys

QML_ROOT = os.path.expanduser("~/.config/quickshell/caelestia")
BACKUP_DIR = QML_ROOT.rstrip("/") + ".bak-sin-anotaciones"

# Coincide con una declaración de función cuya firma completa está en una línea:
#   group1: `function nombre (`
#   group2: lista de parámetros
#   group3: `)` + anotación de retorno opcional
#   group4: ` {`
FUNC_RE = re.compile(
    r"(\bfunction\s+[A-Za-z_$][\w.]*\s*\()([^)]*)"
    r"(\)(?:\s*:\s*[A-Za-z_$][\w]*(?:<[^>]*>)?)?)(\s*\{)"
)

# Quita `: Type` dentro de la lista de parámetros.
#   - Seguido de `,`, `)` o fin de línea: se elimina por completo.
#   - Seguido de `=`: se sustituye por un espacio (conserva el valor por defecto).
PARAM_ANN = re.compile(r":\s*[A-Za-z_$][\w.]*(?:<[^>]*>)?\s*(?=,|\)|$)")
PARAM_ANN_DEFAULT = re.compile(r"\s*:\s*[A-Za-z_$][\w.]*(?:<[^>]*>)?\s*(?==)")


def process_line(line):
    if line.lstrip().startswith("//") or line.lstrip().startswith("*"):
        return line
    m = FUNC_RE.search(line)
    if not m:
        return line
    params = m.group(2)
    params = PARAM_ANN.sub("", params)
    params = PARAM_ANN_DEFAULT.sub(" ", params)
    return line[: m.start()] + m.group(1) + params + ")" + m.group(4) + line[m.end():]


def main():
    if not os.path.isdir(QML_ROOT):
        print(f"Error: no existe {QML_ROOT}")
        sys.exit(1)

    if "--sin-respaldo" not in sys.argv and not os.path.exists(BACKUP_DIR):
        print(f"Creando respaldo en: {BACKUP_DIR}")
        shutil.copytree(QML_ROOT, BACKUP_DIR)

    changed_files = 0
    changed_lines = 0
    for dirpath, _dirs, files in os.walk(QML_ROOT):
        for fname in files:
            if not (fname.endswith(".qml") or fname.endswith(".qml.inc")):
                continue
            path = os.path.join(dirpath, fname)
            with open(path, encoding="utf-8") as fh:
                lines = fh.readlines()
            new_lines = [process_line(line) for line in lines]
            diff = sum(1 for a, b in zip(lines, new_lines) if a != b)
            if diff:
                changed_files += 1
                changed_lines += diff
                with open(path, "w", encoding="utf-8") as fh:
                    fh.writelines(new_lines)

    print(f"Archivos modificados: {changed_files}")
    print(f"Líneas modificadas: {changed_lines}")

    if changed_files > 0:
        respaldo = f" (respaldo previo en {BACKUP_DIR})" if os.path.isdir(BACKUP_DIR) else ""
        print(f"Listo. Reinicia el shell: caelestia shell -k && caelestia shell -d{respaldo}")


if __name__ == "__main__":
    main()
