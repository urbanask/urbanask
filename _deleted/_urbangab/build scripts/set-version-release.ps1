$file = "..\cache.manifest"
$content = Get-Content $file 
$newContent = @()

$content | ForEach-Object {

	if ($_ -match '\#ver (\d*\.\d*.\d*)') {

		$version = $matches[1]

	} 

}



$file = "..\config.xml"
$content = Get-Content $file 
$newContent = @()

$content | ForEach-Object {

	if ($_ -match 'version     = "') {

		$_ = '    version     = "' + $version + '">'

	} 

	$newContent += $_

}

Set-Content $file $newContent



$file = "..\index.html"
$content = Get-Content $file 
$newContent = @()

$content | ForEach-Object {

	if ($_ -match 'data-version=') {

		$_ = '<html lang="en" data-version="' + $version + '" manifest="cache.manifest">'

	} 

	$newContent += $_

}

Set-Content $file $newContent