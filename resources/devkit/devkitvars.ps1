# convenience script residing in the DevKit root dir used for
# manually configuring a PowerShell environment to use the
# DevKit for compiling native Ruby extensions
echo "Adding DevKit to PATH..."
$devkit = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$env:RI_DEVKIT = "$devkit"
$env:path = "$devkit\bin;$devkit\mingw\bin;$env:path"
