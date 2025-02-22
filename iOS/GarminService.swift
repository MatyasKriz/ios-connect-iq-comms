import Foundation
import Combine
import ConnectIQ

final class GarminService {
    // This must match the value in `Info.plist`.
    private static let urlScheme = "cz.tyas.ConnectIQComms-ciq"

    static let shared = GarminService()

    private let manager = Manager()

    private let messageSubject = PassthroughSubject<Data, Never>()

    private var lifetimeCancellables: Set<AnyCancellable> = []

    private init() {
        ConnectIQ.shared?.initialize(withUrlScheme: Self.urlScheme, uiOverrideDelegate: nil)

        manager.messageHandler = { [weak self] messageData in
            self?.messageSubject.send(messageData)
        }
    }

    func observeMessages() -> AnyPublisher<Data, Never> {
        messageSubject.eraseToAnyPublisher()
    }

    @discardableResult
    func handle(url: URL) -> Bool {
        guard url.scheme == Self.urlScheme,
              let devices = ConnectIQ.shared?.parseDeviceSelectionResponse(from: url) as? [IQDevice]
        else { return false }

        for device in devices {
            ConnectIQ.shared?.register(forDeviceEvents: device, delegate: manager)
        }

        return true
    }

    func broadcast(dto: any Encodable) async {
        await manager.broadcast(dto: dto)
    }
}

private extension GarminService {
    final class Manager: NSObject, IQDeviceEventDelegate, IQAppMessageDelegate {
        private static let watchAppUuid = UUID(uuidString: "7f86383c-1354-4e4a-9939-859be06cdccc")

        @Published
        private(set) var apps: [UUID: IQApp] = [:]

        var messageHandler: ((Data) -> Void)?

        func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
            switch status {
            case .connected:
                // The `store` is not necessary for sending messages, I suppose it's for when you want the user to download the app.
                // `IQApp` class needs to be instantiated for every IQDevice, you can't share them, it's the app on the specific device.
                let app = IQApp(uuid: Self.watchAppUuid, store: nil, device: device)
                apps[device.uuid] = app

                ConnectIQ.shared?.register(forAppMessages: app, delegate: self)

                // IMPORTANT: Sending a message right after connecting sends the messages to the void.
                // I have no idea why it doesn't work, but feel free to shrink the delay. I've found that 100ms works reliably.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    ConnectIQ.shared?.sendMessage("Hello there.", to: app, progress: nil, completion: {
                        print($0)
                    })
                }

            case .bluetoothNotReady, .invalidDevice, .notConnected, .notFound:
                apps.removeValue(forKey: device.uuid)

            @unknown default:
                print("Unhandled case '\(status.rawValue)'.")
            }
        }

        func receivedMessage(_ message: Any!, from app: IQApp!) {
            print("Received message from ConnectIQ: \(message.debugDescription)")

            guard let message else { return }

            do {
                messageHandler?(try JSONSerialization.data(withJSONObject: message))
            } catch {
                print("Failed to parse payload:", error)
            }
        }

        func broadcast(dto: any Encodable) async {
            for app in apps.values {
                // You may send any ObjC type (e.g. NSNumber, NSString, NSArray, NSDictionary).
                // Unless you're experiencing difficulties, there's no need to use the `NS*` types directly,
                // you can use their Swift equivalents.
                await ConnectIQ.shared?.sendMessage(dto, to: app, progress: nil)
                print("Sent \(dto) to \(app)")
            }
        }

        deinit {
            ConnectIQ.shared?.unregister(forAllDeviceEvents: self)
            ConnectIQ.shared?.unregister(forAllAppMessages: self)
        }
    }
}

extension ConnectIQ {
    static var shared: ConnectIQ? {
        sharedInstance()
    }
}
