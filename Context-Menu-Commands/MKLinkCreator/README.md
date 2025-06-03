will add installer to add to context menu. 

For the moment being use :

MK Link Creator Help

Usage (command line):
  MKLinkCreator.exe -help
    Show this help window.

  MKLinkCreator.exe -InitialSource "C:\Source" -InitialDestination "D:\Target"
    Create a symbolic link directly (no GUI).

  MKLinkCreator.exe -InitialSource "C:\Source" -InitialDestination "D:\Target" -verbose
    Same as above, but with logging to file.

Switches:
  -help       Show help window.
  -verbose    Enable logging of actions and errors to Script_DATE.log and manlog_DATE.log.

Usage (GUI):
  1. Select a source folder.
  2. Select a destination folder.
  3. Click OK to create a symbolic link at:
     Destination\SourceFolderName_Link

Notes:
  - This tool requires admin privileges.
  - Existing links with the same name will be overwritten.
