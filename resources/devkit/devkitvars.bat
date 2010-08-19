:: convenience script residing in the DevKit root dir used for
:: manually configuring a Command Prompt environment to use the
:: DevKit for compiling native Ruby extensions
@ECHO OFF
ECHO Adding the DevKit to PATH...
SET DEVKIT=%~dp0
SET PATH=%DEVKIT%bin;%DEVKIT%mingw\bin;%PATH%
