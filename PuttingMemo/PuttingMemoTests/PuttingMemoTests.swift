import XCTest
@testable import PuttingMemo

final class PuttingRecordTests: XCTestCase {

    // MARK: - PuttingRecord Tests

    func testPuttingRecordDefaultInitialization() {
        let record = PuttingRecord()
        XCTAssertNotNil(record.id)
        XCTAssertNil(record.holeNumber)
        XCTAssertEqual(record.initialDistance, 0.0)
        XCTAssertEqual(record.lineType, .straight)
        XCTAssertEqual(record.slopeType, .flat)
        XCTAssertEqual(record.result, .failure)
        XCTAssertNil(record.remainingDistance)
        XCTAssertEqual(record.remainingStatus, .none)
        XCTAssertEqual(record.notes, "")
    }

    func testPuttingRecordCustomInitialization() {
        let record = PuttingRecord(
            holeNumber: 5,
            initialDistance: 3.5,
            lineType: .sliceLine,
            slopeType: .uphill,
            result: .success,
            remainingDistance: nil,
            remainingStatus: .none,
            notes: "テストメモ"
        )
        XCTAssertEqual(record.holeNumber, 5)
        XCTAssertEqual(record.initialDistance, 3.5)
        XCTAssertEqual(record.lineType, .sliceLine)
        XCTAssertEqual(record.slopeType, .uphill)
        XCTAssertEqual(record.result, .success)
        XCTAssertNil(record.remainingDistance)
        XCTAssertEqual(record.notes, "テストメモ")
    }

    func testPuttingRecordCodable() throws {
        let record = PuttingRecord(
            holeNumber: 3,
            initialDistance: 2.0,
            lineType: .hookLine,
            slopeType: .downhill,
            result: .failure,
            remainingDistance: 0.5,
            remainingStatus: .short,
            notes: ""
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(record)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PuttingRecord.self, from: data)

        XCTAssertEqual(decoded.id, record.id)
        XCTAssertEqual(decoded.holeNumber, 3)
        XCTAssertEqual(decoded.initialDistance, 2.0)
        XCTAssertEqual(decoded.lineType, .hookLine)
        XCTAssertEqual(decoded.slopeType, .downhill)
        XCTAssertEqual(decoded.result, .failure)
        XCTAssertEqual(decoded.remainingDistance, 0.5)
        XCTAssertEqual(decoded.remainingStatus, .short)
    }

    // MARK: - ApproachRecord Tests

    func testApproachRecordDefaultInitialization() {
        let record = ApproachRecord()
        XCTAssertNotNil(record.id)
        XCTAssertNil(record.holeNumber)
        XCTAssertEqual(record.remainingDistance, 0.0)
        XCTAssertEqual(record.club, .pw)
        XCTAssertEqual(record.lieCondition, .fairway)
        XCTAssertEqual(record.hazardType, .none)
        XCTAssertNil(record.nextPuttingDistance)
        XCTAssertEqual(record.nextPuttingSlope, .flat)
        XCTAssertNil(record.distanceDeviation)
        XCTAssertEqual(record.notes, "")
    }

    func testApproachRecordCustomInitialization() {
        let record = ApproachRecord(
            holeNumber: 7,
            remainingDistance: 50.0,
            club: .sw,
            lieCondition: .bunker,
            hazardType: .bunker,
            nextPuttingDistance: 3.0,
            nextPuttingSlope: .uphill,
            distanceDeviation: -2.0,
            notes: "バンカーから"
        )
        XCTAssertEqual(record.holeNumber, 7)
        XCTAssertEqual(record.remainingDistance, 50.0)
        XCTAssertEqual(record.club, .sw)
        XCTAssertEqual(record.lieCondition, .bunker)
        XCTAssertEqual(record.hazardType, .bunker)
        XCTAssertEqual(record.nextPuttingDistance, 3.0)
        XCTAssertEqual(record.nextPuttingSlope, .uphill)
        XCTAssertEqual(record.distanceDeviation, -2.0)
        XCTAssertEqual(record.notes, "バンカーから")
    }

    func testApproachRecordCodable() throws {
        let record = ApproachRecord(
            holeNumber: 2,
            remainingDistance: 30.0,
            club: .aw,
            lieCondition: .rough,
            hazardType: .waterHazard,
            nextPuttingDistance: 5.0,
            nextPuttingSlope: .downhill,
            distanceDeviation: 1.5,
            notes: ""
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(record)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ApproachRecord.self, from: data)

        XCTAssertEqual(decoded.id, record.id)
        XCTAssertEqual(decoded.holeNumber, 2)
        XCTAssertEqual(decoded.remainingDistance, 30.0)
        XCTAssertEqual(decoded.club, .aw)
        XCTAssertEqual(decoded.lieCondition, .rough)
        XCTAssertEqual(decoded.hazardType, .waterHazard)
        XCTAssertEqual(decoded.nextPuttingDistance, 5.0)
        XCTAssertEqual(decoded.distanceDeviation, 1.5)
    }
}

// MARK: - PuttingViewModel Tests

final class PuttingViewModelTests: XCTestCase {

    var viewModel: PuttingViewModel!
    var testStore: DataStore!

    override func setUp() {
        super.setUp()
        // 既存データをクリアしてから初期化
        DataStore.shared.deleteAllPuttingRecords()
        viewModel = PuttingViewModel()
    }

    override func tearDown() {
        DataStore.shared.deleteAllPuttingRecords()
        super.tearDown()
    }

    func testAddRecord() {
        let record = PuttingRecord(initialDistance: 3.0)
        viewModel.addRecord(record)
        XCTAssertEqual(viewModel.records.count, 1)
        XCTAssertEqual(viewModel.records.first?.initialDistance, 3.0)
    }

    func testDeleteRecord() {
        let record = PuttingRecord(initialDistance: 5.0)
        viewModel.addRecord(record)
        XCTAssertEqual(viewModel.records.count, 1)
        viewModel.deleteRecord(id: record.id)
        XCTAssertEqual(viewModel.records.count, 0)
    }

    func testUpdateRecord() {
        var record = PuttingRecord(initialDistance: 2.0)
        viewModel.addRecord(record)
        record.initialDistance = 4.0
        viewModel.updateRecord(record)
        XCTAssertEqual(viewModel.records.first?.initialDistance, 4.0)
    }

    func testSuccessRate() {
        viewModel.addRecord(PuttingRecord(result: .success))
        viewModel.addRecord(PuttingRecord(result: .success))
        viewModel.addRecord(PuttingRecord(result: .failure))
        viewModel.addRecord(PuttingRecord(result: .failure))
        XCTAssertEqual(viewModel.successRate, 50.0, accuracy: 0.001)
    }

    func testSuccessRateEmpty() {
        XCTAssertEqual(viewModel.successRate, 0.0)
    }

    func testAverageInitialDistance() {
        viewModel.addRecord(PuttingRecord(initialDistance: 2.0))
        viewModel.addRecord(PuttingRecord(initialDistance: 4.0))
        XCTAssertEqual(viewModel.averageInitialDistance, 3.0, accuracy: 0.001)
    }

    func testFilterByResult() {
        viewModel.addRecord(PuttingRecord(result: .success))
        viewModel.addRecord(PuttingRecord(result: .failure))
        viewModel.filterResult = .success
        viewModel.applyFilters()
        XCTAssertEqual(viewModel.filteredRecords.count, 1)
        XCTAssertEqual(viewModel.filteredRecords.first?.result, .success)
    }

    func testClearFilters() {
        viewModel.addRecord(PuttingRecord(result: .success))
        viewModel.addRecord(PuttingRecord(result: .failure))
        viewModel.filterResult = .success
        viewModel.applyFilters()
        viewModel.clearFilters()
        XCTAssertEqual(viewModel.filteredRecords.count, 2)
        XCTAssertNil(viewModel.filterResult)
    }
}

// MARK: - ApproachViewModel Tests

final class ApproachViewModelTests: XCTestCase {

    var viewModel: ApproachViewModel!

    override func setUp() {
        super.setUp()
        DataStore.shared.deleteAllApproachRecords()
        viewModel = ApproachViewModel()
    }

    override func tearDown() {
        DataStore.shared.deleteAllApproachRecords()
        super.tearDown()
    }

    func testAddRecord() {
        let record = ApproachRecord(remainingDistance: 40.0)
        viewModel.addRecord(record)
        XCTAssertEqual(viewModel.records.count, 1)
    }

    func testDeleteRecord() {
        let record = ApproachRecord(remainingDistance: 30.0)
        viewModel.addRecord(record)
        viewModel.deleteRecord(id: record.id)
        XCTAssertEqual(viewModel.records.count, 0)
    }

    func testAverageRemainingDistance() {
        viewModel.addRecord(ApproachRecord(remainingDistance: 30.0))
        viewModel.addRecord(ApproachRecord(remainingDistance: 50.0))
        XCTAssertEqual(viewModel.averageRemainingDistance, 40.0, accuracy: 0.001)
    }

    func testAverageNextPuttingDistance() {
        var r1 = ApproachRecord()
        r1.nextPuttingDistance = 2.0
        var r2 = ApproachRecord()
        r2.nextPuttingDistance = 4.0
        viewModel.addRecord(r1)
        viewModel.addRecord(r2)
        XCTAssertEqual(viewModel.averageNextPuttingDistance, 3.0, accuracy: 0.001)
    }

    func testFilterByClub() {
        viewModel.addRecord(ApproachRecord(club: .pw))
        viewModel.addRecord(ApproachRecord(club: .sw))
        viewModel.filterClub = .pw
        viewModel.applyFilters()
        XCTAssertEqual(viewModel.filteredRecords.count, 1)
        XCTAssertEqual(viewModel.filteredRecords.first?.club, .pw)
    }
}

// MARK: - CSVExporter Tests

final class CSVExporterTests: XCTestCase {

    func testExportPuttingRecordsHeader() {
        let csv = CSVExporter.exportPuttingRecords([])
        let lines = csv.components(separatedBy: "\n")
        XCTAssertTrue(lines[0].contains("日付"))
        XCTAssertTrue(lines[0].contains("ホール番号"))
        XCTAssertTrue(lines[0].contains("初期距離"))
        XCTAssertTrue(lines[0].contains("結果"))
    }

    func testExportPuttingRecordsData() {
        let record = PuttingRecord(
            holeNumber: 1,
            initialDistance: 3.5,
            lineType: .straight,
            slopeType: .flat,
            result: .success
        )
        let csv = CSVExporter.exportPuttingRecords([record])
        let lines = csv.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 2) // header + 1 row
        XCTAssertTrue(lines[1].contains("1"))
        XCTAssertTrue(lines[1].contains("3.5"))
        XCTAssertTrue(lines[1].contains("成功"))
    }

    func testExportApproachRecordsHeader() {
        let csv = CSVExporter.exportApproachRecords([])
        let lines = csv.components(separatedBy: "\n")
        XCTAssertTrue(lines[0].contains("残り距離"))
        XCTAssertTrue(lines[0].contains("使用クラブ"))
        XCTAssertTrue(lines[0].contains("ライの状況"))
    }

    func testExportApproachRecordsData() {
        let record = ApproachRecord(
            holeNumber: 2,
            remainingDistance: 50.0,
            club: .sw,
            lieCondition: .bunker,
            hazardType: .none
        )
        let csv = CSVExporter.exportApproachRecords([record])
        let lines = csv.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[1].contains("50.0"))
        XCTAssertTrue(lines[1].contains("SW"))
        XCTAssertTrue(lines[1].contains("バンカー"))
    }

    func testCSVEscapesCommas() {
        let record = PuttingRecord(notes: "カンマ,含む,メモ")
        let csv = CSVExporter.exportPuttingRecords([record])
        let lines = csv.components(separatedBy: "\n")
        XCTAssertTrue(lines[1].contains("\"カンマ,含む,メモ\""))
    }
}
