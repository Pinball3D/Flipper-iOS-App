class JSONArchiveStorage: ArchiveStorage {
    let storage: JSONStorage<[ArchiveItem]>

    var items: [ArchiveItem] {
        get { read() }
        set { write(newValue) }
    }

    init() {
        storage = .init(for: Peripheral.self, filename: "archive")
    }

    func read() -> [ArchiveItem] {
        storage.read() ?? []
    }

    func write(_ archive: [ArchiveItem]) {
        if !archive.isEmpty {
            storage.write(archive)
        } else {
            storage.delete()
        }
    }
}