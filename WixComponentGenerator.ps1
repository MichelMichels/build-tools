$files = Get-ChildItem | ForEach-Object {
    If (Test-Path -Path $_.Name -PathType Leaf) { 
        $_.Name        
    }
}

$index = 0
$components = $files | ForEach-Object {
    "<Component><File Source=`"" + $_ + "`" /></Component>"        
}

Set-Clipboard $components
"Wix components copied to clipboard."