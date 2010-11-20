:: convenience script residing in the DevKit root dir used for
:: manually configuring a Command Prompt environment to use the
:: DevKit for compiling native Ruby extensions
@ECHO OFF
ECHO Adding the DevKit to PATH...
SET RI_DEVKIT=%~dp0
SET PATH=%RI_DEVKIT%bin;%RI_DEVKIT%mingw\bin;%PATH%
