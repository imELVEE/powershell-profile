# Deescription

This file is for initial setup of a new machine, the script contains various softwares that I use often or may use semi-commonly. Some may not be automatically added to PATH, so they need to be checked.

The following command will run the script on your machine.

```
iwr "https://raw.githubusercontent.com/imELVEE/powershell-profile/refs/heads/main/initial-setup/setup.ps1" | iex
```
If the above command is not running anything, try running without `| iex` to test that it can connect to the page containing the script. If all is well, it may be running the script that is being blocked.

The following command will temporarily change the execution policy and may allow the script to run.

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```


# Software Installed by the Script

## User-Scoped Software
These are installed for the current user only:
- **Firefox**: Web browser.
- **Chrome**: Web browser.
- **Visual Studio Code**: Lightweight code editor.
- **OhMyPosh**: Command-line prompt theme.

## System-Scoped Software
These are installed for all users:
- **Git**: Version control system.
- **CMake**: Build system generator.
- **MSYS2 (MinGW)**: Minimalist GNU for Windows, includes GCC/G++.
- **Visual Studio Community 2022**: Integrated development environment.
- **Node.js**: JavaScript runtime (includes `npm`).
- **7-Zip**: File archiver and extractor.
- **Eclipse Adoptium Temurin JDK 21**: Java Development Kit.

  *I thought about installing vanilla OpenJDK. But, I recently learned that Temurin is apparently the de-facto JDK packager. In my defense, I was using Oracle instead of openJDK up until very recently.*
  
- **Android Studio**: Android application development environment.
- **Python 3.11**: Programming language runtime.
