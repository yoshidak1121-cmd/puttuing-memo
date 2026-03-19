import Foundation

/// CSV形式でのエクスポートユーティリティ
struct CSVExporter {

    // MARK: - Putting Records

    static func exportPuttingRecords(_ records: [PuttingRecord]) -> String {
        let header = "日付,ホール番号,初期距離(m),ラインの特徴,勾配,結果,残り距離(m),オーバー/ショート,メモ"
        let rows = records.map { record -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date = formatter.string(from: record.date)
            let hole = record.holeNumber.map { String($0) } ?? ""
            let remaining = record.remainingDistance.map { String(format: "%.1f", $0) } ?? ""
            return [
                date,
                hole,
                String(format: "%.1f", record.initialDistance),
                record.lineType.rawValue,
                record.slopeType.rawValue,
                record.result.rawValue,
                remaining,
                record.remainingStatus.rawValue,
                csvEscape(record.notes)
            ].joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    // MARK: - Approach Records

    static func exportApproachRecords(_ records: [ApproachRecord]) -> String {
        let header = "日付,ホール番号,残り距離(m),使用クラブ,ライの状況,手前障害物,次パット距離(m),次パット勾配,距離のズレ(m),メモ"
        let rows = records.map { record -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date = formatter.string(from: record.date)
            let hole = record.holeNumber.map { String($0) } ?? ""
            let nextPutt = record.nextPuttingDistance.map { String(format: "%.1f", $0) } ?? ""
            let deviation = record.distanceDeviation.map { String(format: "%.1f", $0) } ?? ""
            return [
                date,
                hole,
                String(format: "%.1f", record.remainingDistance),
                record.club.rawValue,
                record.lieCondition.rawValue,
                record.hazardType.rawValue,
                nextPutt,
                record.nextPuttingSlope.rawValue,
                deviation,
                csvEscape(record.notes)
            ].joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    // MARK: - Helpers

    private static func csvEscape(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") || text.contains("\n") {
            return "\"" + text.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return text
    }
}
