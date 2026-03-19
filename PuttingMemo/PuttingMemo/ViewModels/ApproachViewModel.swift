import Foundation
import Combine

/// アプローチ記録のViewModel
class ApproachViewModel: ObservableObject {
    @Published var records: [ApproachRecord] = []
    @Published var filteredRecords: [ApproachRecord] = []
    @Published var searchText: String = ""
    @Published var filterClub: Club? = nil
    @Published var filterLie: LieCondition? = nil

    private let store: DataStore

    init(store: DataStore = DataStore.shared) {
        self.store = store
        self.records = store.loadApproachRecords()
        applyFilters()
    }

    // MARK: - CRUD

    func addRecord(_ record: ApproachRecord) {
        records.append(record)
        saveAndFilter()
    }

    func updateRecord(_ record: ApproachRecord) {
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

        if let club = filterClub {
            result = result.filter { $0.club == club }
        }
        if let lie = filterLie {
            result = result.filter { $0.lieCondition == lie }
        }
        if !searchText.isEmpty {
            result = result.filter { record in
                let holeText = record.holeNumber.map { String($0) } ?? ""
                return holeText.contains(searchText) ||
                       record.club.rawValue.contains(searchText) ||
                       record.notes.contains(searchText)
            }
        }

        filteredRecords = result.sorted { $0.date > $1.date }
    }

    func clearFilters() {
        searchText = ""
        filterClub = nil
        filterLie = nil
        applyFilters()
    }

    // MARK: - Statistics

    var averageRemainingDistance: Double {
        guard !records.isEmpty else { return 0 }
        return records.map { $0.remainingDistance }.reduce(0, +) / Double(records.count)
    }

    var averageNextPuttingDistance: Double {
        let values = records.compactMap { $0.nextPuttingDistance }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    var averageDeviation: Double {
        let values = records.compactMap { $0.distanceDeviation }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    var clubUsageStats: [(club: Club, count: Int)] {
        var counts: [Club: Int] = [:]
        for record in records {
            counts[record.club, default: 0] += 1
        }
        return counts.map { (club: $0.key, count: $0.value) }
                     .sorted { $0.count > $1.count }
    }

    // MARK: - Private

    private func saveAndFilter() {
        store.saveApproachRecords(records)
        applyFilters()
    }
}
