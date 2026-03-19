import SwiftUI

/// 履歴画面 - パッティング・アプローチの全記録を時系列で表示
struct HistoryView: View {
    @EnvironmentObject var viewModel: HistoryViewModel
    @State private var selectedSegment = 0
    @State private var showingExportSheet = false
    @State private var exportText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // セグメントコントロール
                Picker("種別", selection: $selectedSegment) {
                    Text("パッティング").tag(0)
                    Text("アプローチ").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedSegment == 0 {
                    puttingHistoryList
                } else {
                    approachHistoryList
                }
            }
            .navigationTitle("履歴")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        exportText = viewModel.exportCSV()
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView(csvText: exportText)
            }
        }
    }

    // MARK: - Putting List

    private var puttingHistoryList: some View {
        Group {
            if viewModel.puttingRecords.isEmpty {
                emptyView(message: "パッティング記録がありません")
            } else {
                List(viewModel.puttingRecords) { record in
                    PuttingHistoryRow(record: record)
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Approach List

    private var approachHistoryList: some View {
        Group {
            if viewModel.approachRecords.isEmpty {
                emptyView(message: "アプローチ記録がありません")
            } else {
                List(viewModel.approachRecords) { record in
                    ApproachHistoryRow(record: record)
                }
                .listStyle(.plain)
            }
        }
    }

    private func emptyView(message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// MARK: - Putting History Row

struct PuttingHistoryRow: View {
    let record: PuttingRecord

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(record.result == .success ? Color.green : Color.red)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(record.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let hole = record.holeNumber {
                        Text("H\(hole)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                HStack {
                    Text(String(format: "%.1fm", record.initialDistance))
                        .font(.headline)
                    Text(record.lineType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(record.slopeType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(record.result.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(record.result == .success ? .green : .red)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Approach History Row

struct ApproachHistoryRow: View {
    let record: ApproachRecord

    var body: some View {
        HStack(spacing: 12) {
            Text(record.club.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(4)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(record.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let hole = record.holeNumber {
                        Text("H\(hole)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                HStack {
                    Text(String(format: "残り %.1fm", record.remainingDistance))
                        .font(.headline)
                    Text(record.lieCondition.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let nextPutt = record.nextPuttingDistance {
                VStack(alignment: .trailing) {
                    Text(String(format: "%.1fm", nextPutt))
                        .font(.subheadline)
                    Text("次パット")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Export View

struct ExportView: View {
    let csvText: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(csvText)
                    .font(.system(size: 11, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("CSVエクスポート")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: csvText, preview: SharePreview("パッティングメモ.csv"))
                }
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryViewModel())
}
