#######prompt modification

#oh-my-posh preferred json
# json has been modified, path is absolute, not relative
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/imELVEE/powershell-profile/refs/heads/main/kali.omp.json' | Invoke-Expression


#######list of aliases I like using


## Useful functions

	<# list all current versions for languages and programs installed
		#if there is a program to add, add it to $progs
	## @pre		: these programs exist in their current locations
	#>
	function versions
	{
		$progs =	"C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\bin\javac.exe",
					"C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\bin\java.exe",
					"~\AppData\Local\Programs\Python\Python311\python.exe",
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
	## @pre		: an existing repo on github.com to push to
	## @param	: string, the SSH clone link of online repo
	## @param	: string, the commit message for all files
	## @post	: local repo is created and linked to an existing online repo
	#>
	function gitRepo([string]$repo, [string]$commit_message = "initial commits")
	{
		$git_prog = "C:\Program Files\Git\cmd\git.exe"
		& $git_prog init
		& $git_prog remote add origin $repo
		& $git_prog add -A
		& $git_prog commit -am $commit_message
		& $git_prog pull --rebase origin main
		& $git_prog push -u origin main
	}

	<# take coding preamble and create a file with given name,
	##	default: create a new template consisting of the default template in the working directory
	## @pre		: template txt file exists properly formatted with <date> and <file_name> to replace
					no conditionals/safety checks because this is for personal use and I'm feeling particularly lazy today
	## @param	: string, the name of the file to be created with the template
	## @param	: string, path to a "template.txt" file containing *only* the preamble,
					default value is a path to ~\Documents
	## @post	: create a file with given name in the working directory
	#>
	function authoredTemplate([string]$file_name = ".\template.txt", [string]$templateFile = "~\Documents\")
	{
		if ($templateFile -eq "CSCI235")
		{
			$templateFile = "~\Documents\ALL-CS\Hunter-CSCI\CSCI-235\"
		}
		$templateFile += "template.txt"
		[string] $templateText = Get-Content -Path $templateFile -Raw
		[string] $date = Get-Date -Format "MM/dd/yyyy"
		$templateText = $templateText.replace("<date>", $date).replace("<file_name>", $file_name)
		Set-Content -Path $file_name -Value $templateText
	}


## Automatically added code during installations

	# Import the Chocolatey Profile that contains the necessary code to enable
	# tab-completions to function for `choco`.
	# Be aware that if you are missing these lines from your profile, tab completion
	# for `choco` will not function.
	# See https://ch0.co/tab-completion for details.
	$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
	if (Test-Path($ChocolateyProfile)) {
	  Import-Module "$ChocolateyProfile"
	}
