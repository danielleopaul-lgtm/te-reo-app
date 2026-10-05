import SwiftUI

@main
struct TeReoApp: App {
    @State private var store = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(.teal)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            StudyView()
                .tabItem { Label("Study", systemImage: "rectangle.on.rectangle.angled") }
            StatsView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
        }
    }
}
