//
//  AppDelegate.swift
//
//  Created by Matyas Kriz on 21/10/2019.
//

import UIKit
import SwiftUI
import Combine
import ConnectIQ

extension ConnectIQ {
    static var shared: ConnectIQ? {
        return sharedInstance()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IQDeviceEventDelegate, IQAppMessageDelegate {
    // This must match the value in `Info.plist`.
    private static let urlScheme = "org.brightify.ConnectIQComms-ciq"
    // UUID from `manifest.xml` of the ConnectIQ app.
    private static let watchAppUuid = UUID(uuidString: "7f86383c-1354-4e4a-9939-859be06cdccc")

    // Device UUID mapped to the CommsApp on that device.
    private var apps: [UUID: IQApp] = [:]

    var window: UIWindow?
    @Published private var message = ""

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 7
        return formatter
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ConnectIQ.shared?.initialize(withUrlScheme: AppDelegate.urlScheme, uiOverrideDelegate: nil)

        let messageView = MessageView(messagePublisher: $message.eraseToAnyPublisher()) { [weak self] in
            self?.broadcastMessage()
        }

        let window = UIWindow()
        window.rootViewController = UIHostingController(rootView: messageView)
        self.window = window
        window.makeKeyAndVisible()

        // This will let the user pick ConnectIQ devices to connect to the app (or automatically pick the only one if there aren't more).
        // Your app may be suspended during this, act accordingly.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ConnectIQ.shared?.showDeviceSelection()
        }

        return true
    }
    
    private func broadcastMessage() {
        for app in apps.values {
            // You may send any ObjC type (e.g. NSNumber, NSString, NSArray, NSDictionary).
            // Unless you're experiencing difficulties, there's no need to use the `NS*` types directly,
            // you can use their Swift equivalents.
            ConnectIQ.shared?.sendMessage("General Kenobi.", to: app, progress: nil, completion: { print($0) })
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == AppDelegate.urlScheme,
            let devices = ConnectIQ.shared?.parseDeviceSelectionResponse(from: url) as? [IQDevice] else { return false }
        registerForDeviceEvents(devices: devices)
        return true
    }

    private func registerForDeviceEvents(devices: [IQDevice]) {
        for device in devices {
            ConnectIQ.shared?.register(forDeviceEvents: device, delegate: self)
        }
    }

    func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
        switch status {
        case .connected:
            // The `store` is not necessary for sending messages, I suppose it's for when you want the user to download the app.
            // `IQApp` class needs to be instantiated for every IQDevice, you can't share them, it's the app on the specific device.
            let app = IQApp(uuid: AppDelegate.watchAppUuid, store: nil, device: device)
            apps[device.uuid] = app

            ConnectIQ.shared?.register(forAppMessages: app, delegate: self)

            // IMPORTANT: Apparently sending a message right after connecting sends the messages to the void.
            // I have no idea why it doesn't work, but feel free to shrink the delay. I've found that 100ms works consistently.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ConnectIQ.shared?.sendMessage("Hello there.", to: app, progress: nil, completion: { print($0) })
            }

        case .bluetoothNotReady, .invalidDevice, .notConnected, .notFound:
            apps.removeValue(forKey: device.uuid)

        @unknown default:
            print("New case, still unhandled. \(status.rawValue)")
        }
    }

    func receivedMessage(_ message: Any!, from app: IQApp!) {
        print("Received message from ConnectIQ: \(message.debugDescription)")

        guard let array = message as? [Any] else {
            print("Failed to parse message sent from ConnectIQ.")
            return
        }

        for (index, contents) in array.enumerated() {
            guard let dictionary = contents as? [Int: Any] else {
                print("Failed to parse ConnectIQ message contents at index \(index).")
                return
            }

            guard let latitude = dictionary[MessageCodingKey.latitude.rawValue] as? Double else {
                print("Failed to get latitude from ConnectIQ message.")
                return
            }
            guard let longitude = dictionary[MessageCodingKey.longitude.rawValue] as? Double else {
                print("Failed to get longitude from ConnectIQ message.")
                return
            }
            guard let message = dictionary[MessageCodingKey.message.rawValue] as? String else {
                print("Failed to get message from ConnectIQ message.")
                return
            }

            print("Got message with data: \(latitude), \(longitude) with message '\(message)'.")

            self.message = "Meet me at \(formatter.string(from: NSNumber(value: latitude)) ?? "0"), \(formatter.string(from: NSNumber(value: longitude)) ?? "0").\n\(message)"
        }
    }

    deinit {
        ConnectIQ.shared?.unregister(forAllDeviceEvents: self)
        ConnectIQ.shared?.unregister(forAllAppMessages: self)
    }
}

extension AppDelegate {
    private enum MessageCodingKey: Int {
        case latitude = 0
        case longitude = 1
        case message = 2
    }
}
