import SwiftUI

/// アプローチ記録の追加・編集画面
struct ApproachRecordView: View {
    enum Mode {
        case add
        case edit(ApproachRecord)
    }

    let mode: Mode
    let onSave: (ApproachRecord) -> Void

    @Environment(\.dismiss) var dismiss

    // Form state
    @State private var holeNumberText: String = ""
    @State private var remainingDistanceText: String = ""
    @State private var club: Club = .pw
    @State private var lieCondition: LieCondition = .fairway
    @State private var hazardType: HazardType = .none
    @State private var nextPuttingDistanceText: String = ""
    @State private var nextPuttingSlope: SlopeType = .flat
    @State private var distanceDeviationText: String = ""
    @State private var notes: String = ""
    @State private var date: Date = Date()

    @State private var showValidationError = false

    init(mode: Mode, onSave: @escaping (ApproachRecord) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let record) = mode {
            _holeNumberText = State(initialValue: record.holeNumber.map { String($0) } ?? "")
            _remainingDistanceText = State(initialValue: String(format: "%.1f", record.remainingDistance))
            _club = State(initialValue: record.club)
            _lieCondition = State(initialValue: record.lieCondition)
            _hazardType = State(initialValue: record.hazardType)
            _nextPuttingDistanceText = State(initialValue: record.nextPuttingDistance.map { String(format: "%.1f", $0) } ?? "")
            _nextPuttingSlope = State(initialValue: record.nextPuttingSlope)
            _distanceDeviationText = State(initialValue: record.distanceDeviation.map { String(format: "%.1f", $0) } ?? "")
            _notes = State(initialValue: record.notes)
            _date = State(initialValue: record.date)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    HStack {
                        Text("日付")
                        Spacer()
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }

                    HStack {
                        Text("ホール番号")
                        Spacer()
                        TextField("例: 1", text: $holeNumberText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("残り距離 (m)")
                            .fontWeight(.semibold)
                        Spacer()
                        TextField("例: 50.0", text: $remainingDistanceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("使用クラブ") {
                    Picker("クラブ", selection: $club) {
                        ForEach(Club.allCases, id: \.self) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section("ライの状況") {
                    Picker("ライ", selection: $lieCondition) {
                        ForEach(LieCondition.allCases, id: \.self) { lie in
                            Text(lie.rawValue).tag(lie)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("手前障害物") {
                    Picker("障害物", selection: $hazardType) {
                        ForEach(HazardType.allCases, id: \.self) { h in
                            Text(h.rawValue).tag(h)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("結果") {
                    HStack {
                        Text("次パット距離 (m)")
                        Spacer()
                        TextField("例: 2.5", text: $nextPuttingDistanceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("次パット勾配")
                        Spacer()
                        Picker("", selection: $nextPuttingSlope) {
                            ForEach(SlopeType.allCases, id: \.self) { slope in
                                Text(slope.rawValue).tag(slope)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    HStack {
                        Text("距離のズレ (m)")
                        Text("+:オーバー / -:ショート")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("例: +2.0", text: $distanceDeviationText)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("メモ") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                if showValidationError {
                    Section {
                        Text("残り距離を入力してください")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isAdding ? "アプローチ記録追加" : "アプローチ記録編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var isAdding: Bool {
        if case .add = mode { return true }
        return false
    }

    private func save() {
        guard let remainingDistance = Double(remainingDistanceText), remainingDistance > 0 else {
            showValidationError = true
            return
        }

        let holeNumber = Int(holeNumberText)
        let nextPuttingDistance = Double(nextPuttingDistanceText)
        let distanceDeviation = Double(distanceDeviationText)

        let record: ApproachRecord
        if case .edit(let existing) = mode {
            record = ApproachRecord(
                id: existing.id,
                date: date,
                holeNumber: holeNumber,
                remainingDistance: remainingDistance,
                club: club,
                lieCondition: lieCondition,
                hazardType: hazardType,
                nextPuttingDistance: nextPuttingDistance,
                nextPuttingSlope: nextPuttingSlope,
                distanceDeviation: distanceDeviation,
                notes: notes
            )
        } else {
            record = ApproachRecord(
                date: date,
                holeNumber: holeNumber,
                remainingDistance: remainingDistance,
                club: club,
                lieCondition: lieCondition,
                hazardType: hazardType,
                nextPuttingDistance: nextPuttingDistance,
                nextPuttingSlope: nextPuttingSlope,
                distanceDeviation: distanceDeviation,
                notes: notes
            )
        }

        onSave(record)
        dismiss()
    }
}

#Preview {
    ApproachRecordView(mode: .add) { _ in }
}
