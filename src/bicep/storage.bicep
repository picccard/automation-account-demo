targetScope = 'subscription'

param parLocation string
param parResourceGroupName string
param parStorageAccountName string
param parStorageAccountBlobContainerName string
param parStorageAccountAllowedIps string[]
param parStorageBlobDataOwnerObjectIds string[]

var varStorageAccountIpRules = [for publicIp in parStorageAccountAllowedIps: { action: 'Allow', value: publicIp }]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  location: parLocation
  name: parResourceGroupName
}

/*
module deploymentScript 'br/public:avm/res/resources/deployment-script:0.3.1' = {
  scope: rg
  name: 'deploymentScriptDeployment'
  params: {
    // Required parameters
    kind: 'AzurePowerShell'
    name: 'rdsps001'
    // Non-required parameters
    //arguments: '-var1 \\\'AVM Deployment Script test!\\\''
    azPowerShellVersion: '9.7'
    location: parLocation
    //retentionInterval: 'P1D'
    scriptContent: '$DeploymentScriptOutputs = @{ 'publicip' = (Invoke-RestMethod -Uri "checkip.amazonaws.com").Trim() }'
    //storageAccountResourceId: '<storageAccountResourceId>'
  }
}
output armPublicIp1 string = deploymentScript.outputs.outputs.publicip
*/

/*
module deploymentScript2 'br/public:avm/res/resources/deployment-script:0.3.1' = {
  scope: rg
  name: 'deploymentScriptDeployment2'
  params: {
    kind: 'AzureCLI'
    name: 'rdscli002'
    azCliVersion: '2.9.1'
    location: parLocation
    retentionInterval: 'P1D'
    scriptContent: 'jq -n -c --arg pubip "$(curl \'checkip.amazonaws.com\')" \'{"publicip": $pubip}\' > $AZ_SCRIPTS_OUTPUT_PATH'
  }
}
output armPublicIp2 string = deploymentScript2.outputs.outputs.publicip
*/

module storageForTesting 'br/public:avm/res/storage/storage-account:0.9.1' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-storage-account'
  params: {
    name: parStorageAccountName
    skuName: 'Standard_LRS'
    networkAcls: empty(parStorageAccountAllowedIps)
      ? { defaultAction: 'Allow' }
      : {
          defaultAction: 'Deny'
          bypass: 'AzureServices'
          virtualNetworkRules: []
          resourceAccessRules: []
          ipRules: varStorageAccountIpRules
        }
    blobServices: {
      containers: [
        { name: parStorageAccountBlobContainerName }
      ]
    }
    roleAssignments: [
      for objectId in parStorageBlobDataOwnerObjectIds: {
        principalId: objectId
        principalType: 'User'
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
      }
    ]
  }
}
