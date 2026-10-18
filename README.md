# GamepadDot

World of Warcraft addon that enables or disables the gamepad center dot (`GamepadReticle`), with an optional custom dot.

Tested on WoW Forever (Classic beta, interface 16001).

## Install
Copy the `GamepadDot` folder into `World of Warcraft\<client>\Interface\AddOns\`, then `/reload`.

## Commands
| Command | Effect |
|---|---|
| `/gdot` | open options window |
| `/gdot show` / `on` | enable the dot |
| `/gdot hide` / `off` | disable the dot (default) |
| `/gdot custom` | toggle a custom dot at screen center |
| `/gdot size N`, `/gdot color r g b` | style the custom dot |

## Notes
Only touches Blizzard's `GamepadReticle` frame. If a patch renames it, hiding stops working.

License: MIT
