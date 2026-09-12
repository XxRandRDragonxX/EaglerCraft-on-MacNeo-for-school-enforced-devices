# EaglerCraft-on-MacNeo-for-school-enforced-devices
Self explanatory name. WILL NOT WORK IF YOU HAVE TERMINAL BLOCKED. You need terminal to do this. For QoL, use Visual Code Studio (can be downloaded with Self Service) to have a better experience.

CURRENT AND KNOWN BUGS

EaglerCraft issues will not be documented, only issues with this specific way of running it. I should also mention that this should, by absolutely NO MEANS work.

Only 2 so far, lmk if you find any at 2218854@edtools.psd401.net

1. NO SAVES
   Yes, the game will save your skin and username, but for some reason not your worlds. Keep this in mind.
2. MOUSE IN NON-FULLSCREEN
   If you play the game not in full screen, and your mouse is offscreen when you start, it might click things on your desktop. Try to minimize this by always clicking the green button to enter fullscreen.
   

FIRST OFF!
This is made with AI. If you do not support AI, you are welcome to not use it. You also require terminal.

Step 1: Installing EaglerCraft.
You will need an installation of EaglerCraft in HTML format. If you do not have this, get an external device and upload it to your school email's Google Drive. For this, I will be using u37, though any version should work fine, but is not guaranteed to. You also may have to download it through a folder, however this wasn't necessary for me and probably won't be for you either.

Step 2: Setting up a safe place to set up EaglerCraft
Click your home button to go to the psdportal (You can use any downloadable website, however this is simply what I did.)
Then, download the website.  (THE BUTTON WILL BE DOWNLOAD FOR YOU)

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/e5956427-9b27-45ea-ba2f-e121e2a20166" />

Then, from there, go to your search and search "Applications" and open the one with your Student ID attached to it.

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/0bb6b19c-d07b-4222-ab72-e32225a2f9bf" />

From here, open the folder and go to Chrome Apps. You will see the PSD Portal.app. Right click it, and enter Package Contents.

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/f7ae12a6-7c30-4305-9404-47a6f5d2f7b7" />

From here, delete everything except for the "Contents" folder, and the subfolders "Resources" and "MacOS"
Delete everything in those folders aswell.
Also, put your version of eaglercraft.html into the folder "Resources. By the time you're done, it should look something like this.

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/0703af7f-fb62-4e1a-a91e-b40465f245bf" />

EDIT, VERY IMPORTANT! RENAME YOUR EAGLERCRAFT FILE TO SIMPLY Eaglercraft.html

Step 3: Entering in Terminal
NOTE! I am not that experienced in Unix, and therefore this might get sloppy. Some commands here (the worse ones) are from me and some (such as compiling) are from ChatGpt. Use with caution.

When you open terminal, type
```bash
cd Applications/
```

``` bash
cd Chrome\ Apps.localized/
```

``` bash
cd PSD\ Portal.app
```

Once here, you have to do the following. 
First, enter the command 
``` bash
touch main.swift
```
It should look like this

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/e5e8e753-f0f2-4c7b-b2de-c391fd82a86e" />

Open the file in Finder using VSC (Or any text editor)

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/cf60957d-077f-4262-a16c-892dcaee68fd" />

``` swift
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
```
REMEMBER TO DO command+s TO SAVE! IF YOU DO NOT SAVE, NOTHING ELSE WILL WORK
After you have this, then paste the commands in terminal

``` bash
clear
```

``` bash
swiftc main.swift \
    -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk \
    -o Eaglercraft \
    -framework Cocoa \
    -framework WebKit
```

``` bash
cp Eaglercraft Contents/MacOS/Eaglercraft
```

``` bash
chmod +x Contents/MacOS/Eaglercraft
```

``` bash
nano Contents/Info.plist
```
Then paste into that 
``` XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Eaglercraft</string>

    <key>CFBundleIdentifier</key>
    <string>com.eaglercraft.native</string>

    <key>CFBundleName</key>
    <string>Eaglercraft</string>

    <key>CFBundleDisplayName</key>
    <string>Eaglercraft</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleVersion</key>
    <string>1.0</string>

    <key>CFBundleShortVersionString</key>
    <string>1.0</string>

    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
```
Then enter control+0, hit return(enter), then control+x

Now, it should look something like this.

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/df9ee27c-245d-4d8a-b59e-591b2060a678" />

At this point, you can rename PSD Portal.app to EaglerCraft.app and maybe even pin it to your taskbar. Assuming both I (me writing this) and YOU have done everything correctly, simply launching EaglerCraft.app will run EaglerCraft.
