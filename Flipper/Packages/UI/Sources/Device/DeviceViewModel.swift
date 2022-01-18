import Core
import Combine
import Inject
import Foundation

@MainActor
class DeviceViewModel: ObservableObject {
    @Published var appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var device: Peripheral? {
        didSet {
            if device?.state == .connected {
                presentConnectionsSheet = false
            }
        }
    }
    @Published var status: Status = .noDevice
    @Published var presentConnectionsSheet = false {
        didSet {
            if presentConnectionsSheet == true {
                appState.forgetDevice()
            }
        }
    }

    var firmwareVersion: String {
        guard let device = device else { return .noDevice }
        guard let info = device.information else { return .unknown }

        let version = info
            .softwareRevision
            .split(separator: " ")
            .prefix(2)
            .reversed()
            .joined(separator: " ")

        return .init(version)
    }

    var firmwareBuild: String {
        guard let device = device else { return .noDevice }
        guard let info = device.information else { return .unknown }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: String {
        guard let device = device else { return .noDevice }
        guard let storage = device.storage else { return .unknown }

        return storage.internal?.description ?? ""
    }

    var externalSpace: String {
        guard let device = device else { return .noDevice }
        guard let storage = device.storage else { return .unknown }

        return storage.external?.description ?? ""
    }

    init() {
        appState.$device
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)
    }

    func sync() {
        Task { await appState.synchronize() }
    }
}

extension StorageSpace: CustomStringConvertible {
    public var description: String {
        "\(free.hr) / \(total.hr)"
    }
}

extension Int {
    var hr: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(self))
    }
}