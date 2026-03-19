import Foundation

/// パッティングのラインの特徴
enum LineType: String, CaseIterable, Codable {
    case straight = "ストレート"
    case sliceLine = "スライスライン"
    case hookLine = "フックライン"
    case slightSlice = "わずかにスライス"
    case slightHook = "わずかにフック"
}

/// 勾配の方向
enum SlopeType: String, CaseIterable, Codable {
    case uphill = "上り"
    case downhill = "下り"
    case flat = "フラット"
    case sideSlope = "横傾斜"
}

/// パッティングの結果
enum PuttingResult: String, CaseIterable, Codable {
    case success = "成功"
    case failure = "失敗"
}

/// オーバー/ショートの状態
enum RemainingStatus: String, CaseIterable, Codable {
    case over = "オーバー"
    case short = "ショート"
    case none = "なし"
}

/// パッティング記録モデル
struct PuttingRecord: Identifiable, Codable {
    var id: UUID
    var date: Date
    var holeNumber: Int?
    var initialDistance: Double       // ボールからカップまでの距離（m）
    var lineType: LineType
    var slopeType: SlopeType
    var result: PuttingResult
    var remainingDistance: Double?    // 結果：残り距離（m）
    var remainingStatus: RemainingStatus
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        holeNumber: Int? = nil,
        initialDistance: Double = 0.0,
        lineType: LineType = .straight,
        slopeType: SlopeType = .flat,
        result: PuttingResult = .failure,
        remainingDistance: Double? = nil,
        remainingStatus: RemainingStatus = .none,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.holeNumber = holeNumber
        self.initialDistance = initialDistance
        self.lineType = lineType
        self.slopeType = slopeType
        self.result = result
        self.remainingDistance = remainingDistance
        self.remainingStatus = remainingStatus
        self.notes = notes
    }
}
