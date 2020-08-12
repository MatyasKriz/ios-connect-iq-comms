# iOS Companion App
In addition to all the steps described in the [Official ConnectIQ iOS SDK Guide](https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/), `gcm-ciq` application query scheme needs to be added to the Info.plist like so:
```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>gcm-ciq</string>
</array>
```

Make sure to match `watchAppUuid` with the one from the ConnectIQ app [manifest.xml](../ConnectIQ/manifest.xml).

`urlScheme` must match the value specified in [Info.plist](Info.plist).

### IMPORTANT
For some unknown reason, ConnectIQ iOS SDK **REQUIRES** your app to set "Bundle display name" (key `CFBundleDisplayName` in **Info.plist**) or the device selection just up and fails.

If anything's not clear enough, consult [Official ConnectIQ iOS SDK Guide](https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/).
