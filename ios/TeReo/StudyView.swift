import SwiftUI

struct StudyView: View {
    @Environment(ProgressStore.self) private var store

    enum Mode: String, CaseIterable { case flashcards = "Flashcards", quiz = "Quiz" }

    @State private var mode: Mode = .flashcards
    @State private var topic = "All"
    @State private var deck: [Word] = []
    @State private var current: Word?
    @State private var flipped = false
    @State private var practiceAnyway = false
    @State private var right = 0
    @State private var seen = 0
    @State private var choices: [Word] = []
    @State private var picked: Word?

    private var pool: [Word] {
        vocabulary.filter { topic == "All" || $0.topic == topic }
    }
    private var dueCount: Int { pool.filter { store.isDue($0) }.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("\(dueCount) due now").foregroundStyle(.secondary)
                    Spacer()
                    if seen > 0 { Text("\(right)/\(seen)").foregroundStyle(.secondary) }
                }
                .font(.subheadline)

                if let word = current {
                    if mode == .flashcards { flashcard(word) } else { quiz(word) }
                } else {
                    caughtUp
                }
                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
            .navigationTitle("Te Reo Māori")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Topic", selection: $topic) {
                            Text("All").tag("All")
                            ForEach(topics, id: \.self) { Text($0).tag($0) }
                        }
                    } label: {
                        Label(topic, systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear { if current == nil { next() } }
            .onChange(of: mode) { _, _ in next() }
            .onChange(of: topic) { _, _ in
                practiceAnyway = false
                deck = []
                next()
            }
        }
    }

    // MARK: Flashcards

    private func flashcard(_ word: Word) -> some View {
        VStack(spacing: 16) {
            Button {
                withAnimation(.snappy) { flipped.toggle() }
            } label: {
                Text(flipped ? word.en : word.reo)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(flipped ? Color.accentColor : .primary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 240)
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Flips the card")

            Text("Tap the card to flip").font(.footnote).foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button { Speaker.shared.speak(word) } label: {
                    Image(systemName: "speaker.wave.2.fill").frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Hear it")

                Button { grade(word, correct: false) } label: {
                    Text("Still learning").frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)

                Button { grade(word, correct: true) } label: {
                    Text("Got it").frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: Quiz

    private func quiz(_ word: Word) -> some View {
        VStack(spacing: 14) {
            Text(word.reo)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Button { Speaker.shared.speak(word) } label: {
                Image(systemName: "speaker.wave.2.fill")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Hear it")

            ForEach(choices) { option in
                Button { answer(option, for: word) } label: {
                    Text(option.en)
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.bordered)
                .tint(tint(for: option, word: word))
                .disabled(picked != nil)
            }

            if let picked {
                Text(picked == word ? "Kei te tika! (Correct)" : "Not quite")
                    .font(.headline)
                Button("Next") { next() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func tint(for option: Word, word: Word) -> Color? {
        guard let picked else { return nil }
        if option == word { return .green }
        return option == picked ? .red : .gray
    }

    // MARK: Done state

    private var caughtUp: some View {
        VStack(spacing: 16) {
            Text("Kua oti!").font(.largeTitle.bold())
            Text("You're all caught up for now.").foregroundStyle(.secondary)
            Button("Practise anyway") {
                practiceAnyway = true
                deck = []
                next()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
    }

    // MARK: Logic

    private func loadDeck() {
        let candidates = pool.filter { practiceAnyway || store.isDue($0) }
        // Weakest words (lowest box) come up first: deck is popped from the end.
        deck = candidates.shuffled().sorted { store.box($0) > store.box($1) }
    }

    private func next() {
        if deck.isEmpty { loadDeck() }
        flipped = false
        picked = nil
        current = deck.popLast()
        if let word = current, mode == .quiz { buildChoices(for: word) }
    }

    private func buildChoices(for word: Word) {
        let others = vocabulary.filter { $0.en != word.en }
        let same = others.filter { $0.topic == word.topic }.shuffled()
        let rest = others.filter { $0.topic != word.topic }.shuffled()
        choices = (Array((same + rest).prefix(3)) + [word]).shuffled()
    }

    private func grade(_ word: Word, correct: Bool) {
        store.record(word, correct: correct)
        seen += 1
        if correct { right += 1 }
        next()
    }

    private func answer(_ option: Word, for word: Word) {
        picked = option
        store.record(word, correct: option == word)
        seen += 1
        if option == word { right += 1 }
    }
}
