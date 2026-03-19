import SwiftUI
import Charts

/// 統計・分析画面
struct StatisticsView: View {
    @EnvironmentObject var puttingVM: PuttingViewModel
    @EnvironmentObject var approachVM: ApproachViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // パッティング統計セクション
                    puttingStatisticsSection

                    // アプローチ統計セクション
                    approachStatisticsSection
                }
                .padding()
            }
            .navigationTitle("統計・分析")
        }
    }

    // MARK: - Putting Statistics

    private var puttingStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("パッティング統計")
                .font(.title2)
                .fontWeight(.bold)

            // KPIカード
            HStack(spacing: 12) {
                KPICard(
                    title: "総合成功率",
                    value: String(format: "%.0f%%", puttingVM.successRate),
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                KPICard(
                    title: "平均距離",
                    value: String(format: "%.1fm", puttingVM.averageInitialDistance),
                    icon: "ruler.fill",
                    color: .blue
                )
                KPICard(
                    title: "記録数",
                    value: "\(puttingVM.records.count)",
                    icon: "list.bullet",
                    color: .orange
                )
            }

            // 距離別成功率グラフ
            if !puttingVM.successRateByDistance.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("距離別成功率")
                        .font(.headline)

                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(puttingVM.successRateByDistance, id: \.range) { item in
                                BarMark(
                                    x: .value("距離", item.range),
                                    y: .value("成功率", item.rate)
                                )
                                .foregroundStyle(Color.green.gradient)
                                .annotation(position: .top) {
                                    Text(String(format: "%.0f%%", item.rate))
                                        .font(.caption2)
                                }
                            }
                        }
                        .chartYScale(domain: 0...100)
                        .frame(height: 200)
                        .padding(.vertical)
                    } else {
                        SuccessRateBarChart(data: puttingVM.successRateByDistance)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            // ラインタイプ別成功率
            if !puttingVM.records.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ラインタイプ別成功率")
                        .font(.headline)

                    ForEach(LineType.allCases, id: \.self) { lineType in
                        let typeRecords = puttingVM.records.filter { $0.lineType == lineType }
                        if !typeRecords.isEmpty {
                            let rate = Double(typeRecords.filter { $0.result == .success }.count) /
                                       Double(typeRecords.count) * 100
                            LineTypeRateRow(lineType: lineType, rate: rate, count: typeRecords.count)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Approach Statistics

    private var approachStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("アプローチ統計")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                KPICard(
                    title: "平均残距離",
                    value: String(format: "%.1fm", approachVM.averageRemainingDistance),
                    icon: "location.fill",
                    color: .purple
                )
                KPICard(
                    title: "平均次パット",
                    value: String(format: "%.1fm", approachVM.averageNextPuttingDistance),
                    icon: "flag.fill",
                    color: .teal
                )
                KPICard(
                    title: "記録数",
                    value: "\(approachVM.records.count)",
                    icon: "list.bullet",
                    color: .orange
                )
            }

            // クラブ使用状況
            if !approachVM.clubUsageStats.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("クラブ使用状況")
                        .font(.headline)

                    ForEach(approachVM.clubUsageStats, id: \.club) { item in
                        ClubUsageRow(club: item.club, count: item.count, total: approachVM.records.count)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Success Rate Bar Chart (iOS 15 fallback)

struct SuccessRateBarChart: View {
    let data: [(range: String, rate: Double)]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data, id: \.range) { item in
                VStack(spacing: 4) {
                    Text(String(format: "%.0f%%", item.rate))
                        .font(.caption2)
                    Rectangle()
                        .fill(Color.green.opacity(0.7))
                        .frame(height: max(CGFloat(item.rate) * 1.5, 4))
                    Text(item.range)
                        .font(.caption2)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 160)
    }
}

// MARK: - Line Type Rate Row

struct LineTypeRateRow: View {
    let lineType: LineType
    let rate: Double
    let count: Int

    var body: some View {
        HStack {
            Text(lineType.rawValue)
                .font(.subheadline)
                .frame(width: 120, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    Rectangle()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: geometry.size.width * CGFloat(rate / 100))
                        .cornerRadius(4)
                }
            }
            .frame(height: 16)
            Text(String(format: "%.0f%%", rate))
                .font(.caption)
                .frame(width: 40, alignment: .trailing)
            Text("(\(count)件)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

// MARK: - Club Usage Row

struct ClubUsageRow: View {
    let club: Club
    let count: Int
    let total: Int

    var ratio: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }

    var body: some View {
        HStack {
            Text(club.rawValue)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                    Rectangle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: geometry.size.width * CGFloat(ratio))
                        .cornerRadius(4)
                }
            }
            .frame(height: 16)
            Text("\(count)回")
                .font(.caption)
                .frame(width: 40, alignment: .trailing)
            Text(String(format: "%.0f%%", ratio * 100))
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(PuttingViewModel())
        .environmentObject(ApproachViewModel())
}
