# ConnectIQ and iOS comms example

A pair of simple example apps that use the [Garmin Connect iOS app](https://apps.apple.com/us/app/garmin-connect/id583446403) to initiate connection between a ConnectIQ and an iOS device.

After initiating connection in AppDelegate `func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus)` on state `.connected`, a listener for messages is registered and from that point onward, all messages sent from the ConnectIQ app are shown in the iOS app in its only view.

Likewise, the ConnectIQ app is listening for messages and shows the sent message at the center of the screen.

After the first message sent from the iOS app, further messages can be sent manually by tapping the visible text.

#### ConnectIQ App
Visit [ConnectIQ subfolder](ConnectIQ) for the readme specific to the ConnectIQ app.

#### iOS Companion App
Visit [iOS subfolder](iOS) for the readme specific to the iOS companion app.

### IMPORTANT
For some unknown reason, ConnectIQ iOS SDK **REQUIRES** your app to set "Bundle display name" (key `CFBundleDisplayName` in **Info.plist**) or the device selection just up and fails.

If anything's not clear enough, consult [Official ConnectIQ iOS SDK Guide](https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/).
