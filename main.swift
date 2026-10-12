import Cocoa
import ServiceManagement

// Borderless panel that may sit over the menu bar.
final class Panel: NSPanel {
    override func constrainFrameRect(_ r: NSRect, to s: NSScreen?) -> NSRect { r }
    override var canBecomeKey: Bool { false }
}

// One status item is both divider and toggle. Collapsed, it grows to 10_000pt: everything Cmd-dragged
// left of it is pushed off-screen and macOS drops the oversized item itself, so a floating "<" button
// is shown where it was. Expanding hides the button and shrinks the item back.
final class Ctl: NSObject {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let panel = Panel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
    let stand = NSButton()
    let menu = NSMenu()
    let login = NSMenuItem(title: "Launch at login", action: nil, keyEquivalent: "")
    var collapsed = false  // never persisted: a stale collapsed state would hide icons with no visible cause

    func chevron(_ name: String) -> NSImage? {
        NSImage(systemSymbolName: name, accessibilityDescription: "Show/hide menu bar icons")
    }

    override init() {
        super.init()
        item.autosaveName = "mbm.main"
        item.isVisible = true
        item.button?.target = self
        item.button?.action = #selector(click)
        item.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])  // fire on press, not release
        login.target = self
        login.action = #selector(toggleLogin)
        menu.addItem(login)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        stand.isBordered = false
        stand.image = chevron("chevron.left")
        stand.contentTintColor = .labelColor
        panel.contentView = stand
        panel.ignoresMouseEvents = true  // macOS never delivers clicks over the menu bar to plain windows
        // so clicks on the "<" are caught globally instead.
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] e in
            guard let self, self.collapsed, self.panel.frame.contains(NSEvent.mouseLocation) else { return }
            if e.type == .rightMouseDown {
                self.menu.popUp(positioning: nil, at: NSPoint(x: self.panel.frame.minX, y: self.panel.frame.minY), in: nil)
            } else {
                self.click()
            }
        }
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        render()
    }

    @objc func click() {
        if NSApp.currentEvent?.type == .rightMouseDown {
            login.state = SMAppService.mainApp.status == .enabled ? .on : .off
            item.menu = menu
            item.button?.performClick(nil)
            item.menu = nil
        } else {
            collapsed.toggle()
            render()
        }
    }

    func render() {
        if collapsed, let w = item.button?.window {
            panel.appearance = item.button?.effectiveAppearance  // match the menu bar's light/dark
            panel.setFrame(w.frame, display: true)  // grab the spot before the item is pushed away
            panel.orderFrontRegardless()
            item.length = 10_000
        } else {
            collapsed = false
            panel.orderOut(nil)
            item.length = NSStatusItem.variableLength
            item.button?.image = chevron("chevron.right")
        }
    }

    @objc func toggleLogin() {
        let s = SMAppService.mainApp
        do { if s.status == .enabled { try s.unregister() } else { try s.register() } } catch { NSSound.beep() }
    }
}

NSApplication.shared.setActivationPolicy(.accessory)
let ctl = Ctl()
NSApplication.shared.run()
