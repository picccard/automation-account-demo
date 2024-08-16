#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="7.2.0" }

param (
    [string]$Subscription = 'management',
    [switch]$Storage,
    [switch]$Runbooks,
    [string]$StorageTemplateFile = './src/bicep/storage.bicep',
    [string]$StorageTemplateParameterFile = './src/bicep/dev.storage.bicepparam',
    [string]$RunbooksTemplateFile = './src/bicep/runbooks.bicep',
    [string]$RunbooksTemplateParameterFile = './src/bicep/dev.runbooks.bicepparam',
    [string]$Location = 'norwayeast',
    [string]$Timezone = 'Europe/Oslo'
)

function ConvertFrom-TimezoneClockToUtc {
    <#
        .SYNOPSIS
            Converts a time from a timezone to UTC.
        .DESCRIPTION
            Converts a time from a timezone to UTC.
        .PARAMETER Clock
            Time to convert as HH:mm, e.g. 18:30
        .PARAMETER Timezone
            Timezone to convert from, e.g. Europe/Oslo
        .EXAMPLE
            ConvertFrom-TimezoneClockToUtc -Timezone 'Europe/Oslo' -Clock '12:00'
            ConvertFrom-TimezoneClockToUtc -Timezone 'Asia/Kathmandu' -Clock '12:00'
            ConvertFrom-TimezoneClockToUtc -Timezone 'Pacific/Chatham' -Clock '12:00'
        .EXAMPLE
            (ConvertFrom-TimezoneClockToUtc -Timezone 'Europe/Oslo' -Clock '00:00').ToString('yyyy-MM-ddTHH:mm:ss')
    #>
    param (
        [Parameter(HelpMessage = "Time to convert as HH:mm, e.g. 18:30", Mandatory = $true)]
        [string]
        $Clock,

        [Parameter(HelpMessage = "Timezone to convert from, e.g. Europe/Oslo", Mandatory = $false)]
        [ValidateScript(
            { [System.TimeZoneInfo]::GetSystemTimeZones().Id -contains $_ },
            ErrorMessage = "Invalid timezone, see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
        )]
        [string]
        $Timezone
    )

    # https://craigforrester.com/posts/convert-times-between-time-zones-with-powershell/
    $timezone_src = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match $Timezone }
    $timezone_utc = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match "UTC" }

    $from_datetime = "{0} {1}" -f (Get-Date).ToString("yyyy-MM-dd"), $Clock # format: 2021-09-30 18:30

    return [System.TimeZoneInfo]::ConvertTime($from_datetime, $timezone_src, $timezone_utc)
}

$splatStorage = @{
    Name                  = -join ('storage-for-runbooks-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $Location
    TemplateFile          = $StorageTemplateFile
    TemplateParameterFile = $StorageTemplateParameterFile
    # parStorageAccountAllowedIps = @((Invoke-RestMethod -Uri "checkip.amazonaws.com").Trim())
    Verbose               = $true
}

$splatRunbooks = @{
    Name                  = -join ('runbooks-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = 'norwayeast'
    TemplateFile          = $RunbooksTemplateFile
    TemplateParameterFile = $RunbooksTemplateParameterFile
    parTimeMidnight       = (ConvertFrom-TimezoneClockToUtc -Timezone $Timezone -Clock '00:00').ToString('yyyy-MM-ddTHH:mm:ss')
    # parGitHubToken        = $env:GITHUB_TOKEN
    Verbose               = $true
}

Select-AzSubscription -Subscription $Subscription

if ($Storage) {
    New-AzSubscriptionDeployment @splatStorage
}

if ($Runbooks) {
    New-AzSubscriptionDeployment @splatRunbooks
}
