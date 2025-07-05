# MKLinkCreator

**MKLinkCreator** is a Windows utility designed to simplify the creation of symbolic links (symlinks) via a GUI or directly from the context menu. It offers both a user-friendly graphical interface and command-line support for power users, and integrates with the Windows context menu for seamless usage.

## Features

- 📁 Create symbolic links between folders.
- 🧭 Context menu integration: right-click to set source and destination.
- 🖱️ GUI-based interaction with logging support.
- 🔧 Persistent folder selection using an XML config.
- 🧹 One-click clearing of stored folder paths.
- 🧰 Admin-level installer for full system integration.

## Installation

To install the tool and integrate it into the Windows context menu:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
ps2exe '.\MKLinkCreator.ps1' .\MKLinkCreator.exe -noConsole -STA -requireAdmin -exitOnCancel -title 'MK Link Creator' -company 'Polos AB' -product 'MKLinkCreator' -version '1.0.1' -iconFile ".\ico_resaved.ico" -verbose
Then run the generated MKLinkCreator.exe to trigger the self-installation and register the context menu entries.

⚠️ Administrator privileges are required to install and use this tool.

Usage
GUI Mode
Run MKLinkCreator.exe to open the GUI:

Select a source folder.

Select a destination folder.

Click OK to create a symbolic link.

Command-Line Mode
MKLinkCreator.exe -InitialSource "C:\MyFolder" -InitialDestination "D:\Target"
Additional command-line options:

Option	Description
-help	Displays the help window.
-verbose	Enables verbose logging to Script_DATE.log and manlog_DATE.log.
-setSource <path>	Sets the source folder in the internal XML config.
-setDestination <path>	Sets the destination folder in the config.
-createLink	Creates the symbolic link using the stored source & destination.
-clearTempSetup	Clears saved source and destination paths.

Context Menu Integration
Once installed, right-click on any folder or folder background to access:

Set MKLink Source – Saves the folder as the source.

Set MKLink Destination – Saves the folder as the destination and creates the link.

Clear MKLink Setup – Clears stored paths.

These commands appear under a top-level context menu entry called My Tools.

Logs
If -verbose is used, logs are saved to:

Script_YYYY-MM-DD.log

manlog_YYYY-MM-DD.log

These contain detailed records of operations and errors for debugging purposes.

Uninstallation
Uninstallation is not yet implemented as a dedicated function, but you can manually:

Delete the folder: C:\ProgramData\PolosAutomation\MyTools\MKLink

Remove registry keys under:

HKEY_CLASSES_ROOT\Directory\shell\MyTools

HKEY_CLASSES_ROOT\Directory\Background\shell\MyTools

HKEY_CLASSES_ROOT\PolosAutomation.MyToolsCommands

Requirements
Windows 10/11

PowerShell 5.1+

Admin privileges for installation

ps2exe to compile .ps1 to .exe

License
MIT License

© 2025 Polos AB. All rights reserved.
---
