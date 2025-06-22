# TestTask
# Configuration Options
Describe the configurable options and how to customize them:

API Endpoint:
You can change the server URL in the code in Network.swif).

Retry Count & Delay:
You can configure the number of retry attempts for network requests and the delay between them. Defaults are:

retryCount = 3  
delay = 2 seconds  

Network Monitoring:
Enable or disable network monitoring by calling NetworkMonitor.shared.startMonitoring() in SceneDelegate.

Dependencies
None

Troubleshooting & Common Issues
None

Build Instructions
Clone the repository:
https://github.com/Olegarh1/TestTask

Run on Simulator or Real Device:
Select the target in Xcode and press Run.

Requires iOS 15+:
Make sure the deployment target is iOS 15 or higher.

