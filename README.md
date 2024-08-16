# automation-account-demo
Bicep code to handle schedules and runbooks in an automation account

## azcopy log
```text
PS /Users/eskillarsen/automation-account-demo> azcopy sync ./src/runbooks/ 'https://strunbooks.blob.core.windows.net/runbooks' --recursive > /dev/null


PS /Users/eskillarsen/automation-account-demo> cat /Users/eskillarsen/.azcopy/16ffa5a2-c0be-4a43-76e0-bd2ea675aa28-scanning.log
2024/08/16 13:00:57 AzcopyVersion  10.26.0
2024/08/16 13:00:57 OS-Environment  darwin
2024/08/16 13:00:57 OS-Architecture  arm64
2024/08/16 13:00:57 Log times are in UTC. Local time is 16 Aug 2024 15:00:57
2024/08/16 13:00:58 ==> REQUEST/RESPONSE (Try=1/32.973083ms, OpTime=129.013125ms) -- RESPONSE SUCCESSFULLY RECEIVED
   GET https://strunbooks.blob.core.windows.net/runbooks?comp=list&delimiter=%2F&include=metadata&prefix=&restype=container
   X-Ms-Request-Id: [d61167ff-901e-006c-72dc-ef94b3000000]

2024/08/16 13:00:58 File runbook1.ps1 was overwritten because the source is more recent than the destination
2024/08/16 13:00:58 File runbook2.ps1 was skipped because the source has an older LMT than the destination
2024/08/16 13:00:59 Closing Log


PS /Users/eskillarsen/automation-account-demo> cat /Users/eskillarsen/.azcopy/16ffa5a2-c0be-4a43-76e0-bd2ea675aa28.log         
2024/08/16 13:00:57 AzcopyVersion  10.26.0
2024/08/16 13:00:57 OS-Environment  darwin
2024/08/16 13:00:57 OS-Architecture  arm64
2024/08/16 13:00:57 Log times are in UTC. Local time is 16 Aug 2024 15:00:57
2024/08/16 13:00:57 ISO 8601 START TIME: to copy files that changed before or after this job started, use the parameter --include-before=2024-08-16T13:00:52Z or --include-after=2024-08-16T13:00:52Z
2024/08/16 13:00:57 Authenticating to destination using Azure AD
2024/08/16 13:00:57 Any empty folders will not be processed, because source and/or destination doesn't have full folder support
2024/08/16 13:00:58 Job-Command sync ./src/runbooks/ https://strunbooks.blob.core.windows.net/runbooks --recursive 
2024/08/16 13:00:58 Number of CPUs: 69
2024/08/16 13:00:58 Max file buffer RAM 0.420 GB
2024/08/16 13:00:58 Max concurrent network operations: 176 (Based on number of CPUs. Set AZCOPY_CONCURRENCY_VALUE environment variable to override)
2024/08/16 13:00:58 Check CPU usage when dynamically tuning concurrency: true (Based on hard-coded default. Set AZCOPY_TUNE_TO_CPU environment variable to true or false override)
2024/08/16 13:00:58 Max concurrent transfer initiation routines: 64 (Based on hard-coded default. Set AZCOPY_CONCURRENT_FILES environment variable to override)
2024/08/16 13:00:58 Max enumeration routines: 16 (Based on hard-coded default. Set AZCOPY_CONCURRENT_SCAN environment variable to override)
2024/08/16 13:00:58 Parallelize getting file properties (file.Stat): false (Based on AZCOPY_PARALLEL_STAT_FILES environment variable)
2024/08/16 13:00:58 Max open files when downloading: 2147483066 (auto-computed)
2024/08/16 13:00:58 Final job part has been created
2024/08/16 13:00:58 Final job part has been scheduled
2024/08/16 13:00:58 INFO: [P#0-T#0] Starting transfer: Source "/Users/eskillarsen/automation-account-demo/src/runbooks/runbook1.ps1" Destination "https://strunbooks.blob.core.windows.net/runbooks/runbook1.ps1". Specified chunk size 8388608
2024/08/16 13:00:58 ==> REQUEST/RESPONSE (Try=1/31.725333ms, OpTime=64.441083ms) -- RESPONSE SUCCESSFULLY RECEIVED
   PUT https://strunbooks.blob.core.windows.net/runbooks/runbook1.ps1
   X-Ms-Request-Id: [d2bd5ab8-301e-0065-6cdc-efd160000000]

2024/08/16 13:00:58 ==> REQUEST/RESPONSE (Try=1/8.480625ms, OpTime=8.603917ms) -- RESPONSE SUCCESSFULLY RECEIVED
   HEAD https://strunbooks.blob.core.windows.net/runbooks/runbook1.ps1
   X-Ms-Request-Id: [d2bd5abd-301e-0065-6fdc-efd160000000]

2024/08/16 13:00:58 INFO: [P#0-T#0] UPLOADSUCCESSFUL: https://strunbooks.blob.core.windows.net/runbooks/runbook1.ps1
2024/08/16 13:00:58 JobID=16ffa5a2-c0be-4a43-76e0-bd2ea675aa28, Part#=0, TransfersDone=1 of 1
2024/08/16 13:00:58 all parts of entire Job 16ffa5a2-c0be-4a43-76e0-bd2ea675aa28 successfully completed, cancelled or paused
2024/08/16 13:00:58 is part of Job which 1 total number of parts done 
2024/08/16 13:00:59 PERF: primary performance constraint is Unknown. States: X:  0, O:  0, M:  0, L:  0, R:  0, D:  0, W:  0, F:  0, B:  0, E:  0, T:  0, GRs: 176
2024/08/16 13:00:59 100.0 %, 1 Done, 0 Failed, 0 Pending, 1 Total, 2-sec Throughput (Mb/s): 0.0003
2024/08/16 13:00:59 

Diagnostic stats:
IOPS: 1
End-to-end ms per request: 36
Network Errors: 0.00%
Server Busy: 0.00%

Job 16ffa5a2-c0be-4a43-76e0-bd2ea675aa28 Summary
Files Scanned at Source: 2
Files Scanned at Destination: 2
Elapsed Time (Minutes): 0.0334
Number of Copy Transfers for Files: 1
Number of Copy Transfers for Folder Properties: 0 
Total Number of Copy Transfers: 1
Number of Copy Transfers Completed: 1
Number of Copy Transfers Failed: 0
Number of Deletions at Destination: 0
Total Number of Bytes Transferred: 70
Total Number of Bytes Enumerated: 70
Final Job Status: Completed

2024/08/16 13:00:59 Closing Log
```

## References
- https://arinco.com.au/blog/deploying-an-automation-account-with-a-runbook-and-schedule-using-bicep/
- https://alanparr.github.io/bicep-create-storage-account-and-sas
- https://github.com/Azure/bicep/issues/6955
- https://gregorsuttie.com/2023/05/30/azure-vm-extensions-part-1-dsc-extensions/
- https://github.com/Azure/bicep/issues/6048
- https://github.com/Azure/bicep-types-az/issues/2150