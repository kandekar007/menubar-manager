# menubar-manager

Tiny macOS menu bar declutter tool. One `>` chevron hides every icon to its left; click `<` to bring them back.

## Build & run

    ./build.sh && open MenuBarManager.app

## Use

1. Hold Cmd and drag icons you want hidden to the left of `>`.
2. Click `>` to hide them (it becomes `<`), click `<` to show them again.
3. Right-click the chevron for "Launch at login" / Quit.

## Limits

- Apple's own icons (Wi-Fi, battery, clock) can't be hidden this way; use System Settings > Control Center.
- While collapsed, `<` is a floating window, not a real status item, so it can't be Cmd-dragged.
- Collapsed state is not remembered across launches.
