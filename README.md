<div align="left">
  <img width="25%" alt="guhShot" src="https://github.com/user-attachments/assets/0ba5d51a-91ac-4b3e-88ca-b70d6158a691"/>
  <h3>Guh?? Take a screenshot!</h3>
</div>

---
> ### **Suckless Wayland Screenshot Utility**
>
> guhShot is a minimalist screenshot utility written in C. Designed for [guhwm](https://github.com/Tapi-Mandy/guhwm) and other wlroots-based compositors.
---

## Installation
### <sub><img src="https://cdn.simpleicons.org/archlinux/1793D1" height="25" width="25"></sub> Arch Linux

```bash
git clone --depth 1 https://github.com/Tapi-Mandy/guhShot.git
cd guhShot
# Edit config.h to set your preferred defaults
makepkg -si
```

## Screenshots
<p align="center">
  <img alt="Notification Preview" src="https://github.com/user-attachments/assets/445ed34e-6052-4988-ad47-123fcf127297" width="69%"/>
  <img alt="Swappy" src="https://github.com/user-attachments/assets/aacc069b-c552-493d-b9ac-60ff54d593ac" width="47%"/>
  <img alt="Region Selection" src="https://github.com/user-attachments/assets/26f8d900-3e7e-42ce-ac54-fdda1bce896f" width="47%"/>
</p>

## Usage
guhShot is intended to be used on minimalist window manager setups. Keybindings are the way it's intended to be used, however you can use the commands with CLI flags without keybindings obviously.

Running `guhshot` without an action or modifier will display the help menu.

Settings (Save/Copy) are persistent. If you disable saving with -s, it will remain disabled for all future screenshots until you re-enable it with -S. The persistent state will be saved to `~/.cache/guhshot/state`.

### Actions
| Argument | Short | Description |
| :--- | :--- | :--- |
| `--full` | `-f` | Capture all monitors (Default for single monitor setups) |
| `--monitor` | `-m` | Capture the focused monitor (For multi-monitor setups) |
| `--region` | `-r` | Select a region to capture |

### Modifiers
| Argument | Short | Description |
| :--- | :--- | :--- |
| `--enable-save` | `-S` | Save to disk |
| `--disable-save` | `-s` | Disable saving to disk |
| `--enable-copy` | `-C` | Copy to clipboard |
| `--disable-copy` | `-c` | Disable copying to clipboard |
| `--swappy` | `-e` | Edit with swappy before saving |

## Keybinds
> **Note:** The main modifier key used in these examples is **Alt**.
>
> Also with the recommended setups for a single monitor. If you have multiple monitors, it's probably better to use `--monitor` (or `-m`) instead of `--full` (`-f`)
### dwl (config.h)
```c
{ MODKEY,                    XKB_KEY_s,           spawn,            SHCMD("/usr/sbin/guhshot --full") },
{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_s,           spawn,            SHCMD("/usr/sbin/guhshot --region") },
{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_s,           spawn,            SHCMD("/usr/sbin/guhshot --region --swappy") },
```

### MangoWC (config.conf)
```ini
bind=ALT, S, spawn, guhshot --full
bind=ALT+SHIFT, S, spawn, guhshot --region
bind=ALT+CTRL, S, spawn, guhshot --region --swappy
```

### Hyprland (hyprland.conf)
```ini
bind = ALT, S, exec, guhshot --full
bind = ALT SHIFT, S, exec, guhshot --region
bind = ALT CONTROL, S, exec, guhshot --region --swappy
```

### Sway (config)
```bash
bindsym Mod1+s exec guhshot --full
bindsym Mod1+Shift+s exec guhshot --region
bindsym Mod1+Control+s exec guhshot --region --swappy
```

### River (init)
```bash
riverctl map normal Alt S spawn "guhshot --full"
riverctl map normal Alt+Shift S spawn "guhshot --region"
riverctl map normal Alt+Control S spawn "guhshot --region --swappy"
```
