targetScope = 'subscription'

param parLocation string
param parResourceGroupName string
param parStorageAccountName string
param parStorageAccountBlobContainerName string
param parAutomationAccountName string
param parStorageAccountSasTokenValidityLength string = 'PT1H'

var varStorageAccountUri = 'https://${storageAccount.name}.blob.${environment().suffixes.storage}'
// environment().suffixes => { ..., "storage": "core.windows.net" }
// e.g.'https://storageaccountname.blob.core.windows.net/runbooks/runbook1.ps1'

// date and time for scheule start time calculations
param now string = utcNow('yyyy-MM-ddTHH:mm:ss')
param currentHour string = '${utcNow('yyyy-MM-ddTHH')}:00:00'
param parTimeMidnight string = '1970-12-31T20:00:00' // override this

// The start time of a schedule must be at least 5 minutes after the time you create the schedule.
var minimumOffsetSeconds = 60 * 5
var safetyMarginOffsetSeconds = 60 * 3
var offsetSeconds = minimumOffsetSeconds + safetyMarginOffsetSeconds
var minimumEpochStartTime = dateTimeToEpoch(now) + offsetSeconds

param parSchedules scheduleType[]
param parRunbooks object[]

// make sure startTime exists on every schedule
var varSchedules = [
  for schedule in parSchedules: union(schedule, {
    startTime: !empty(schedule.?startTime)
      ? schedule.startTime
      : !empty(schedule.?startTimeDurationFromMidnight)
          ? dateTimeAdd(parTimeMidnight, schedule.startTimeDurationFromMidnight!)
          : !empty(schedule.?startTimeDurationFromCurrentHour)
              ? dateTimeAdd(currentHour, schedule.startTimeDurationFromCurrentHour!)
              : null
  })
]

// import { roleAssignmentType } from 'br/public:avm/res/automation/automation-account:0.6.0'
type scheduleType = {
  expiryTime: string?
  frequency: ('Day' | 'Hour' | 'Minute' | 'Month' | 'OneTime' | 'Week')
  @minValue(1)
  interval: int
  @maxLength(128)
  name: string
  startTime: string?
  startTimeDurationFromMidnight: string?
  startTimeDurationFromCurrentHour: string?
  startTimeDeferral: ('P1D' | 'PT1H' | 'n/a')
  timeZone: string
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' existing = {
  name: parResourceGroupName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: parStorageAccountName
  scope: rg

  resource storageAccountBlobService 'blobServices' existing = {
    name: 'default'

    resource storageAccountBlobContainer 'containers' existing = {
      name: parStorageAccountBlobContainerName
    }
  }
}

/*
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: parStorageAccountName
  scope: rg
}
resource storageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' existing = {
  name: 'default'
  parent: storageAccount
}
resource storageAccountBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' existing = {
  parent: storageAccountBlobService
  name: parStorageAccountBlobContainerName
}
*/

module automationAccount 'br/public:avm/res/automation/automation-account:0.6.0' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-automation-account'
  params: {
    name: parAutomationAccountName
    runbooks: [
      for runbook in parRunbooks: contains(runbook.uri, varStorageAccountUri)
        ? union(runbook, {
            scriptStorageAccountResourceId: storageAccount.id
            sasTokenValidityLength: parStorageAccountSasTokenValidityLength
          })
        : runbook
    ]
    schedules: [
      for schedule in varSchedules: union(schedule, {
        // add 0 days if start time is greater than minimumEpochStartTime, else add schedule.startTimeDeferral
        startTime: dateTimeAdd(
          schedule.startTime,
          (dateTimeToEpoch(schedule.startTime) > minimumEpochStartTime ? 'P0D' : schedule.startTimeDeferral)
        )
      })
    ]
  }
}

output outAutomationAccountId string = automationAccount.outputs.resourceId
output outSchedulesStartTime array = map(varSchedules, schedule => { startTime: schedule.startTime })
