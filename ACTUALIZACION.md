# Actualizar Caelestia (manteniendo las modificaciones locales)

Guía práctica para actualizar esta instalación de Caelestia a la última
versión del upstream **sin perder las modificaciones locales**.

> **💡 Ya está automatizado.** Lo normal es ejecutar un único comando:
> ```bash
> caelestia-actualizar          # backup + actualizar + rebuild + reiniciar
> caelestia-actualizar --check  # solo comprobar si hay novedades
> ```
> El script vive en `~/.local/bin/caelestia-actualizar` (fuera del repo, por
> lo que sobrevive a cualquier `reset --hard`) y hace todo lo de esta guía
> automáticamente: backup rotativo, sincronizar fuentes, restaurar el módulo
> `Internal/`, re-añadir `add_subdirectory(Internal)`, recompilar y reiniciar,
> y **restaurar los QML personalizados** (transparencias, reloj con segundos,
> shimeji/Pusheen, visualizador, `DesktopClockOld`/`DesktopLyricsOld`, toasts
> en español, iconos Papirus-Dark).
>
> El timer systemd existe pero está **desactivado** (modo manual). Si algún día
> quieres que se actualice solo, actívalo con:
> ```bash
> systemctl --user enable --now caelestia-update.timer
> ```
> Y para programarlo a una hora concreta, edita `OnCalendar=` en
> `~/.config/systemd/user/caelestia-update.timer`.
>
> Los pasos manuales de abajo quedan como referencia y para depurar.

---

## 1. Qué es cada cosa

| Pieza | Ruta / URL | Notas |
|---|---|---|
| Repo local | `~/caelestia-dots-kde` | Tu fork, rama `main` |
| Remoto `origin` (y `fork`) | `github.com/manufm97/caelestia-dots-kde` | Tu fork en GitHub |
| Remoto `upstream` | `github.com/caelestia-kde/caelestia` | Proyecto original (fuente de la última versión). El repo se movió aquí desde `ladybug-me/caelestia-kde` |
| Submódulos | `src/dots`, `src/yet-another-monochrome-icon-set` | Se actualizan con el repo |
| Shell (QML) instalado | `~/.config/quickshell/caelestia/` | Lo despliega `update.sh` |
| Plugin nativo compilado | `~/.local/lib/qt6/qml/Caelestia/` | Lo compila el build del shell |
| Binarios/librerías | `~/.local/bin/caelestia-*`, `~/.local/lib/caelestia/` | Instalación "source" (home) |
| CLI | `/usr/bin/caelestia` | Paquete AUR `caelestia-cli`, se actualiza aparte |

> La instalación es de tipo **source** (en `$HOME/.local`), no "package".
> Lo decide `scripts/lib/install-kind.sh` según dónde viva el repo.

---

## 2. Cuáles son las modificaciones locales (lo que hay que conservar)

1. **Módulo `Caelestia.Internal`** — `shell/plugin/src/Caelestia/Internal/`
   (carpeta **untracked**, no está en git). Upstream lo eliminó en el commit
   `6c4c50b1` ("dissolve Caelestia.Internal") moviendo sus clases a
   `Components/`, `Services/`, `Images/` y `Models/`. Aquí se conserva como
   módulo aparte porque el shell instalado aún lo importa.

2. **Config instalada con personalizaciones** — `~/.config/quickshell/caelestia/`:
   componentes que importan `Caelestia.Internal` (`CircularIndicator.qml`,
   `StyledProgressBar.qml`, `Visualiser.qml`, `NetworkCard.qml`, `NetworkUsage.qml`,
   `Hypr.qml`), el módulo `Shimeji`, y assets/wallpapers propios.

3. **Plugin compilado** — `~/.local/lib/qt6/qml/Caelestia/Internal/` (el `.so`).

4. **QML personalizados** (modificaciones de la sesión 24-25/11/2026, copia
   canónica en `~/.config/caelestia-kde/mods/qml/` con parches + copias
   completas; los restaura el paso "5b" del script DESPUÉS del deploy, porque
   el prune del artefacto precompilado borra lo que upstream no trae):
   - Transparencias: fondo del dock, del tray y de los indicadores (KbLayout,
     Notifications).
   - Reloj de la barra: hora arriba con segundos, fecha `dd/MM/yyyy` abajo.
   - Shimeji Pusheen: `modules/shimeji/` + `assets/shimeji/pusheen/` + wiring
     en `shell.qml` + clave `shimeji` de `shell.json`.
   - Toasts personalizados en español desde `services/Hypr.qml` (+ `HyprlandData.qml`);
     los nativos de v2.7.6 (`toasts.capsLockChanged/numLockChanged`) en `false`.
   - Visualizador de audio (`Visualiser.qml`, adaptado a v2.7.6).
   - `DesktopClockOld.qml` y `DesktopLyricsOld.qml` (versiones antiguas con
     sufijo `Old`, conectadas por loaders propios en `Background.qml`).
     letras antiguas ocultan el "Loading lyrics..." a los 10s sin resultados,
     para vídeos que no son música).
   - Esta misma documentación (copia canónica en
     `~/.config/caelestia-kde/mods/ACTUALIZACION.md`; se restaura al raíz
     tras cada actualización: si llega a commitirse, el `reset` la borra).
   - `kdeglobals`: `[Icons] Theme=Papirus-Dark`, `[KDE] OSDEnabled=false`.

> Nota: en v2.7.6 `install.sh` y `scripts/setup.sh` ya son ejecutables (755),
> así que ya no hace falta tocar los bits de ejecución.

---

## 3. Procedimiento de actualización

### Paso 0 — Backup (hazlo SIEMPRE antes)

```bash
cd ~/caelestia-dots-kde
D="$(date +%Y%m%d)"
mkdir -p ~/backups/caelestia-backup-$D

# Historia completa de git (todas las ramas/refs)
git bundle create ~/backups/caelestia-backup-$D/repo.bundle --all

# Working tree completo (incluye la carpeta untracked Internal/)
tar -C ~ --exclude='caelestia-dots-kde/.git' -cf - caelestia-dots-kde \
  | zstd -3 -T0 -o ~/backups/caelestia-backup-$D/worktree.tar.zst

# Estado instalado (config + plugin compilado)
tar -cf - .local/lib/qt6/qml/Caelestia .local/lib/caelestia \
  .local/bin/caelestia-* .config/quickshell/caelestia \
  .config/caelestia .config/caelestia-kde 2>/dev/null \
  | zstd -5 -T0 -o ~/backups/caelestia-backup-$D/instalado.tar.zst

# Y guarda el estado actual en una rama local (por si acaso)
git branch backup/pre-update main
git add -A && git commit -m "WIP backup pre-update"   # en backup/pre-update
git checkout main
```

### Paso 1 — Sincronizar tu fork con upstream

En GitHub: botón **Sync fork** (o desde CLI):

```bash
git fetch upstream main
git push origin upstream/main:main
```

Esto deja `origin/main` (tu fork) en la última versión.

### Paso 2 — Actualizar la rama local

```bash
cd ~/caelestia-dots-kde
git fetch origin main

# Si la rama local no tiene commits propios que conservar:
git reset --hard origin/main

# Submódulos
git submodule sync --recursive
git submodule update --init --recursive
```

> Si el árbol local hubiera divergido y quieres conservar commits locales,
> usa `git merge origin/main` en lugar de `reset --hard`.

### Paso 3 — Restaurar las modificaciones

```bash
# Recuperar el módulo Internal/ desde el backup (o la rama backup/pre-update)
git checkout backup/pre-update -- shell/plugin/src/Caelestia/Internal
git restore --staged shell/plugin/src/Caelestia/Internal   # dejarlo untracked
```

> **Importante:** para que el módulo `Internal/` se **recompile** como parte del
> plugin, hay que volver a añadir la línea `add_subdirectory(Internal)` en
> `shell/plugin/src/Caelestia/CMakeLists.txt` (upstream la quitó en el dissolve).
>
> **Pero en la práctica ya no se recompila:** `08-build-shell.sh` usa
> **artefactos precompilados** del release (rápido, sin compilar ffmpeg) cuando
> `HEAD` está en el tag del release o en `origin/main`. En ese modo no hay
> compilación local, así que el `.so` de `Internal/` se queda tal cual. **No es
> un problema**: el módulo `Internal` es **autocontenido** (solo enlaza contra
> Qt — `Qt::Gui`, `Qt::Quick`, `Qt::Network` —, **no** contra
> `libcaelestia-core.so`), por lo que su binario sobrevive a cualquier cambio de
> versión de Caelestia mientras Qt6 mantenga su ABI. Solo habría que
> recompilarlo si editas su código o si llegara Qt7.

### Paso 4 — Rebuild y redeploy

```bash
cd ~/caelestia-dots-kde
bash update.sh
```

`update.sh` hace: fetch + pull, actualiza submódulos, despliega configs
(`scripts/03-deploy-configs.sh`), recompila el shell (`scripts/08-build-shell.sh`)
y reinicia la shell. Para recompilar solo el plugin:

```bash
bash scripts/08-build-shell.sh
```

### Paso 5 — Verificar

```bash
caelestia shell -l        # logs de la shell
caelestia shell -k        # matar y reiniciar la shell si falla
```

---

## 4. Trampas conocidas (causa de dolores previos)

1. **Archivos de root dentro del repo** — una instalación previa con `sudo`
   dejó `.git/objects`, el binario `caelestia-install` y la carpeta `Internal/`
   propiedad de root, lo que bloqueaba `git fetch` ("cannot lock ref"). Fix:

   ```bash
   sudo chown -R manu:manu ~/caelestia-dots-kde
   ```

2. **`Internal/` es untracked** — `update.sh` hace `git stash` de cambios
   *tracked*, pero no toca lo untracked. Asegúrate de tenerlo en el backup y
   restaurarlo después (Paso 3).

3. **El dissolve de `Caelestia.Internal`** — si en el futuro el shell instalado
   deja de importar `Caelestia.Internal`, puedes migrar la config a
   `Caelestia.Components`/`Caelestia.Services` y eliminar la carpeta
   `Internal/` + su `add_subdirectory`. Mientras la config instalada lo importe,
   basta con que el `.so` instalado siga presente en
   `~/.local/lib/qt6/qml/Caelestia/Internal/` (no hace falta recompilarlo, es
   autocontenido).

4. **El CLI (`caelestia-cli`) es un paquete AUR aparte** — no se actualiza con
   el repo:
   ```bash
   paru -S caelestia-cli
   ```

5. **No mezclar tipos de instalación** — si el repo pasa a `/usr/...` (package),
   los destinos cambian a `/usr/lib/qt6/qml` y `/etc/xdg/quickshell/caelestia`.

6. **Reinicio de la shell tras actualizar** — `restart_shell.sh` hace
   `systemctl --user restart caelestia-shell.service`. Si aún corriera una
   instancia vieja bajo `app-caelestiashell@autostart.service` (la entrada de
   autostart antigua, ya retirada), quickshell detecta "An instance of this
   configuration is already running" y el reinicio no surte efecto. Se resuelve
   parando la instancia vieja una sola vez:
   ```bash
   systemctl --user stop app-caelestiashell@autostart.service
   systemctl --user start caelestia-shell.service
   ```
   Ya está hecho en esta instalación; a partir de ahora solo existe
   `caelestia-shell.service`.

---

## 5. Backup de la última actualización (referencia)

Creado en `~/backups/caelestia-backup-20261123/`:
- `caelestia-repo-20261123.bundle` — historia git completa
- `caelestia-dots-kde-worktree.tar.zst` — árbol de trabajo (incl. `Internal/`)
- `caelestia-installed-home.tar.zst` — config + plugin instalados
- `caelestia-installed-system.tar.zst` — `/usr/share/caelestia` y `/usr/bin/caelestia`

Rama local `backup/pre-update-main` con un commit WIP que captura el estado
previo a la actualización (incluida la carpeta `Internal/`).
