# Video Randomizer for picking a video from the videos folder pseudo-randomly
# 
# Because this is pseudo-random, it can be predicted although it is difficult.
#
$current_dir = Split-Path $script:MyInvocation.MyCommand.Path
$video_dir = "$current_dir\videos"

echo "`nNow scrambling videos..."

# Grab the crypto RNG entropy pool widget
[System.Security.Cryptography.RNGCryptoServiceProvider] $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider

# Part 1: count number of files
$filenumber = 0
foreach($file in Get-ChildItem $video_dir){
	$fileextension = [IO.Path]::GetExtension($file)
    if ($fileextension -ne ".ps1" -and $fileextension -ne ".bat"){		
		$filenumber++
		Rename-Item ("$video_dir\$file") ("temp"+$filenumber+$fileextension)
	}
}

# Part 2: Make random numbers. If there is a collision (2 numbers equal), then re-do it.
# Make array to contain the random numbers for video names
$rndnum = New-Object byte[] $filenumber
# Generate random sequence of bytes 
$collisionflag = 1

while ($collisionflag -ne 0){
	$collisionflag = 0
	echo "Getting Random Numbers"
	$rng.GetBytes($rndnum)
	
	foreach($a in $rndnum){
		$occurrences = ($rndnum -eq $a).Count
		if($occurrences -gt 1){
			$collisionflag = 1 # if collision, get new randoms
			echo "COLLISION! (too many videos??)"
			$occurrences--
		}
	}
}

echo "Files in roulette folder: $filenumber"

# Part 3: Rename files to video### to obscure name
$i = 0
foreach($file in Get-ChildItem $video_dir){
   $fileextension = [IO.Path]::GetExtension($file)
    if ($fileextension -ne ".ps1" -and $fileextension -ne ".bat"){		
		Rename-Item ("$video_dir\$file") ("video"+$rndnum[$i]+$fileextension)
		$i++
	}
}

# Part 4: Pick a video and put it into the directory
$choice = New-Object byte[] 1
$rng.GetBytes($choice)
$choice = $choice[0] % $filenumber
#echo "choice is $choice"
foreach($file in Get-ChildItem $video_dir){
    $fileextension = [IO.Path]::GetExtension($file)
    if ($fileextension -ne ".ps1" -and $fileextension -ne ".bat"){		
		if($choice -eq 0){
			echo "`nYour next video to watch is: $file"
			Move-Item -Path ("$video_dir\$file") -Destination ($current_dir)
			$choice--
		}
		else{
			$choice--
		}
	}
}