#Requires -Modules @{ ModuleName="Az.Storage"; ModuleVersion="6.1.3" }

param (
    $bicepparamPath = './src/bicep/dev.storage.bicepparam',
    $runbookFilesPath = './src/runbooks/',
    $MAX_UPLOAD_SIZE = $env:MAX_UPLOAD_SIZE ?? 10mb
)

# build params json for storage to stdout and get the storage account name and container name
$bicepparamBuilt = bicep build-params $bicepparamPath --stdout | ConvertFrom-Json
$bicepparam = $bicepparamBuilt.parametersJson | ConvertFrom-Json

$uploadSplat = @{
    Container = $bicepparam.parameters.parStorageAccountBlobContainerName.value
    Context = New-AzStorageContext -StorageAccountName $bicepparam.parameters.parStorageAccountName.value
}

$runbookFiles = Get-ChildItem -File -Path $runbookFilesPath

$runbookFilesTotalSize = ($runbookFiles | Measure-Object -Property Length -Sum).Sum
$runbookFilesTotalSizeUnit = 'b'

if ($runbookFilesTotalSize -gt 1mb) {
    $runbookFilesTotalSize /= 1mb
    $runbookFilesTotalSizeUnit = 'MB'
}
if ($runbookFilesTotalSize -gt 1kb) {
    $runbookFilesTotalSize /= 1kb
    $runbookFilesTotalSizeUnit = 'KB'
}
Write-Verbose -Message ("Total upload size: [{0} {1}]" -f $runbookFilesTotalSize, $runbookFilesTotalSizeUnit) -Verbose

if ($runbookFilesTotalSize -gt $MAX_UPLOAD_SIZE) {
    throw "Total upload size exceeds the maximum allowed size of $MAX_UPLOAD_SIZE"
    exit 1
}

$runbookFiles | Set-AzStorageBlobContent @uploadSplat

# https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-blobs-synchronize
# azcopy login --identity --identity-client-id "<client-id>" # uami login azcopy
# azcopy sync 'C:\myDirectory' 'https://mystorageaccount.blob.core.windows.net/mycontainer' --recursive