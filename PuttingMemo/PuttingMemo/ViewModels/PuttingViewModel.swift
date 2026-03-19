import Foundation
import Combine

/// パッティング記録のViewModel
class PuttingViewModel: ObservableObject {
    @Published var records: [PuttingRecord] = []
    @Published var filteredRecords: [PuttingRecord] = []
    @Published var searchText: String = ""
    @Published var filterResult: PuttingResult? = nil
    @Published var filterHole: Int? = nil

    private let store: DataStore

    init(store: DataStore = DataStore.shared) {
        self.store = store
        self.records = store.loadPuttingRecords()
        applyFilters()
    }

    // MARK: - CRUD

    func addRecord(_ record: PuttingRecord) {
        records.append(record)
        saveAndFilter()
    }

    func updateRecord(_ record: PuttingRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveAndFilter()
        }
    }

    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveAndFilter()
    }

    func deleteRecord(id: UUID) {
        records.removeAll { $0.id == id }
        saveAndFilter()
    }

    // MARK: - Filters

    func applyFilters() {
        var result = records

        if let hole = filterHole {
            result = result.filter { $0.holeNumber == hole }
        }
        if let resultFilter = filterResult {
            result = result.filter { $0.result == resultFilter }
        }
        if !searchText.isEmpty {
            result = result.filter { record in
                let holeText = record.holeNumber.map { String($0) } ?? ""
                return holeText.contains(searchText) ||
                       record.lineType.rawValue.contains(searchText) ||
                       record.notes.contains(searchText)
            }
        }

        filteredRecords = result.sorted { $0.date > $1.date }
    }

    func clearFilters() {
        searchText = ""
        filterResult = nil
        filterHole = nil
        applyFilters()
    }

    // MARK: - Statistics

    var successRate: Double {
        guard !records.isEmpty else { return 0 }
        let successes = records.filter { $0.result == .success }.count
        return Double(successes) / Double(records.count) * 100
    }

    var averageInitialDistance: Double {
        guard !records.isEmpty else { return 0 }
        return records.map { $0.initialDistance }.reduce(0, +) / Double(records.count)
    }

    var averageRemainingDistance: Double {
        let withRemaining = records.compactMap { $0.remainingDistance }
        guard !withRemaining.isEmpty else { return 0 }
        return withRemaining.reduce(0, +) / Double(withRemaining.count)
    }

    var successRateByDistance: [(range: String, rate: Double)] {
        let bins: [(range: String, min: Double, max: Double)] = [
            ("〜1m", 0, 1),
            ("1〜3m", 1, 3),
            ("3〜5m", 3, 5),
            ("5〜10m", 5, 10),
            ("10m〜", 10, Double.infinity)
        ]
        return bins.compactMap { bin in
            let inRange = records.filter { $0.initialDistance >= bin.min && $0.initialDistance < bin.max }
            guard !inRange.isEmpty else { return nil }
            let rate = Double(inRange.filter { $0.result == .success }.count) / Double(inRange.count) * 100
            return (range: bin.range, rate: rate)
        }
    }

    // MARK: - Private

    private func saveAndFilter() {
        store.savePuttingRecords(records)
        applyFilters()
    }
}
