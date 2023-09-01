#######prompt modification

#oh-my-posh preferred json
# json has been modified, path is absolute, not relative
oh-my-posh init pwsh --config 'C:\Users\ommar\AppData\Local\Programs\oh-my-posh\themes\kali.omp.json' | Invoke-Expression


#######list of aliases I like using

#clear cli screen
Set-Alias -Name cls -Value Clear-Host


#######useful functions

<# list all current versions for languages and programs installed
	#if there is a program to add, add it to $progs
## @pre these programs exist in their current locations
#>
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

<# turn current working directory into remote git repo and sync/link with online version
	#if git init is defaulting to 'master' in your local repository, run <git config --global init.defaultBranch main> in your cli
		#this changes the default name git assigns to your local branch from master to main
## @pre1 an existing repo on github.com to push to
## @post local repo is created and linked to an existing online repo
## @param $repo is the SSH clone link of online repo
#>
function mwdgr([string]$repo){
	$git_prog = "C:\Program Files\Git\cmd\git.exe"
	& $git_prog init
	& $git_prog remote add origin $repo
	& $git_prog add -A
	& $git_prog commit -am "inital commits"
	& $git_prog pull --rebase origin main
	& $git_prog push -u -f origin main
}
