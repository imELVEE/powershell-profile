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
function versions
{
	$progs = "javac", "java", "python", "git", "gcc" , "g++", "gdb"
	foreach ($progname in $progs){
		Invoke-Expression ($progname + " --version")
		echo ""
	}
}
