import SwiftUI

struct StatsView: View {
    @Environment(ProgressStore.self) private var store
    @State private var confirmReset = false

    private var learned: Int { vocabulary.filter(store.isLearned).count }
    private var started: Int { vocabulary.filter(store.started).count }
    private var due: Int { vocabulary.filter { store.isDue($0) }.count }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        stat(learned, "words learned")
                        stat(started, "words started")
                        stat(due, "due now")
                        stat(store.streak, "day streak")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("By topic") {
                    ForEach(topics, id: \.self) { topic in
                        let words = vocabulary.filter { $0.topic == topic }
                        let done = words.filter(store.isLearned).count
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(topic)
                                Spacer()
                                Text("\(done)/\(words.count)").foregroundStyle(.secondary)
                            }
                            ProgressView(value: Double(done), total: Double(words.count))
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section {
                    Button("Reset progress", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("Progress")
            .confirmationDialog("Erase all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Erase", role: .destructive) { store.reset() }
            }
        }
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading) {
            Text("\(value)").font(.title.bold())
            Text(label).font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 14))
    }
}
