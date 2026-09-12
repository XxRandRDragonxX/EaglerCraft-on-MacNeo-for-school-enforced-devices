# EaglerCraft-on-MacNeo-for-school-enforced-devices
Self explanatory name. WILL NOT WORK IF YOU HAVE TERMINAL BLOCKED. You need terminal to do this. For QoL, use Visual Code Studio (can be downloaded with Self Service) to have a better experience.

CURRENT AND KNOWN BUGS

All code was made with AI. If you have a problem with that, don't use it.

EaglerCraft issues will not be documented, only issues with this specific way of running it. I should also mention that this should, by absolutely NO MEANS work.

lmk if you find any at 2218854@edtools.psd401.net

1. NO SAVES
   Yes, the game will save your skin and username, but for some reason not your worlds. Keep this in mind.
2. MOUSE IN NON-FULLSCREEN
   If you play the game not in full screen, and your mouse is offscreen when you start, it might click things on your desktop. Try to minimize this by always clicking the green button to enter fullscreen.
3. When exiting the game, you MUST exit it in Activity Manager, as just closing it will stop you from re-opening it until you exit it in Activity Manager.

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

Step 4: Creating main.swift, info.plist and compiling.

Once here, you have to do the following. 

First, enter the command 
``` bash
touch main.swift
```
It should look like this

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/e5e8e753-f0f2-4c7b-b2de-c391fd82a86e" />

Open the file in Finder using VSC (Or any text editor)

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/cf60957d-077f-4262-a16c-892dcaee68fd" />


Copy and paste [link text](./main.swift) into main.swift.

<img width="2816" height="1762" alt="image" src="https://github.com/user-attachments/assets/c46976ee-fac0-442a-868c-cbeba5aa7c93" />

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

Step 5: Enjoy

At this point, you can rename PSD Portal.app to EaglerCraft.app and maybe even pin it to your taskbar. Assuming both I (me writing this) and YOU have done everything correctly, simply launching EaglerCraft.app will run EaglerCraft.
