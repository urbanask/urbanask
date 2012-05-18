$file = "..\cache.manifest"
$content = Get-Content $file 
$newContent = @()

$content | ForEach-Object {

	if ($_ -match '\#ver (\d)\.(\d).(\d)') {

		$majorVersion = $matches[1]
		$minorVersion = $matches[2]
		$revisionVersion = ([int]$matches[3] + 1)
		$version = $majorVersion + "." + $minorVersion + "." + $revisionVersion
		$_ = '#ver ' + $version

	} 

	$newContent += $_

}

Set-Content $file $newContent



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