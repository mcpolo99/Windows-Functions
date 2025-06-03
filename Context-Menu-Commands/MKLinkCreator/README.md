# MK Link Creator

A simple utility to create symbolic links on Windows using a graphical interface or command-line options.

> 🚧 **Coming Soon:** A Windows installer that adds MK Link Creator to the context menu.

---

## 🔧 Usage

### 📦 GUI Mode

1. Launch `MKLinkCreator.exe`.
2. Select a **source folder**.
3. Select a **destination folder**.
4. Click **OK** to create a symbolic link at:

Destination\SourceFolderName_Link

> **Note:**  
> - Existing links with the same name will be **overwritten**.  
> - Admin privileges are **required**.

---

### 💻 Command-Line Mode

#### Show Help:
```powershell
MKLinkCreator.exe -help
Create a Link:
powershell
MKLinkCreator.exe -InitialSource "C:\Source" -InitialDestination "D:\Target"

With Logging:
powershell
MKLinkCreator.exe -InitialSource "C:\Source" -InitialDestination "D:\Target" -verbose
🧩 Command-Line Switches
Switch	Description
-help	Show the help window
-InitialSource	Path to the source directory
-InitialDestination	Path to the target directory
-verbose	Enable logging to Script_DATE.log and manlog_DATE.log in the working dir

🛠 Requirements
Windows 10/11

Admin privileges (UAC prompt will appear)

📌 Notes
The tool overwrites any existing symbolic links with the same name.

Logging provides details on actions and errors for troubleshooting when using the -verbose switch.

📥 Coming Soon
🖱️ Context menu integration via installer script

🧪 More advanced link management options

Feel free to open issues or submit pull requests for improvements!

---
