import SwiftUI

/// アプローチ記録一覧画面
struct ApproachListView: View {
    @EnvironmentObject var viewModel: ApproachViewModel
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    @State private var selectedRecord: ApproachRecord? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 検索バー
                SearchBar(text: $viewModel.searchText, onCommit: viewModel.applyFilters)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // サマリーバー
                HStack(spacing: 12) {
                    StatBadge(label: "平均残距離", value: String(format: "%.1fm", viewModel.averageRemainingDistance))
                    StatBadge(label: "平均次パット", value: String(format: "%.1fm", viewModel.averageNextPuttingDistance))
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
                                ApproachRecordRow(record: record)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { viewModel.filteredRecords[$0].id }
                            ids.forEach { viewModel.deleteRecord(id: $0) }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("アプローチ記録")
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
                ApproachRecordView(mode: .add) { newRecord in
                    viewModel.addRecord(newRecord)
                }
            }
            .sheet(item: $selectedRecord) { record in
                ApproachRecordView(mode: .edit(record)) { updated in
                    viewModel.updateRecord(updated)
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                ApproachFilterView()
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Row

struct ApproachRecordRow: View {
    let record: ApproachRecord

    var body: some View {
        HStack(spacing: 12) {
            // クラブバッジ
            Text(record.club.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(6)
                .frame(width: 52)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let hole = record.holeNumber {
                        Text("ホール\(hole)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(4)
                    }
                    Text(record.lieCondition.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if record.hazardType != .none {
                        Text("⚠️ \(record.hazardType.rawValue)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                HStack {
                    Text("残り \(String(format: "%.1f", record.remainingDistance))m")
                        .font(.headline)
                    if let nextPutt = record.nextPuttingDistance {
                        Spacer()
                        Text("→ \(String(format: "%.1f", nextPutt))m")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                if let deviation = record.distanceDeviation {
                    let sign = deviation >= 0 ? "+" : ""
                    Text("ズレ: \(sign)\(String(format: "%.1f", deviation))m")
                        .font(.caption)
                        .foregroundColor(abs(deviation) < 3 ? .green : .orange)
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

// MARK: - Filter View

struct ApproachFilterView: View {
    @EnvironmentObject var viewModel: ApproachViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("クラブフィルター") {
                    Picker("クラブ", selection: $viewModel.filterClub) {
                        Text("すべて").tag(Club?.none)
                        ForEach(Club.allCases, id: \.self) { club in
                            Text(club.rawValue).tag(Club?.some(club))
                        }
                    }
                    .onChange(of: viewModel.filterClub) { _ in viewModel.applyFilters() }
                }

                Section("ライの状況フィルター") {
                    Picker("ライ", selection: $viewModel.filterLie) {
                        Text("すべて").tag(LieCondition?.none)
                        ForEach(LieCondition.allCases, id: \.self) { lie in
                            Text(lie.rawValue).tag(LieCondition?.some(lie))
                        }
                    }
                    .onChange(of: viewModel.filterLie) { _ in viewModel.applyFilters() }
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
    ApproachListView()
        .environmentObject(ApproachViewModel())
}
