function BackupGpgKeyring {
    param($filePath)

    If ($null -eq $filePath) {
        Write-Host "Please provide an export file path as argument."
        Write-Host
        Write-Host "Ex.: GpgTools C:\keyring.gpg"
        Return
    }

    # Get directory from path
    $directory = Split-Path -Parent $filePath

    # Create directory structure if does not exist
    If (!(Test-Path -Path $directory)) { 
        $null = New-Item $directory -ItemType Directory
    }

    gpg --export-options backup -o $filePath --export
}

function RestoreGpgKeyring {
    param($filePath)

    if (!(Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "File $filePath does not exist. Aborting."
        Return
    }

    #gpg --import-options restore --import PATH/TO/BACKUP/keyring.gpg
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