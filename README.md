# TagIt 3
Tagit is software designed to help tagging image projects for booru upload (specifically e621). It does so by providing the user with suggestions related to the tags being added to create a more comprehensive list to help discoverability and prevent those who would rather blacklist a tag from reaching it.

Version 3 is the final major version of TagIt (and last rewrite). It comes bundled with a few useful tools to make tagging easier.
## Installation
### Quick (Reccomended)
Simply download the launcher script that is appropiate for your system and run it. It'll download and rename the required files where you've placed the script. Each time you run the script it'll check if there is an update required and automatically download it for you.
> [!NOTE]
> Running the executable instead of the launcher will also check for updates and let you decide if you want to update or not, but unlike the launcher it can't keep the executable or the plugins updated and can only patch for bugs.
### Manual
The launcher gets the files from the next repo: [TagIt Launcher](https://github.com/Ketei/tagit-launcher/releases/latest).

If you're on **Windows**, download: 
- tagit.pck
- tagit.windows.x86_64.exe
- godotgif.windows.template_release.x86_64.dll
- libgdsqlite.windows.template_release.x86_64.dll.

Rename `tagit.windows.x86_64.exe` to `tagit.exe`.

If you're on **Linux**, download:
- tagit.pck
- tagit.linux.x86_64
- libgodotgif.linux.template_release.x86_64.so
- libgdsqlite.linux.template_release.x86_64.so.

Rename `tagit.linux.x86_64` to `tagit.x86_64`.

Lastly create an empty text file named `version` WITHOUT the extension and write the version of the files you've downloaded. Now you can launch the tagger through the executable.
> If you downloaded 3.0.0 then write on the file `3.0.0` and nothing else.

Now just launch `tagit.exe` if on Windows or `tagit.x86_64` if on Linux.

> [!CAUTION]
> Not using the intended names could render the software unusable.

## Main differences with v2
This version of TagIt:
- Uses an actual database, instead of a bunch of loose files. Making loading times a LOT shorter.
- Has an updater that can update your application to the latest version
- Has a simpler user interface.
- Allows you to include images with your tagging projects.
- Allows for more customization
- You can create as many alt lists for a project as you need.
- You can finally add your own formatting through the application.
- And a few more...
