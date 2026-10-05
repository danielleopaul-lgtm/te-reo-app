import Foundation
import Observation

struct WordProgress: Codable {
    var box: Int = 0
    var due: Date = .distantPast
}

private struct Saved: Codable {
    var progress: [String: WordProgress] = [:]
    var days: [String] = []
}

/// Leitner-box spaced repetition, persisted to UserDefaults.
@Observable
final class ProgressStore {
    static let learnedBox = 3
    private static let intervals: [TimeInterval] = [0, 1, 3, 7, 21].map { $0 * 86_400 }
    private static let key = "te-reo-app/v1"

    private var saved: Saved

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let decoded = try? JSONDecoder().decode(Saved.self, from: data) {
            saved = decoded
        } else {
            saved = Saved()
        }
    }

    func box(_ word: Word) -> Int { saved.progress[word.reo]?.box ?? 0 }
    func started(_ word: Word) -> Bool { saved.progress[word.reo] != nil }
    func isLearned(_ word: Word) -> Bool { box(word) >= Self.learnedBox }
    func isDue(_ word: Word, now: Date = .now) -> Bool {
        (saved.progress[word.reo]?.due ?? .distantPast) <= now
    }

    func record(_ word: Word, correct: Bool) {
        var p = saved.progress[word.reo] ?? WordProgress()
        p.box = correct ? min(p.box + 1, Self.intervals.count - 1) : 0
        p.due = Date.now.addingTimeInterval(Self.intervals[p.box])
        saved.progress[word.reo] = p
        let day = Self.dayKey(.now)
        if !saved.days.contains(day) { saved.days.append(day) }
        persist()
    }

    var streak: Int {
        let cal = Calendar.current
        let set = Set(saved.days)
        var day = Date.now
        if !set.contains(Self.dayKey(day)) { day = cal.date(byAdding: .day, value: -1, to: day)! }
        var n = 0
        while set.contains(Self.dayKey(day)) {
            n += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return n
    }

    func reset() {
        saved = Saved()
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    private static func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(c.year!)-\(c.month!)-\(c.day!)"
    }
}
