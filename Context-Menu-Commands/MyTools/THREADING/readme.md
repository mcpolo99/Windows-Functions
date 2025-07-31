
# Bsolid Macro Compiler

## info

This script compiles a bSolid macro folder into a winrar self-extracting archive.
Using default winrar path, if winrar is not found try find with registry.
This script will later be compiled with PS2EXE for less future issues with running scripts.

## Different types of executing of the script

- (not nessesary to do now!!)right click a folder which i want to compile and with that right click i am passing the folder path to this script. (this is for use with a registry context key.)
- command line with a folder path as an argument.
- (this is the one to focus on now!)Run the script in the same directory and look for folders with this type of structure

## Validate Folder Structure

bsolidMacroFolderStructure(interface?):
{foldername}:
├─TextFiles
│   └─ any type of lang code like : "en" for english or "sv" for svenska
│
├─ _Large.png
├─ {a file with same name as folder}.bSolid
├─ {a file with same name as folder}.det
├─ {a file with same name as folder}.png
└─ {a file with same name as folder}_Descr.png

there will be exceptions like when the folder is called for instace "THREADING_JON_REV1.1" and the "files" is called "THREADING_JON.*" only. In these cases we
copy the folder "THREADING_JON_REV1.1" to "THREADING_JON" and remember "REV1.1" for compiling the "THREADING_JON" folder. When Compiling is finished remove the copied folder.

There also will be cases when we have multiple folders with same {foldername}s but with different REV numbers. In these cases we need to ONLY use the "biggest"
REV folder. so for example "THREADING_JON_REV1.5" wins over "THREADING_JON_REV1.1" and "THREADING_JON_REV2.1" wins over both previous. in the cases when a folder WITHOUT
a REV. this folder wins before any other. in these cases i want a popup to ask for a rev number.
IMPORTANT TO NOTE is that all folders will have same "base name".
so for instace if parent folder name is called "THREADING_JON" the child folders that we want to handle will also be called "THREADING_JON"+"revnumbers etc"

Then to the sfx archive properties. we create a sfx.txt at runtime. if it exsist already we overwrite it with a new one.
this file is to be used with the command for compiling the SFX archive.
Important for the title (inside of sfx.txt) is that we split up the {foldername} like "THREADING_JON REV 1.1"

``` markdown

;The comment below contains SFX script commands
Path=C:\Biesse\bSuite\Macro 
Text=  This will extract Macro "{foldername}" to: C:\Biesse\bSuite\Macro\
Title={foldername}
Overwrite=1
Silent=0
Presetup=<hide>PowerShell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('CLOSE BSOLID!!!!')"
Setup=<hide>PowerShell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('RESTART BSOLID!!!!')"
License= License and Agreement

```

When compiling the folder similar command will be run for compiling:
"{path to winrar}" a -sfx -r -z".\sfx.txt" {foldername}.exe .\{foldername}

the parent folder and the childfolder should be case insensetive.

## error handling

### Logging

use of Start-Transcript/Stop-Transcript + custom logging.

Custom logging Function:

```powershell

# and like Log.error, Log.debug and Log.info to this my default logging stratergy
function Log {
  param([string]$message)
    if ($script:verbose) {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $message"
    }
}

```

$executionPath: current dir (OR the dir provided).
$logStamp = Get-Date -Format 'yyyy-MM-dd'
$logFile: $logFile = "{$executionPath}\\{scriptname/executorsname}_$logStamp.log"

### Errors i know we need to handle from start

|error to be handled| handle like|
| --- | --- |
| If winrar cannont be found (not static path OR registry) | Prompt the user to install winrar |
| If no "child" folder with the "same name+rev" or with "same name" as "parent" folder can be found | Prompt the user that no sfx archive could be done because missing folders |
| exe file with same name as we want to compile to already exsists  | prompt user to overwrite or cancel |
| --- | --- |
