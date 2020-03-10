# ConnectIQ App

This part of the communications system is arguably the harder one because of the nature of the Monkey C language being a glorified JavaScript. Errors that manifest mainly at runtime and no viable way to debug an app on device didn't help when creating a ConnectIQ app.

`</rant>`

### Important Stuff
For correct communication between the ConnectIQ app and iOS companion app, you need to make sure that your manifest settings contain valid app UUID as well as "Communications" and "BluetoothLowEnergy" permissions.

**IMPORTANT**: I don't think this can work in the simulator, you'll need a real device to run this on.

That's about it, check "ExampleCommsApp.mc" for Communications examples (both sending and receiving).

If anything's not clear enough, consult [Official ConnectIQ iOS SDK Guide](https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/).
