#######prompt modification

#oh-my-posh preferred json
# json has been modified, path is absolute, not relative
oh-my-posh init pwsh --config 'C:\Users\ommar\AppData\Local\Programs\oh-my-posh\themes\kali.omp.json' | Invoke-Expression


#######list of aliases I like using

#clear cli screen
Set-Alias -Name cls -Value Clear-Host


#######useful functions

#list all current versions for languages and programs installed
# if there is a program to add, add it to $progs
function versions{
	$progs =	"C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\bin\javac.exe",
				"C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\bin\java.exe",
				"C:\Users\ommar\AppData\Local\Programs\Python\Python311\python.exe",
				"C:\Program Files\Git\cmd\git.exe",
				"C:\msys64\mingw64\bin\gcc.exe",
				"C:\msys64\mingw64\bin\g++.exe",
				"C:\msys64\mingw64\bin\gdb.exe"
	foreach ($prog_name in $progs){
		& $prog_name --version
		echo ""
	}

}

<#
function mwdgr([string]$repo){
	Invoke-Expression("git init")
	Invoke-Expression("git remote add origin " + $repo)

	$files = Get-ChildItem
	foreach ($file_name in $files){
		Invoke-Expression("git add " + $file_name)
	}

	Invoke-Expression("git commit -am \"initial commit\"")
	Invoke-Expression("git push -u -f origin main")
}
#>