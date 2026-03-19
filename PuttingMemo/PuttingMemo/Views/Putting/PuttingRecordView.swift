import SwiftUI

/// パッティング記録の追加・編集画面
struct PuttingRecordView: View {
    enum Mode {
        case add
        case edit(PuttingRecord)
    }

    let mode: Mode
    let onSave: (PuttingRecord) -> Void

    @Environment(\.dismiss) var dismiss

    // Form state
    @State private var holeNumberText: String = ""
    @State private var initialDistanceText: String = ""
    @State private var lineType: LineType = .straight
    @State private var slopeType: SlopeType = .flat
    @State private var result: PuttingResult = .failure
    @State private var remainingDistanceText: String = ""
    @State private var remainingStatus: RemainingStatus = .none
    @State private var notes: String = ""
    @State private var date: Date = Date()

    @State private var showValidationError = false

    init(mode: Mode, onSave: @escaping (PuttingRecord) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let record) = mode {
            _holeNumberText = State(initialValue: record.holeNumber.map { String($0) } ?? "")
            _initialDistanceText = State(initialValue: String(format: "%.1f", record.initialDistance))
            _lineType = State(initialValue: record.lineType)
            _slopeType = State(initialValue: record.slopeType)
            _result = State(initialValue: record.result)
            _remainingDistanceText = State(initialValue: record.remainingDistance.map { String(format: "%.1f", $0) } ?? "")
            _remainingStatus = State(initialValue: record.remainingStatus)
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
                        Text("初期距離 (m)")
                            .fontWeight(.semibold)
                        Spacer()
                        TextField("例: 3.5", text: $initialDistanceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("ラインの特徴") {
                    Picker("ライン", selection: $lineType) {
                        ForEach(LineType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section("勾配") {
                    Picker("勾配", selection: $slopeType) {
                        ForEach(SlopeType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("成果") {
                    Picker("結果", selection: $result) {
                        ForEach(PuttingResult.allCases, id: \.self) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: result) { newValue in
                        if newValue == .success {
                            remainingDistanceText = ""
                            remainingStatus = .none
                        }
                    }
                }

                if result == .failure {
                    Section("失敗の詳細") {
                        HStack {
                            Text("残り距離 (m)")
                            Spacer()
                            TextField("例: 0.5", text: $remainingDistanceText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }

                        Picker("状態", selection: $remainingStatus) {
                            ForEach(RemainingStatus.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section("メモ") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                if showValidationError {
                    Section {
                        Text("初期距離を入力してください")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isAdding ? "パッティング記録追加" : "パッティング記録編集")
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
        guard let initialDistance = Double(initialDistanceText), initialDistance > 0 else {
            showValidationError = true
            return
        }

        let holeNumber = Int(holeNumberText)
        let remainingDistance = Double(remainingDistanceText)

        let record: PuttingRecord
        if case .edit(let existing) = mode {
            record = PuttingRecord(
                id: existing.id,
                date: date,
                holeNumber: holeNumber,
                initialDistance: initialDistance,
                lineType: lineType,
                slopeType: slopeType,
                result: result,
                remainingDistance: result == .failure ? remainingDistance : nil,
                remainingStatus: result == .failure ? remainingStatus : .none,
                notes: notes
            )
        } else {
            record = PuttingRecord(
                date: date,
                holeNumber: holeNumber,
                initialDistance: initialDistance,
                lineType: lineType,
                slopeType: slopeType,
                result: result,
                remainingDistance: result == .failure ? remainingDistance : nil,
                remainingStatus: result == .failure ? remainingStatus : .none,
                notes: notes
            )
        }

        onSave(record)
        dismiss()
    }
}

#Preview {
    PuttingRecordView(mode: .add) { _ in }
}
