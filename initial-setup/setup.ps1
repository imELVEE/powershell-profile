function setup {
    # Define software to install via winget
    $software = @(
        @{ Name = "Firefox"; ID = "Mozilla.Firefox"; Scope = "user" },
        @{ Name = "Chrome"; ID = "Google.Chrome"; Scope = "user" },
        @{ Name = "Git"; ID = "Git.Git"; Scope = "machine" },
        @{ Name = "CMake"; ID = "Kitware.CMake"; Scope = "machine" },
        @{ Name = "MSYS2 (MinGW)"; ID = "MSYS2.MSYS2"; Scope = "machine" },
        @{ Name = "Visual Studio"; ID = "Microsoft.VisualStudio.2022.Community"; Scope = "machine" },
        @{ Name = "Node.js"; ID = "OpenJS.NodeJS.LTS"; Scope = "machine" },
        @{ Name = "Visual Studio Code"; ID = "Microsoft.VisualStudioCode"; Scope = "user" },
        @{ Name = "7-Zip"; ID = "7zip.7zip"; Scope = "machine" },
        @{ Name = "Eclipse Adoptium Temurin JDK 21"; ID = "EclipseAdoptium.Temurin.21.JDK"; Scope = "machine" },
        @{ Name = "OhMyPosh"; ID = "JanDeDobbeleer.OhMyPosh"; Scope = "user" },
        @{ Name = "Android Studio"; ID = "Google.AndroidStudio"; Scope = "machine" },
        @{ Name = "Python"; ID = "Python.Python.3.11"; Scope = "machine" }
    )

    # Install software using winget
    foreach ($package in $software) {
    Write-Host "Installing $($package.Name)..."
    try {
        if ($package.Scope -eq "machine") {
            winget install --id $($package.ID) --scope machine --silent --accept-package-agreements --accept-source-agreements 2>&1 | Tee-Object -Variable output
        } else {
            winget install --id $($package.ID) --scope user --silent --accept-package-agreements --accept-source-agreements 2>&1 | Tee-Object -Variable output
        }
    } catch {
        Write-Error "Failed to install $($package.Name): $_"
    }
}


    # MSYS2-specific setup for MinGW and GCC
    $msys2Shell = "C:\msys64\usr\bin\bash.exe"
    if (Test-Path $msys2Shell) {
        Write-Host "Configuring MSYS2 and installing GCC with pacman..."

        # Update pacman package database
        & $msys2Shell -lc "pacman -Syu --noconfirm"

        # Install GCC (MinGW)
        & $msys2Shell -lc "pacman -S --noconfirm mingw-w64-ucrt-x86_64-gcc"

        # Add MinGW to system PATH
        $mingwPath = "C:\msys64\mingw64\bin"
        if (-not ($env:Path -split ";" | Where-Object { $_ -eq $mingwPath })) {
            [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$mingwPath", [System.EnvironmentVariableTarget]::Machine)
            Write-Host "Added MinGW to PATH. Please restart your terminal for changes to take effect."
        }
    } else {
        Write-Host "MSYS2 shell not found. Please ensure MSYS2 was installed correctly."
    }

    Write-Host "Setup complete!"
}

# Function to validate installations
function Validate-Installations {
    param ([Array]$software)

    $notInstalled = @()

    foreach ($package in $software) {
        $installed = winget list --id $($package.ID) | Out-String
        if ($installed -notmatch $package.ID) {
            Write-Error "$($package.Name) was not installed."
            $notInstalled += $package.Name
        } else {
            Write-Host "$($package.Name) is installed."
        }
    }

    if ($notInstalled.Count -gt 0) {
        Write-Host "The following packages were not installed:" -ForegroundColor Red
        $notInstalled | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    } else {
        Write-Host "All packages are successfully installed!" -ForegroundColor Green
    }
}
