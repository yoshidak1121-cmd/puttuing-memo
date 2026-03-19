import Foundation

/// ローカルストレージへのデータ永続化を担うクラス
class DataStore {
    static let shared = DataStore()

    private let puttingKey = "puttingRecords"
    private let approachKey = "approachRecords"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Putting Records

    func savePuttingRecords(_ records: [PuttingRecord]) {
        if let data = try? encoder.encode(records) {
            UserDefaults.standard.set(data, forKey: puttingKey)
        }
    }

    func loadPuttingRecords() -> [PuttingRecord] {
        guard let data = UserDefaults.standard.data(forKey: puttingKey),
              let records = try? decoder.decode([PuttingRecord].self, from: data) else {
            return []
        }
        return records
    }

    func deleteAllPuttingRecords() {
        UserDefaults.standard.removeObject(forKey: puttingKey)
    }

    // MARK: - Approach Records

    func saveApproachRecords(_ records: [ApproachRecord]) {
        if let data = try? encoder.encode(records) {
            UserDefaults.standard.set(data, forKey: approachKey)
        }
    }

    func loadApproachRecords() -> [ApproachRecord] {
        guard let data = UserDefaults.standard.data(forKey: approachKey),
              let records = try? decoder.decode([ApproachRecord].self, from: data) else {
            return []
        }
        return records
    }

    func deleteAllApproachRecords() {
        UserDefaults.standard.removeObject(forKey: approachKey)
    }
}
