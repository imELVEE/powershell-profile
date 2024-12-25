function setup {
    # Define software to install via winget
    $software = @(
        @{ Name = "Firefox"; ID = "Mozilla.Firefox"; Scope = "user"; ValidationPath = "C:\Program Files\Mozilla Firefox\firefox.exe" },
        @{ Name = "Chrome"; ID = "Google.Chrome"; Scope = "user"; ValidationPath = "C:\Program Files\Google\Chrome\Application\chrome.exe" },
        @{ Name = "Git"; ID = "Git.Git"; Scope = "machine"; ValidationCommand = "git" },
        @{ Name = "CMake"; ID = "Kitware.CMake"; Scope = "machine"; ValidationCommand = "cmake" },
        @{ Name = "MSYS2 (MinGW)"; ID = "MSYS2.MSYS2"; Scope = "machine"; ValidationPath = "C:\msys64\usr\bin\bash.exe" },
        @{ Name = "Visual Studio"; ID = "Microsoft.VisualStudio.2022.Community"; Scope = "machine"; ValidationPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" },
        @{ Name = "Node.js"; ID = "OpenJS.NodeJS.LTS"; Scope = "machine"; ValidationCommand = "node" },
        @{ Name = "Visual Studio Code"; ID = "Microsoft.VisualStudioCode"; Scope = "user"; ValidationPath = "C:\Program Files\Microsoft VS Code\Code.exe" },
        @{ Name = "7-Zip"; ID = "7zip.7zip"; Scope = "machine"; ValidationPath = "C:\Program Files\7-Zip\7z.exe" },
        @{ Name = "Eclipse Adoptium Temurin JDK 21"; ID = "EclipseAdoptium.Temurin.21.JDK"; Scope = "machine"; ValidationCommand = "java" },
        @{ Name = "OhMyPosh"; ID = "JanDeDobbeleer.OhMyPosh"; Scope = "user"; ValidationCommand = "oh-my-posh" },
        @{ Name = "Android Studio"; ID = "Google.AndroidStudio"; Scope = "machine"; ValidationPath = "C:\Program Files\Android\Android Studio\bin\studio64.exe" },
        @{ Name = "Python"; ID = "Python.Python.3.11"; Scope = "machine"; ValidationCommand = "python" }
    )

    # Install software using winget
    foreach ($package in $software) {
        Write-Host "Installing $($package.Name)..."
        try {
            if ($package.Scope -eq "machine") {
                winget install --id $($package.ID) --scope machine --accept-package-agreements --accept-source-agreements --verbose-logs
            } else {
                winget install --id $($package.ID) --scope user --accept-package-agreements --accept-source-agreements --verbose-logs
            }
        } catch {
            Write-Error "Failed to install $($package.Name): $_"
        }
    }

    # Validate installations
    Write-Host "Validating installed packages..."
    Validate-Installations $software

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

        # Check for validation path (file/directory)
        if ($package.ValidationPath) {
            if (-not (Test-Path $package.ValidationPath)) {
                Write-Error "$($package.Name) is not fully installed. Path $($package.ValidationPath) not found."
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
