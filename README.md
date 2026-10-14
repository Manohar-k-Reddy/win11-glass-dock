# win11-glass-dock

A clean, floating dock-style taskbar and matching Start menu for Windows 11, built with [Windhawk](https://windhawk.net/) style rules, plus a small debloat script.

![Taskbar](screenshots/taskbar.png)

- **Auto-sizing dock**: the app pill shrinks and grows with your icons and stays centered
- **Matching tray pill** on the right: same dark glass, 16px corners, 1px edge
- **Start menu to match**: same glass, edge and corners, no Recommended section, no Phone Link panel
- **Follows dark/light mode**: colors come from Windows theme resources, not hardcoded values
- **Lightweight**: styles are applied inside the real taskbar, no extra always-running app besides Windhawk

## Install

1. Install Windhawk: `winget install RamenSoftware.Windhawk` (or from [windhawk.net](https://windhawk.net/))
2. In Windhawk → **Explore**, install:
   - **Windows 11 Taskbar Styler**
   - **Windows 11 Start Menu Styler**
3. Import the styles (run as admin, or double-click each file):
   ```
   reg import windhawk\taskbar-styler.reg
   reg import windhawk\start-menu-styler.reg
   ```
4. Restart Explorer: `Stop-Process -Name explorer -Force`. The taskbar may take 15–30 seconds to reappear while Windhawk loads.

### Recommended Windows settings
- Dark mode on
- Taskbar search box hidden, Task View hidden, icons centered (Settings → Personalization → Taskbar)

### Start menu centering
The Start menu is shifted with `TranslateTransform X="110" Y="12"` (in `start-menu-styler.reg`) to sit centered above the dock. That value was measured on a **1920×1080 screen at 125% scaling**. On other setups, open Start, check how far it is from center, and adjust `X` in Windhawk → Start Menu Styler → Settings.

## Scripts (optional)

Review before running, and run in an elevated PowerShell.

| Script | What it does |
|---|---|
| `scripts/debloat.ps1` | Removes Bing/news/Xbox/Teams/etc. Store apps, turns off ads, suggestions, telemetry (to minimum), Copilot and Recall, shows file extensions, restores the classic right-click menu. Edit the `$apps` list to keep anything you use. |
| `scripts/disable-web-search.ps1` | Removes web/Bing/Store results from Start menu search (policy). Sign out or restart to apply. |

Everything removed can be reinstalled from the Microsoft Store.

## Undo

- Turn off or uninstall the two Windhawk mods to get the stock taskbar and Start menu back instantly.
- Windhawk can be uninstalled like any app.

## Known limitations

- The clock and tray icons can't be moved out of the tray pill. Windows clips them to the tray's container.
- A full-width tinted strip behind the dock isn't possible with the auto-sizing layout. The taskbar doesn't expose a full-width layer in that mode.
- Big Windows feature updates can temporarily break Windhawk style rules until the mods are updated.
