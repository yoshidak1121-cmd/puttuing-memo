import Foundation

/// ライの状況
enum LieCondition: String, CaseIterable, Codable {
    case fairway = "フェアウェイ"
    case rough = "ラフ"
    case bunker = "バンカー"
    case greenSide = "グリーン周り"
    case slope = "傾斜地"
}

/// 手前障害物の種類
enum HazardType: String, CaseIterable, Codable {
    case none = "なし"
    case bunker = "バンカー"
    case waterHazard = "池"
    case trees = "木"
    case other = "その他"
}

/// 使用クラブ
enum Club: String, CaseIterable, Codable {
    case pw = "PW"
    case aw = "AW"
    case sw = "SW"
    case lw = "LW"
    case iron9 = "9番アイアン"
    case iron8 = "8番アイアン"
    case iron7 = "7番アイアン"
    case other = "その他"
}

/// アプローチ記録モデル
struct ApproachRecord: Identifiable, Codable {
    var id: UUID
    var date: Date
    var holeNumber: Int?
    var remainingDistance: Double       // 残り距離（m）
    var club: Club
    var lieCondition: LieCondition
    var hazardType: HazardType
    var nextPuttingDistance: Double?    // 次のパッティング距離（m）
    var nextPuttingSlope: SlopeType
    var distanceDeviation: Double?      // 距離のズレ（m）：プラスがオーバー、マイナスがショート
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        holeNumber: Int? = nil,
        remainingDistance: Double = 0.0,
        club: Club = .pw,
        lieCondition: LieCondition = .fairway,
        hazardType: HazardType = .none,
        nextPuttingDistance: Double? = nil,
        nextPuttingSlope: SlopeType = .flat,
        distanceDeviation: Double? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.holeNumber = holeNumber
        self.remainingDistance = remainingDistance
        self.club = club
        self.lieCondition = lieCondition
        self.hazardType = hazardType
        self.nextPuttingDistance = nextPuttingDistance
        self.nextPuttingSlope = nextPuttingSlope
        self.distanceDeviation = distanceDeviation
        self.notes = notes
    }
}
