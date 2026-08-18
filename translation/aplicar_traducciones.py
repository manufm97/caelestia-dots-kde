#!/usr/bin/env python3
"""
Aplica / actualiza traducciones español a archivos QML de Caelestia usando qsTr().

Solo traduce cadenas que son texto de usuario visible (labels, títulos, mensajes).
Ignora imports, comandos shell, valores booleanos, variables, propiedades, etc.

EXCLUSIONES (nunca se tocan):
- Claves de objetos JS/QML  ("key": valor)
- Etiquetas de switch/case   (case "x":)
- Strings anidados dentro de otro string (cadenas JS/Python con comillas internas)
- Bloques de strings multilínea (comillas triples)
- Argumentos de comandos (execDetached, notify-send, pkexec, wg-quick, etc.)
- Valores de estado / enum / identificadores técnicos
- Contenido de plantillas de scripts (Python/Shell embebidos)
"""
import json, os, re
from pathlib import Path

QML_ROOT = os.path.expanduser("~/.config/quickshell/caelestia")
JSON_PATH = Path(__file__).parent / "traducciones.json"

with open(JSON_PATH, encoding="utf-8") as f:
    all_translations = json.load(f)

eng_to_spa = {}
for cat, pairs in all_translations.items():
    eng_to_spa.update(pairs)

QSTR_RE = re.compile(r'qsTr\("([^"]+)"\)')

# Líneas que contienen comandos / código que nunca deben traducirse
SKIP_PATTERNS = [
    r'^import\s',
    r'^\s*import\s',
    r'execDetached',
    r'exec\(',
    r'\bqml:',
    r'^\s*case\s',
    r'command\s*:\s*\[',
    r'function\s+\w+\s*\(',
    r'property\s+\w+\s+\w+\s*:',
    r'anchors\.\w+',
    r'when\s*:',
    r'on\w+\s*:',
    r'property\s*:\s*',
    r'\.text\s*=\s*',
    r'\.label\s*=\s*',
    r'PropertyAction\s*\{',
    r'property:\s*qsTr\(',
    r"'''",
    r'"""',
    r'urllib',
    r'pywal',
    r'\.sh"',
    r'notify-send',
    r'pkexec',
    r'warp-cli',
    r'wg-quick',
    r'nmcli',
    r'networkctl',
    r'bash -c',
]

SKIP_VALUES = {
    'true', 'false', 'null', 'undefined',
    'bash', 'sh', 'zsh', 'terminal',
    'quickshell', 'qml', 'js',
    'left', 'right', 'top', 'bottom', 'center',
    'horizontal', 'vertical',
    'fill', 'fit', 'cover',
    'none', 'auto',
    'opacity', 'scale', 'progress', 'pos',
    'circleRadius', 'isExpanded', 'fadingOut', 'hadPrevious',
    'text', 'string', 'number', 'bool', 'object',
    'Home', 'Select a file',
    'Secondary', 'Authorization',
    # Estados / enums / identificadores técnicos
    'stopped', 'running', 'ready', 'connected', 'disconnected', 'connecting',
    'needs-auth', 'error', 'expanded', 'pinned', 'tile', 'float', 'unpin', 'pin',
    'light', 'dark', 'default', 'custom',
    'small', 'normal', 'large', 'extraLarge',
    'description', 'folder', 'image', 'file', 'link', 'tag', 'title', 'date', 'body',
    'category', 'categories', 'purity', 'sorting', 'order', 'topRange', 'atleast',
    'resolutions', 'ratios', 'colors', 'page', 'seed', 'User-Agent',
    'wireguard', 'warp', 'netbird', 'tailscale',
    'fedora', 'arch', 'cachyos', 'endeavouros', 'manjaro', 'ubuntu', 'debian', 'opensuse',
    'content', 'expressive', 'fidelity', 'monochrome', 'neutral', 'tonal-spot',
    'tonalspot', 'vibrant', 'rainbow', 'fruit-salad', 'fruitsalad',
    'claude', 'openai', 'gemini', 'openrouter', 'opencode', 'opencode-go',
    'isUser', 'name', 'dir', 'announce', 'probe', 'connect', 'disconnect',
    'caelestia', 'caelestia-cli', 'caelestia-update-checker',
    # nmcli commands
    'status', 'up', 'down', 'connect', 'disconnect', 'show', 'delete', 'modify',
    'device', 'connection', 'add', 'reload', 'enable', 'disable',
    # git / branch names
    'dev', 'main', 'master',
    # Misc technical
    'PY', 'query', 'to', 'wpa',
    # Colores
    'transparent', 'red', 'green', 'blue', 'white', 'black', 'yellow', 'cyan', 'magenta',
    'gray', 'grey', 'orange', 'purple', 'pink', 'brown',
    # QML/CSS values
    'bold', 'italic', 'underline', 'normal', 'dashed', 'dotted', 'solid',
    'absolute', 'relative', 'fixed', 'static',
    'default', 'inherit', 'initial', 'unset',
    # Nombres de variantes / scheme
    'small', 'normal', 'large', 'extraLarge',
}

SKIP_PREFIXES = ['$', '${', '@', '##', '//']

# Material Design icon names - NEVER translate these
MATERIAL_ICONS = {
    'palette', 'desktop_windows', 'dock_to_bottom', 'dock_to_right', 'wifi', 'bluetooth',
    'volume_up', 'notifications', 'build', 'battery_charging_full', 'keyboard', 'apps',
    'settings_suggest', 'language', 'update', 'extension', 'info', 'smart_toy',
    'settings', 'energy_savings_leaf', 'balance', 'rocket_launch', 'close', 'open_in_new',
    'routine', 'clear_all', 'chat', 'call_split', 'expand_more', 'sports_esports',
    'download', 'login', 'person_add', 'play_circle', 'view_quilt', 'menu_open',
    'arrow_back', 'stop', 'wifi_off', 'cable', 'bluetooth_disabled', 'bluetooth_connected',
    'keyboard_capslock_badge', 'looks_one', 'bedtime', 'battery_full', 'notifications_off',
    'notifications_unread', 'memory', 'memory_alt', 'swap_vert', 'hard_disk', 'north',
    'refresh', 'chevron_left', 'chevron_right', 'skip_previous', 'skip_next',
    'play_arrow', 'shuffle', 'repeat', 'remove', 'logout', 'restart_alt',
    'power_settings_new', 'sentiment_very_dissatisfied', 'android', 'photo_library',
    'collections', 'gif', 'movie', 'image_search', 'slideshow', 'style', 'wallpaper',
    'dark_mode', 'light_mode', 'fullscreen', 'check', 'animated_images',
    'select_to_speak', 'screenshot_region', 'pause', 'stop', 'unfold_more',
    'delete_forever', 'mic', 'colorize', 'vpn_key', 'nutrition', 'workspaces',
    'web_asset', 'widgets', 'signal_cellular_alt', 'schedule', 'dock', 'code',
    'save', 'commit', 'touch_app', 'visibility_off', 'ads_click', 'notifications_off',
    'priority_high', 'location_on', 'location_searching', 'resize', 'page_header',
    'account_tree', 'picture_in_picture_center', 'gradient', 'keep',
    'content_copy', 'aspect_ratio', 'view_agenda', 'tune', 'remove', 'close',
    'settings_backup_restore', 'nfc', 'screen_rotation', 'screenshot',
    'mouse', 'keyboard', 'touch_app', 'fingerprint', 'face', 'qr_code_scanner',
}

# Internal identifiers that should NEVER be translated (used as keys, IDs, etc.)
INTERNAL_IDENTIFIERS = {
    'dashboard', 'launcher', 'session', 'sidebar', 'drawers', 'nexus',
    'tray', 'activeWindow', 'workspaces', 'logo', 'dock', 'clock',
    'statusIcons', 'kbLayoutIndicator', 'notificationsIndicator',
    'perfCpu', 'perfMemory', 'perfStorage', 'perfNetwork', 'perfGpu', 'perfBattery',
    'github', 'showDesktop', 'power', 'showall', 'screenshot', 'googleLens',
    'screenRecording', 'launcherInterrupt', 'aiAssistant', 'utilities', 'emoji',
    'clipboard', 'windowSwitcher', 'windowSwitcherReverse', 'wallpaper', 'keybinds',
    'foot', 'firefox', 'nemo', 'kcolorpicker',
    'workspace1', 'workspace2', 'workspace3', 'workspace4', 'workspace5',
    'workspace6', 'workspace7', 'workspace8', 'workspace9', 'workspace10',
    'krohnkite', 'krohnkiteLayout', 'krohnkiteLayoutReverse',
    'activewindow', 'network', 'ethernet', 'wirelesspassword', 'battery',
    'peripheralBattery', 'github', 'audio', 'nightlight', 'kblayout',
    'lockstatus', 'notifications', 'dockhover', 'dockcontext', 'active',
    'personalization', 'connectivity', 'controls', 'shell', 'system',
    'Blur',
    'background', 'top-left', 'top-center', 'top-right', 'middle-left',
    'middle-center', 'middle-right', 'bottom-left', 'bottom-center', 'bottom-right',
    'left', 'right', 'top', 'bottom', 'center',
    'middle', 'component', 'library', 'drag_indicator',
    'area-picker', 'screenshotFreeze', 'screenshotClip', 'screenshotFreezeClip',
    'regionScreenshot', 'regionSearch', 'regionOcr', 'regionRecord', 'regionRecordWithSound',
    'border-exclusion', 'sidebar', 'shimeji',
    'apps', 'actions', 'calc', 'scheme', 'variant',
    'wallpapers', 'windowSwitcher', 'keybinds', 'animations',
    'noMedia', 'loading', 'hasLyrics', 'noLyrics', 'open',
    'attachedToSidebar', 'unlock',
    'store_disk', 'store_cache', 'custom_', 'application-x-executable', 'Unknown Component',
    'visible', 'roleValue',
    'app2unit', 'x,y',
    'Password entry',
    # KWin window properties
    'normal', 'dialog', 'toolbar', 'utility', 'dock', 'desktop', 'splash', 'notification',
    'popup', 'onScreenDisplay', 'menu', 'override', 'input',
}

stats = {"checked": 0, "new": 0, "updated": 0, "added_to_json": 0, "files": set()}
json_modified = False

def should_skip_string(text):
    if not text or len(text) < 3:
        return True
    if text.lower() in {v.lower() for v in SKIP_VALUES}:
        return True
    if text in INTERNAL_IDENTIFIERS:
        return True
    if text in MATERIAL_ICONS:
        return True
    if any(text.startswith(p) for p in SKIP_PREFIXES):
        return True
    if re.match(r'^[A-Z_][A-Z0-9_]*$', text):
        return True
    if re.match(r'^\d+(\.\d+)?$', text):
        return True
    if re.match(r'^[a-z]+(\.[a-z]+)+$', text):
        return True
    if '/' in text and not ' ' in text:
        return True
    if text.startswith('-') or text.endswith('-'):
        return True
    if '.' in text and not ' ' in text:
        return True
    if ':' in text:
        return True
    return False


def is_in_triple_string(lines, idx):
    """True si la línea idx está dentro de un bloque ''' o \"\"\" (o lo abre/cierra)."""
    in_block = False
    for j in range(idx + 1):
        line = lines[j]
        opens = line.count("'''") + line.count('"""')
        # Cada bloque de 3 comillas abre y cierra; alterna el estado por cada aparición
        if opens % 2 == 1:
            in_block = not in_block
    return in_block


def find_string_literals(line):
    """Encuentra literales de string, devolviendo (start, end, quote, content)."""
    result = []
    i = 0
    n = len(line)
    while i < n:
        ch = line[i]
        if ch in ('"', "'"):
            # saltar triples
            if line[i:i+3] == ch*3:
                i += 3
                continue
            j = i + 1
            while j < n:
                if line[j] == '\\':
                    j += 2
                    continue
                if line[j] == ch:
                    break
                j += 1
            if j < n:
                result.append((i, j + 1, ch, line[i+1:j]))
            i = j + 1
        else:
            i += 1
    return result


def find_localize_english_spelling(line):
    """Encuentra Strings.localizeEnglishSpelling("...") y devuelve (start, end, content)."""
    pattern = r'Strings\.localizeEnglishSpelling\("([^"]+)"\)'
    matches = list(re.finditer(pattern, line))
    result = []
    for match in matches:
        result.append((match.start(), match.end(), match.group(1)))
    return result


def is_key_position(line, start, end):
    """True si el literal está en posición de clave de objeto (seguido de ':')."""
    rest = line[end:]
    m = re.match(r'\s*:', rest)
    return m is not None


def is_inside_other_string(line, start):
    """True si el literal empieza dentro de otro string (comillas desbalanceadas antes)."""
    before = line[:start]
    # contar comillas simples y dobles antes, fuera de comentarios aproximados
    return before.count('"') % 2 == 1 or before.count("'") % 2 == 1


def is_command_context(line, start):
    """True si el literal está dentro de una llamada a comando o array CLI."""
    # dentro de execDetached([...]), ["cmd", arg], etc.
    before = line[:start]
    return bool(re.search(r'(execDetached|exec)\s*\(', before)) or \
           bool(re.search(r'\[\s*"', before))


def is_property_value_context(line, start):
    """True si el literal es valor de una propiedad que NO debe traducirse."""
    before = line[:start].rstrip()
    # icon: "..."
    if re.search(r'\bicon\s*:\s*$', before):
        return True
    # category: "..."
    if re.search(r'\bcategory\s*:\s*$', before):
        return True
    # name: "..." (internal identifiers)
    if re.search(r'\bname\s*:\s*$', before):
        return True
    # roleValue: "..."
    if re.search(r'\broleValue\s*:\s*$', before):
        return True
    # properties: "x,y" (NumberAnimation)
    if re.search(r'\bproperties\s*:\s*$', before):
        return True
    # keys: [... "..." ...]
    if re.search(r'\bkeys\s*:\s*\[', before):
        return True
    # reloadableId: "..."
    if re.search(r'\breloadableId\s*:\s*$', before):
        return True
    # pagePath: "..."
    if re.search(r'\bpagePath\s*:\s*$', before):
        return True
    # fallbackIcon: "..."
    if re.search(r'\bfallbackIcon\s*:\s*$', before):
        return True
    # activeIcon: "..."
    if re.search(r'\bactiveIcon\s*:\s*$', before):
        return True
    # signal: "..."
    if re.search(r'\bsignal\s*:\s*$', before):
        return True
    # themeVariant: "..."
    if re.search(r'\bthemeVariant\s*:\s*$', before):
        return True
    return False


def is_return_or_comparison_context(line, start):
    """True si el literal está en un return o comparación === con un identificador."""
    before = line[:start].rstrip()
    # return "..."
    if re.search(r'\breturn\s+$', before):
        return True
    # === "..." or !== "..."
    if re.search(r'[!=]==?\s*$', before):
        return True
    return False


def is_translatable_line(line):
    stripped = line.strip()
    if not stripped:
        return False
    for pattern in SKIP_PATTERNS:
        if re.search(pattern, stripped):
            return False
    if 'command:' in stripped or 'command =' in stripped:
        return False
    if '`' in stripped or '$(' in stripped:
        return False
    if stripped.startswith('property'):
        return False
    if stripped.startswith('[') and stripped.endswith(']'):
        return False
    if stripped.startswith('{'):
        return False
    return True


for root, dirs, files in os.walk(QML_ROOT):
    for file in files:
        if not file.endswith(".qml"):
            continue
        path = os.path.join(root, file)
        with open(path, encoding="utf-8") as f:
            lines = f.readlines()
        changed = False

        for i, line in enumerate(lines):
            if not is_translatable_line(line):
                continue
            if is_in_triple_string(lines, i):
                continue

            # Si la línea ya tiene qsTr(), solo actualizar el texto español
            qstr_match = QSTR_RE.search(line)
            if qstr_match:
                current_text = qstr_match.group(1)
                if should_skip_string(current_text):
                    continue
                new_spa = eng_to_spa.get(current_text)
                if new_spa is not None and new_spa != current_text:
                    old_line = lines[i]
                    lines[i] = line.replace(f'qsTr("{current_text}")', f'qsTr("{new_spa}")')
                    if lines[i] != old_line:
                        stats["updated"] += 1
                        changed = True
                continue

            for (start, end, quote, eng_text) in find_string_literals(line):
                if len(eng_text) < 3:
                    continue
                if not re.match(r'^[A-Za-z]', eng_text):
                    continue
                if should_skip_string(eng_text):
                    continue
                # Reglas duras: nunca envolver strings con comillas internas,
                # expansión shell ($HOME, $(...)), backticks, o comandos shell
                if '"' in eng_text or "'" in eng_text or '`' in eng_text:
                    continue
                if re.search(r'\$\w', eng_text):
                    continue
                if re.match(r'^\s*(mkdir|kwriteconfig6|qdbus6|qdbus|sed|printf|rm|cp|mv|echo|killall|pkill|systemctl|hyprctl|playerctl|grep|awk|bash|sh|pkexec|wg|warp-cli|nmcli|networkctl|date|touch|chmod|chown|ln|scrot|grim|swappy|swaync|notify-send)\b', eng_text):
                    continue
                # Posiciones conflictivas: clave de objeto, dentro de otro string,
                # o dentro de un array de comandos
                if is_key_position(line, start, end):
                    continue
                if is_inside_other_string(line, start):
                    continue
                if is_command_context(line, start):
                    continue
                # Propiedades que NO deben traducirse (icon, category, name, etc.)
                if is_property_value_context(line, start):
                    continue
                # Return/comparación con identificadores internos
                if is_return_or_comparison_context(line, start):
                    continue
                # Identificadores internos conocidos
                if eng_text in INTERNAL_IDENTIFIERS:
                    continue
                # Nombres de iconos Material Design
                if eng_text in MATERIAL_ICONS:
                    continue

                spa_text = eng_to_spa.get(eng_text)
                if spa_text is not None:
                    old_line = lines[i]
                    lines[i] = line.replace(f'{quote}{eng_text}{quote}', f'qsTr("{spa_text}")')
                    if lines[i] != old_line:
                        stats["new"] += 1
                        changed = True
                else:
                    if eng_text not in eng_to_spa:
                        eng_to_spa[eng_text] = eng_text
                        all_translations.setdefault("Nuevas cadenas", {})[eng_text] = eng_text
                        json_modified = True
                        stats["added_to_json"] += 1
                    old_line = lines[i]
                    lines[i] = line.replace(f'{quote}{eng_text}{quote}', f'qsTr("{eng_text}")')
                    if lines[i] != old_line:
                        stats["new"] += 1
                        changed = True

        # Handle Strings.localizeEnglishSpelling("...") -> translate content, preserve function
        for i, line in enumerate(lines):
            matches = list(re.finditer(r'Strings\.localizeEnglishSpelling\("([^"]+)"\)', line))
            for match in reversed(matches):
                eng_text = match.group(1)
                spa_text = eng_to_spa.get(eng_text)
                if spa_text is not None and spa_text != eng_text:
                    old_line = lines[i]
                    lines[i] = lines[i].replace(
                        f'Strings.localizeEnglishSpelling("{eng_text}")',
                        f'Strings.localizeEnglishSpelling("{spa_text}")'
                    )
                    if lines[i] != old_line:
                        stats["new"] += 1
                        changed = True
                elif eng_text not in eng_to_spa:
                    eng_to_spa[eng_text] = eng_text
                    all_translations.setdefault("Nuevas cadenas", {})[eng_text] = eng_text
                    json_modified = True
                    stats["added_to_json"] += 1

        if changed:
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(lines)
            stats["files"].add(path)
        stats["checked"] += 1

if json_modified:
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(all_translations, f, ensure_ascii=False, indent=2)
    print(f"Cadenas nuevas agregadas al JSON: {stats['added_to_json']}")

# Post-processing: fix //@ pragmas y revertir strings técnicos
pragma_fixed = 0
revert_fixed = 0
NEVER_TRANSLATE_POST = {
    'undefined', 'string', 'number', 'boolean', 'object',
    'true', 'false', 'null',
    'left', 'right', 'top', 'bottom', 'center',
    'bash', 'sh', 'zsh', 'terminal',
    'Secondary', 'Primary', 'Authorization',
    'opacity', 'scale', 'progress', 'pos', 'radius',
    'dev', 'main', 'master', 'none', 'auto',
    'fill', 'fit', 'cover', 'horizontal', 'vertical',
    'status', 'up', 'down', 'connect', 'disconnect', 'show', 'delete', 'modify',
    'device', 'connection', 'add', 'reload', 'enable', 'disable',
    'PY', 'query', 'to', 'wpa',
    'connected', 'disconnected', 'connecting', 'error', 'needs-auth',
    'expanded', 'pinned', 'tile', 'float', 'light', 'dark', 'custom',
    'wireguard', 'warp', 'netbird', 'tailscale',
    'categories', 'purity', 'sorting', 'order', 'topRange', 'atleast',
    'resolutions', 'ratios', 'colors', 'page', 'seed', 'User-Agent',
    'tag', 'title', 'date', 'body', 'name', 'dir', 'isUser',
    'fedora', 'arch', 'cachyos', 'endeavouros', 'manjaro', 'ubuntu', 'debian', 'opensuse',
    'tonalspot', 'vibrant', 'expressive', 'fidelity', 'fruitsalad',
    'monochrome', 'neutral', 'rainbow', 'content',
    'claude', 'openai', 'gemini', 'openrouter', 'opencode', 'opencode-go',
    'caelestia', 'caelestia-cli', 'caelestia-update-checker',
    # Colores
    'transparent', 'red', 'green', 'blue', 'white', 'black', 'yellow', 'cyan', 'magenta',
    'gray', 'grey', 'orange', 'purple', 'pink', 'brown',
    # QML/CSS values
    'bold', 'italic', 'underline', 'normal', 'dashed', 'dotted', 'solid',
    'absolute', 'relative', 'fixed', 'static',
    'default', 'inherit', 'initial', 'unset',
}

for root, dirs, files in os.walk(QML_ROOT):
    for file in files:
        if not file.endswith(".qml"):
            continue
        path = os.path.join(root, file)
        with open(path, encoding="utf-8") as f:
            content = f.read()

        new_content = content

        # Fix //@ pragmas -> //
        new_content = new_content.replace('//@ pragma', '// pragma')

        # Revertir qsTr() para strings técnicos
        for word in NEVER_TRANSLATE_POST:
            new_content = new_content.replace(f'qsTr("{word}")', f'"{word}"')

        # Fix paréntesis rotos: qsTr("word")) -> "word")
        new_content = re.sub(r'qsTr\("([^"]+)"\)\)', r'"\1")', new_content)

        if new_content != content:
            with open(path, "w", encoding="utf-8") as f:
                f.write(new_content)
            if '//@ pragma' in content:
                pragma_fixed += 1
            revert_fixed += 1

if pragma_fixed > 0:
    print(f"Pragmas //@ corregidos: {pragma_fixed}")
if revert_fixed > 0:
    print(f"Cadenas técnicas revertidas: {revert_fixed}")

print(f"Revisados: {stats['checked']} archivos")
print(f"Nuevas traducciones (inglés→español): {stats['new']}")
print(f"Actualizadas por cambio en JSON: {stats['updated']}")
print(f"Archivos modificados: {len(stats['files'])}")
print(f"Cadenas añadidas al JSON: {stats['added_to_json']}")

if stats["new"] > 0 or stats["updated"] > 0:
    print("\nReiniciando Caelestia shell...")
    os.system("caelestia shell -k 2>/dev/null")
    import time
    time.sleep(1)
    os.system("caelestia shell -d &")
    print("Hecho.")
