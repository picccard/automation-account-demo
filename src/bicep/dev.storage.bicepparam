using './storage.bicep'

extends 'dev.shared.bicepparam'

param parStorageAccountAllowedIps = []
param parStorageBlobDataOwnerObjectIds = ['<REDACTED>']
