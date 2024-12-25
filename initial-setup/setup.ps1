function setup {
    # Define software to install via winget
    $software = @(
        @{ Name = "Firefox"; ID = "Mozilla.Firefox"; Scope = "user"; ValidationPath = @(
                "$env:LOCALAPPDATA\Microsoft\WindowsApps\firefox.exe",
                "$env:LOCALAPPDATA\Programs\Mozilla Firefox\firefox.exe"
            ); AddToPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps" },
        @{ Name = "Chrome"; ID = "Google.Chrome.EXE"; Scope = "user"; ValidationPath = "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe" },
        @{ Name = "Git"; ID = "Git.Git"; Scope = "machine"; ValidationCommand = "git"; AddToPath = "C:\Program Files\Git\cmd" },
        @{ Name = "CMake"; ID = "Kitware.CMake"; Scope = "machine"; ValidationCommand = "cmake"; AddToPath = "C:\Program Files\CMake\bin" },
        @{ Name = "MSYS2 (MinGW)"; ID = "MSYS2.MSYS2"; ValidationPath = "C:\msys64\usr\bin\bash.exe"; AddToPath = "C:\msys64\mingw64\bin" },
        @{ Name = "Visual Studio"; ID = "Microsoft.VisualStudio.2022.Community"; Scope = "machine"; ValidationPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" },
        @{ Name = "Node.js"; ID = "OpenJS.NodeJS.LTS"; Scope = "machine"; ValidationCommand = "node"; AddToPath = "C:\Program Files\nodejs" },
        @{ Name = "Visual Studio Code"; ID = "Microsoft.VisualStudioCode"; Scope = "user"; ValidationPath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"; AddToPath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code" },
        @{ Name = "7-Zip"; ID = "7zip.7zip"; Scope = "machine"; ValidationPath = "C:\Program Files\7-Zip\7z.exe"; AddToPath = "C:\Program Files\7-Zip" },
        @{ Name = "Eclipse Adoptium Temurin JDK 21"; ID = "EclipseAdoptium.Temurin.21.JDK"; Scope = "machine"; ValidationCommand = "java"; AddToPath = "C:\Program Files\Eclipse Adoptium\jdk-21\bin" },
        @{ Name = "OhMyPosh"; ID = "JanDeDobbeleer.OhMyPosh"; Scope = "user"; ValidationCommand = "oh-my-posh"; AddToPath = "$env:LOCALAPPDATA\Programs\oh-my-posh" },
        @{ Name = "Android Studio"; ID = "Google.AndroidStudio"; Scope = "machine"; ValidationPath = "C:\Program Files\Android\Android Studio\bin\studio64.exe" },
        @{ Name = "Python"; ID = "Python.Python.3.11"; Scope = "machine"; ValidationCommand = "python"; AddToPath = "C:\Python311" }
    )

    # Install software using winget
    foreach ($package in $software) {
        Write-Host "Installing $($package.Name)..."
        try {
            if ($package.PSObject.Properties["Scope"] -and $package.Scope -eq "machine") {
                winget install --id $($package.ID) --scope machine --accept-package-agreements --accept-source-agreements --verbose-logs
            } elseif ($package.PSObject.Properties["Scope"] -and $package.Scope -eq "user") {
                winget install --id $($package.ID) --scope user --accept-package-agreements --accept-source-agreements --verbose-logs
            } else {
                winget install --id $($package.ID) --accept-package-agreements --accept-source-agreements --verbose-logs
            }
        } catch {
            Write-Error "Failed to install $($package.Name): $_"
        }

        # Add to PATH if specified
        if ($package.AddToPath) {
            Add-ToPath -Directory $package.AddToPath -Scope ($package.Scope -or "Process")
        }
    }

    # MSYS2-specific setup for toolchain
    $msys2Shell = "C:\msys64\usr\bin\bash.exe"
    if (Test-Path $msys2Shell) {
        Write-Host "Configuring MSYS2 and installing the development toolchain with pacman..."

        try {
            # Update pacman package database
            Write-Host "Updating MSYS2 packages..."
            & $msys2Shell -lc "pacman -Syu --noconfirm"

            # Install development toolchain (base-devel, GCC, G++, GNU Make, GDB)
            Write-Host "Installing development toolchain..."
            & $msys2Shell -lc "pacman -S --needed --noconfirm base-devel mingw-w64-ucrt-x86_64-toolchain"

            # Add MinGW to system PATH
            $mingwPath = "C:\msys64\mingw64\bin"
            if (-not ($env:Path -split ";" | Where-Object { $_ -eq $mingwPath })) {
                [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$mingwPath", [System.EnvironmentVariableTarget]::Machine)
                Write-Host "Added MinGW to PATH. Please restart your terminal for changes to take effect."
            }
        } catch {
            Write-Error "Failed to configure MSYS2 or install the development toolchain: $_"
        }
    } else {
        Write-Host "MSYS2 shell not found. Please ensure MSYS2 was installed correctly."
    }

    # Validate installations
    Write-Host "Validating installed packages and toolchain..."
    Validate-Installations $software

    # Validate GCC, G++, GNU Make, and GDB
    Validate-Toolchain

    Write-Host "Setup complete!"
}

# Function to validate installations
function Validate-Installations {
    param ([Array]$software)

    $notInstalled = @()

    foreach ($package in $software) {
        Write-Host "Validating $($package.Name)..."

        # Check if the package appears in winget list
        $installed = winget list --id $($package.ID) | Out-String
        if ($installed -notmatch $package.ID) {
            Write-Error "$($package.Name) is not installed (not found in winget list)."
            $notInstalled += $package
            continue
        }

        # Check for validation path (multiple possible paths)
        if ($package.ValidationPath) {
            $found = $false
            foreach ($path in $package.ValidationPath) {
                if (Test-Path $path) {
                    Write-Host "$($package.Name) is installed at: $path"
                    $found = $true
                    break
                }
            }
            if (-not $found) {
                Write-Error "$($package.Name) is not fully installed. None of the validation paths were found."
                $notInstalled += $package
                continue
            }
        }

        # Check for validation command (CLI availability)
        if ($package.ValidationCommand) {
            if (-not (Get-Command $package.ValidationCommand -ErrorAction SilentlyContinue)) {
                Write-Error "$($package.Name) is not fully installed. Command $($package.ValidationCommand) not found in PATH."
                $notInstalled += $package
                continue
            }
        }

        Write-Host "$($package.Name) is fully installed."
    }

    if ($notInstalled.Count -gt 0) {
        Write-Host "The following packages are not fully installed:" -ForegroundColor Red
        $notInstalled | ForEach-Object { Write-Host $_.Name -ForegroundColor Yellow }
    } else {
        Write-Host "All packages are fully installed!" -ForegroundColor Green
    }
}

# Function to validate GCC, G++, GNU Make, and GDB
function Validate-Toolchain {
    $tools = @("gcc", "g++", "make", "gdb")
    foreach ($tool in $tools) {
        Write-Host "Validating $tool..."
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Error "$tool is not installed or not available in PATH."
        } else {
            Write-Host "$tool is available in PATH."
        }
    }
}

# Function to add directories to PATH
function Add-ToPath {
    param (
        [string]$Directory,
        [string]$Scope = "Machine" # Options: "Process", "User", "Machine"
    )

    # Check if the directory already exists in PATH
    $currentPath = if ($Scope -eq "Machine") {
        [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    } elseif ($Scope -eq "User") {
        [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    } else {
        $env:PATH
    }

    if ($currentPath -split ";" | Where-Object { $_ -eq $Directory }) {
        Write-Host "Directory already exists in PATH: $Directory"
        return
    }

    # Add the directory to PATH
    if ($Scope -eq "Machine") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$Directory", [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Added to System PATH: $Directory"
    } elseif ($Scope -eq "User") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$Directory", [System.EnvironmentVariableTarget]::User)
        Write-Host "Added to User PATH: $Directory"
    } else {
        $env:PATH = "$currentPath;$Directory"
        Write-Host "Added to Current Session PATH: $Directory"
    }

    # Refresh the current session PATH
    Refresh-Path
}

# Function to refresh PATH in the current session
function Refresh-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    Write-Host "Refreshed the current session's PATH."
}

