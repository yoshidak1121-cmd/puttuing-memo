import SwiftUI

struct ContentView: View {
    @StateObject private var puttingVM = PuttingViewModel()
    @StateObject private var approachVM = ApproachViewModel()
    @StateObject private var historyVM = HistoryViewModel()

    var body: some View {
        TabView {
            PuttingListView()
                .environmentObject(puttingVM)
                .tabItem {
                    Label("パッティング", systemImage: "flag.fill")
                }

            ApproachListView()
                .environmentObject(approachVM)
                .tabItem {
                    Label("アプローチ", systemImage: "location.fill")
                }

            HistoryView()
                .environmentObject(historyVM)
                .tabItem {
                    Label("履歴", systemImage: "clock.fill")
                }

            StatisticsView()
                .environmentObject(puttingVM)
                .environmentObject(approachVM)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
