
# Powershell Compiler

To first compile the exe to a working compiler you need to install ps2exe:

``` powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
```

then compile it with:

``` powershell
compile: ps2exe '.\compile.ps1' .\Compile_new.exe -noConsole -STA -exitOnCancel -title 'compile'  -company 'Polos AB'  -product 'compiler' -version '1.0.1.0' -verbose
```

When you have a exe file you the installation of ps2exe will be requested if missing.
