function BackupGpgKeyring {
    param($filePath)

    If ($null -eq $filePath) {
        Write-Host "Please provide an export zip file path as argument."
        Write-Host
        Write-Host "Ex.: GpgTools C:\mykeys.zip"
        Return
    }

    # Get directory from path
    $directory = Split-Path -Parent $filePath

    # Create directory structure if does not exist
    If (!(Test-Path -Path $directory)) { 
        $null = New-Item $directory -ItemType Directory
    }

    $privatePath = Join-Path -Path $directory -ChildPath "myprivatekeys.asc"
    $publicPath = Join-Path -Path $directory -ChildPath "mypubkeys.asc"
    $trustPath = Join-Path -Path $directory -ChildPath "otrust.txt"

    ## Export all public keys
    gpg -a --export $publicPath

    ## Export all encrypted private keys (which will also include corresponding public keys)
    gpg -a --export-secret-keys $privatePath

    ## Export gpg's trustdb to a text file
    gpg --export-ownertrust $trustPath

    $compress = @{
        Path             = $privatePath, $publicPath, $trustPath
        CompressionLevel = "Fastest"
        DestinationPath  = $filePath
    }
    Compress-Archive $compress
    Remove-Item $publicPath
    Remove-Item $privatePath
    Remove-Item $trustPath
}

function RestoreGpgKeyring {
    param($filePath)

    if (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "File $filePath does not exist. Aborting."
        Return
    }

    $directoryPath = Split-Path -Parent $filePath

    Expand-Archive -LiteralPath $filePath -DestinationPath $directoryPath

    $privatePath = Join-Path -Path $directoryPath -ChildPath "myprivatekeys.asc"
    $publicPath = Join-Path -Path $directoryPath -ChildPath "mypubkeys.asc"
    $trustPath = Join-Path -Path $directoryPath -ChildPath "otrust.txt"

    gpg --import $privatePath
    gpg --import $publicPath
    gpg -K
    gpg -k
    gpg --import-ownertrust $trustPath

    Remove-Item $privatePath
    Remove-Item $publicPath
    Remove-Item $trustPath
}

$action = $args[0]
$filePath = $args[1]

Switch ($action) {
    "backup" {  
        BackupGpgKeyring $filePath
    }
    "restore" {
        RestoreGpgKeyring $filePath
    }
    default {
        Write-Host "This action is not supported. Supported actions: backup, restore"
    }
}