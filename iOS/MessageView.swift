import SwiftUI
import Combine
import ConnectIQ

struct MessageView: View {
    @State
    var message = ""

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 7
        return formatter
    }()

    var body: some View {
        Text(message.isEmpty ? "No message from the spirits." : "The spirits say:\n\(message)")
            .multilineTextAlignment(.center)
            .onReceive(GarminService.shared.observeMessages()) { data in
                do {
                    let dto = try JSONDecoder().decode(MessageDTO.self, from: data)
                    message = """
                    message: \(dto.message)
                    latitude: \(dto.latitude)
                    longitude: \(dto.longitude)
                    """
                } catch {
                    message = ""
                }
            }
            .onOpenURL { url in
                GarminService.shared.handle(url: url)
            }
            .onAppear {
                // This will let the user pick ConnectIQ devices to connect to the app (or automatically pick the only one if there aren't more).
                // Your app may be suspended during this, act accordingly.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ConnectIQ.shared?.showDeviceSelection()
                }
            }
            .onTapGesture {
                Task {
                    await GarminService.shared.broadcast(dto: "General Kenobi.")
                }
            }
    }
}
