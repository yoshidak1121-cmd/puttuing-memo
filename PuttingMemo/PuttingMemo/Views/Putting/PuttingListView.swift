import SwiftUI

/// パッティング記録一覧画面
struct PuttingListView: View {
    @EnvironmentObject var viewModel: PuttingViewModel
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    @State private var selectedRecord: PuttingRecord? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 検索バー
                SearchBar(text: $viewModel.searchText, onCommit: viewModel.applyFilters)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // サマリーバー
                HStack(spacing: 20) {
                    StatBadge(label: "成功率", value: String(format: "%.0f%%", viewModel.successRate))
                    StatBadge(label: "平均距離", value: String(format: "%.1fm", viewModel.averageInitialDistance))
                    StatBadge(label: "記録数", value: "\(viewModel.records.count)件")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                if viewModel.filteredRecords.isEmpty {
                    Spacer()
                    Text("記録がありません")
                        .foregroundColor(.secondary)
                    Text("右上の＋ボタンから記録を追加できます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredRecords) { record in
                            Button {
                                selectedRecord = record
                            } label: {
                                PuttingRecordRow(record: record)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            // filteredRecords の index を records の index にマッピング
                            let ids = offsets.map { viewModel.filteredRecords[$0].id }
                            ids.forEach { viewModel.deleteRecord(id: $0) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("パッティング記録")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                PuttingRecordView(mode: .add) { newRecord in
                    viewModel.addRecord(newRecord)
                }
            }
            .sheet(item: $selectedRecord) { record in
                PuttingRecordView(mode: .edit(record)) { updated in
                    viewModel.updateRecord(updated)
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                PuttingFilterView()
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Row

struct PuttingRecordRow: View {
    let record: PuttingRecord

    var body: some View {
        HStack(spacing: 12) {
            // 成功/失敗インジケーター
            Circle()
                .fill(record.result == .success ? Color.green : Color.red)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let hole = record.holeNumber {
                        Text("ホール\(hole)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(4)
                    }
                    Text(record.lineType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("・")
                        .foregroundColor(.secondary)
                    Text(record.slopeType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(String(format: "%.1fm", record.initialDistance))
                        .font(.headline)
                    Spacer()
                    Text(record.result.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(record.result == .success ? .green : .red)
                }
                if let remaining = record.remainingDistance, record.result == .failure {
                    Text("残り \(String(format: "%.1f", remaining))m（\(record.remainingStatus.rawValue)）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(record.date, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("ホール番号、ラインなどで検索", text: $text, onCommit: onCommit)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                    onCommit()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Filter View

struct PuttingFilterView: View {
    @EnvironmentObject var viewModel: PuttingViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("結果フィルター") {
                    Picker("結果", selection: $viewModel.filterResult) {
                        Text("すべて").tag(PuttingResult?.none)
                        ForEach(PuttingResult.allCases, id: \.self) { result in
                            Text(result.rawValue).tag(PuttingResult?.some(result))
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.filterResult) { _ in viewModel.applyFilters() }
                }

                Section {
                    Button("フィルターをリセット") {
                        viewModel.clearFilters()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("フィルター")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PuttingListView()
        .environmentObject(PuttingViewModel())
}
