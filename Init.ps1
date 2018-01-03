param($installPath, $toolsPath, $package, $project)
$env:Path += ";" + (Join-Path $toolsPath "bin")