import Cocoa
import WebKit

// ------------------------------------------------------------
// JavaScript side of the native pointer-lock bridge
// ------------------------------------------------------------

let pointerLockJS = """
(function() {
    if (window.__nativePointerLockInstalled)
        return;

    window.__nativePointerLockInstalled = true;

    let lockedElement = null;

    function dispatchChange() {
        document.dispatchEvent(new Event("pointerlockchange"));
    }

    // Eaglercraft checks this exact value against its canvas.
    Object.defineProperty(document, "pointerLockElement", {
        configurable: true,
        get: function() {
            return lockedElement;
        }
    });

    // Also expose the prefixed property just in case.
    Object.defineProperty(document, "mozPointerLockElement", {
        configurable: true,
        get: function() {
            return lockedElement;
        }
    });

    Element.prototype.requestPointerLock = function() {
        const element = this;

        lockedElement = element;

        window.webkit.messageHandlers.pointerLock.postMessage({
            action: "lock"
        });
    };

    document.exitPointerLock = function() {
        if (!lockedElement)
            return;

        window.webkit.messageHandlers.pointerLock.postMessage({
            action: "unlock"
        });
    };

    // Native side calls this after it has captured the mouse.
    window.__nativePointerLockDidLock = function() {
        dispatchChange();
    };

    // Native side calls this after releasing the mouse.
    window.__nativePointerLockDidUnlock = function() {
        lockedElement = null;
        dispatchChange();
    };

    // Send a real mousemove event to the actual Eaglercraft canvas.
    window.__nativeMouseMove = function(dx, dy) {
        if (!lockedElement)
            return;

        const rect = lockedElement.getBoundingClientRect();

        const event = new MouseEvent("mousemove", {
            bubbles: true,
            cancelable: true,
            view: window,

            clientX: rect.left + rect.width / 2,
            clientY: rect.top + rect.height / 2,

            movementX: dx,
            movementY: dy
        });

        // Extra protection for WebKit implementations that don't
        // populate movementX/Y from the constructor.
        try {
            Object.defineProperty(event, "movementX", {
                value: dx,
                configurable: true
            });

            Object.defineProperty(event, "movementY", {
                value: dy,
                configurable: true
            });
        } catch (_) {}

        lockedElement.dispatchEvent(event);
    };

    // F8 uses this to toggle the lock.
    window.__nativeTogglePointerLock = function() {
        if (lockedElement) {
            document.exitPointerLock();
            return;
        }

        const canvas = document.querySelector("canvas");

        if (canvas) {
            canvas.requestPointerLock();
        }
    };
})();
"""

// ------------------------------------------------------------
// Bridge between JavaScript and Swift
// ------------------------------------------------------------

final class PointerLockBridge: NSObject, WKScriptMessageHandler {

    weak var app: AppDelegate?

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            message.name == "pointerLock",
            let body = message.body as? [String: Any],
            let action = body["action"] as? String
        else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch action {
            case "lock":
                self.app?.enableMouseLock()

            case "unlock":
                self.app?.disableMouseLock()

            default:
                break
            }
        }
    }
}

// ------------------------------------------------------------
// App
// ------------------------------------------------------------

final class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var webView: WKWebView!

    private var bridge: PointerLockBridge!
    private var eventMonitor: Any?

    private var mouseLocked = false

    func applicationDidFinishLaunching(_ notification: Notification) {

        // --------------------------------------------------------
        // WebKit configuration
        // --------------------------------------------------------

        let configuration = WKWebViewConfiguration()

        configuration.preferences.isElementFullscreenEnabled = true

        let controller = WKUserContentController()

        bridge = PointerLockBridge()
        bridge.app = self

        controller.add(bridge, name: "pointerLock")

        // Install BEFORE Eaglercraft's JavaScript executes.
        let script = WKUserScript(
            source: pointerLockJS,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        controller.addUserScript(script)

        configuration.userContentController = controller

        // --------------------------------------------------------
        // WebView
        // --------------------------------------------------------

        webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.autoresizingMask = [
            .width,
            .height
        ]

        // --------------------------------------------------------
        // Window
        // --------------------------------------------------------

        window = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 1280,
                height: 720
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: false
        )

        window.title = "Eaglercraft"
        window.contentView = webView

        window.center()
        window.makeKeyAndOrderFront(nil)

        // --------------------------------------------------------
        // Load Eaglercraft HTML
        // --------------------------------------------------------

        guard let htmlURL = Bundle.main.url(
            forResource: "Eaglercraft",
            withExtension: "html"
        ) else {
            fatalError("Could not find Eaglercraft.html")
        }

        webView.loadFileURL(
            htmlURL,
            allowingReadAccessTo: htmlURL.deletingLastPathComponent()
        )

        // --------------------------------------------------------
        // Keyboard / mouse monitor
        // --------------------------------------------------------

        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [
                .keyDown,
                .mouseMoved,
                .leftMouseDragged,
                .rightMouseDragged,
                .otherMouseDragged
            ]
        ) { [weak self] event in

            guard let self = self else {
                return event
            }

            // ----------------------------------------------------
            // F8 = toggle native mouse lock
            // ----------------------------------------------------

            if event.type == .keyDown && event.keyCode == 100 {
                self.toggleMouseLock()
                return nil
            }

            // ----------------------------------------------------
            // Esc = release native mouse lock
            // ----------------------------------------------------

            if event.type == .keyDown &&
               event.keyCode == 53 &&
               self.mouseLocked {

                self.webView.evaluateJavaScript(
                    "document.exitPointerLock();",
                    completionHandler: nil
                )

                return nil
            }

            // ----------------------------------------------------
            // While locked, convert native mouse movement into
            // Eaglercraft-compatible movementX/Y.
            // ----------------------------------------------------

            if self.mouseLocked {

                switch event.type {

                case .mouseMoved,
                     .leftMouseDragged,
                     .rightMouseDragged,
                     .otherMouseDragged:

                    let dx = event.deltaX
                    let dy = event.deltaY

                    if dx != 0 || dy != 0 {
                        self.sendMouseDelta(dx: dx, dy: dy)
                    }

                    return nil

                default:
                    break
                }
            }

            // IMPORTANT:
            // Everything else goes through normally.
            //
            // Backtick, WASD, mouse clicks, menus, etc. are NOT
            // intercepted here.
            return event
        }
    }

    // ------------------------------------------------------------
    // F8 toggle
    // ------------------------------------------------------------

    private func toggleMouseLock() {
        webView.evaluateJavaScript(
            "window.__nativeTogglePointerLock();",
            completionHandler: nil
        )
    }

    // ------------------------------------------------------------
    // Enable native mouse capture
    // ------------------------------------------------------------

    func enableMouseLock() {

        if mouseLocked {
            return
        }

        mouseLocked = true

        // Disconnect the hardware cursor from the mouse.
        CGAssociateMouseAndMouseCursorPosition(0)

        NSCursor.hide()

        // Tell JavaScript that native capture succeeded.
        webView.evaluateJavaScript(
            "window.__nativePointerLockDidLock();",
            completionHandler: nil
        )
    }

    // ------------------------------------------------------------
    // Disable native mouse capture
    // ------------------------------------------------------------

    func disableMouseLock() {

        if !mouseLocked {
            return
        }

        mouseLocked = false

        NSCursor.unhide()

        CGAssociateMouseAndMouseCursorPosition(1)

        // Tell JavaScript to clear pointerLockElement.
        webView.evaluateJavaScript(
            "window.__nativePointerLockDidUnlock();",
            completionHandler: nil
        )
    }

    // ------------------------------------------------------------
    // Send relative mouse movement to Eaglercraft.
    // ------------------------------------------------------------

    private func sendMouseDelta(dx: CGFloat, dy: CGFloat) {

        // Escape the numbers into JavaScript safely.
        let x = String(format: "%.4f", Double(dx))
        let y = String(format: "%.4f", Double(dy))

        let js = """
        window.__nativeMouseMove(\(x), \(y));
        """

        webView.evaluateJavaScript(
            js,
            completionHandler: nil
        )
    }

    // ------------------------------------------------------------
    // Cleanup
    // ------------------------------------------------------------

    func applicationWillTerminate(_ notification: Notification) {

        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }

        disableMouseLock()
    }
}
let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
