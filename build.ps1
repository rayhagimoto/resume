# Get the full path to this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Set the path to Git Bash (update if installed elsewhere)
$GitBash = "C:\Program Files\Git\bin\bash.exe"

# Full path to the build.sh script
$BuildScript = Join-Path $ScriptDir "build.sh"

# Run build.sh using Git Bash
& "$GitBash" "$BuildScript"
