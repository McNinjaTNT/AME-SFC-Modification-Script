# AME-SFC-Modification-Script
Warns the user and asks for confirmation before running sfc /scannow.

# How it works:

The automatic deployment script creates a sfc.bat file in the System32 directory, however due to Command Prompt prioritizing .exe extensions over .bat, sfc.exe must be renamed.

Renaming or moving sfc.exe causes it to not output any text. Because of this, I've made sfc.bat attempt to emulate said text.

The deployment script also manages permissions. sfc.bat and sfc1.exe both have their ACLs set to owner:TrustedInstaller and with the default System32 Permissions.

# Notes:
This script could be made much simpler by changing the PATHEXT environment variable to prioritize .bat over .exe, allowing for a unmodified/renamed sfc.exe, which would make sfc.exe output text correctly. However, this would be a permanent change to the system, and ontop of that, if a user were to run sfc.exe /scannow, it would bypass the script.

If sfc /scannow is run, it will warn the user, and ask for a text input of "I know what I'm doing" for confirmation, or "Cancel" to exit. If the user confirms this action, the script will automatically restore sfc1.exe's state to sfc.exe
