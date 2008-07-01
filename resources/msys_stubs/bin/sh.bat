@ECHO OFF
SETLOCAL
SET DEVKIT=%~dp0..\devkit
SET PATH=%DEVKIT%\mingw\bin;%DEVKIT%\msys\bin
bash.exe  --login -i -c "sh %*"
