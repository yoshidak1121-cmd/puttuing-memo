import Foundation
import Combine

/// 履歴・統計全体のViewModel
class HistoryViewModel: ObservableObject {
    @Published var puttingRecords: [PuttingRecord] = []
    @Published var approachRecords: [ApproachRecord] = []

    private let store: DataStore

    init(store: DataStore = DataStore.shared) {
        self.store = store
        reload()
    }

    func reload() {
        puttingRecords = store.loadPuttingRecords().sorted { $0.date > $1.date }
        approachRecords = store.loadApproachRecords().sorted { $0.date > $1.date }
    }

    // MARK: - Combined Statistics

    var totalPuttingCount: Int { puttingRecords.count }
    var totalApproachCount: Int { approachRecords.count }

    var overallPuttingSuccessRate: Double {
        guard !puttingRecords.isEmpty else { return 0 }
        let successes = puttingRecords.filter { $0.result == .success }.count
        return Double(successes) / Double(puttingRecords.count) * 100
    }

    var averagePuttingDistance: Double {
        guard !puttingRecords.isEmpty else { return 0 }
        return puttingRecords.map { $0.initialDistance }.reduce(0, +) / Double(puttingRecords.count)
    }

    var recentPuttingRecords: [PuttingRecord] {
        Array(puttingRecords.prefix(5))
    }

    var recentApproachRecords: [ApproachRecord] {
        Array(approachRecords.prefix(5))
    }

    // MARK: - Export

    func exportCSV() -> String {
        let putting = CSVExporter.exportPuttingRecords(puttingRecords)
        let approach = CSVExporter.exportApproachRecords(approachRecords)
        return "=== パッティング記録 ===\n\(putting)\n\n=== アプローチ記録 ===\n\(approach)"
    }
}
