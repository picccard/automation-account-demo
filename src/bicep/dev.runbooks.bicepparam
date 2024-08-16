using './runbooks.bicep'

extends 'dev.shared.bicepparam'

param parAutomationAccountName = 'aa-eul-management'

param parSchedules = [
  {
    name: 'startTimeDurationFromMidnight-PT15H30M-recur-12-Hour'
    expiryTime: '2026-12-31T23:59'
    frequency: 'Hour'
    interval: 12
    startTimeDurationFromMidnight: 'PT15H30M' // '2024-12-31T15:30'
    startTimeDeferral: 'P1D'
    timeZone: 'Europe/Oslo'
  }
  {
    name: 'startTimeDurationFromCurrentHour-PT47M-recur-1-Hour'
    expiryTime: '9999-12-31T13:00'
    frequency: 'Hour'
    interval: 1
    startTimeDurationFromCurrentHour: 'PT47M'
    startTimeDeferral: 'PT1H'
    timeZone: 'Europe/Oslo'
  }
  {
    name: 'startTime-2024-12-31T20:30-recur-24-Hour'
    expiryTime: null
    frequency: 'Hour'
    interval: 24
    startTime: '2024-12-31T20:30'
    startTimeDeferral: 'n/a'
    timeZone: 'Europe/Oslo'
  }
]

param parRunbooks = [
  {
    name: 'TestRunbook'
    description: 'Test runbook'
    type: 'PowerShell72'
    uri: 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.automation/101-automation/scripts/AzureAutomationTutorial.ps1'
    // version: '1.0.0.0'
  }
  {
    name: 'runbook1'
    description: 'runbook1'
    type: 'PowerShell72'
    uri: 'https://strunbooks.blob.core.windows.net/runbooks/runbook1.ps1'
    // version: '1.0.0.0'
  }
]
