import AVFoundation

extension Word {
    /// File name (without extension) for this word's recording, e.g. "Tēnā koe" -> "tena-koe".
    /// Must match slug() in scripts/audio.py.
    var audioName: String {
        reo.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en"))
            .lowercased()
            .split { !$0.isASCII || !($0.isLetter || $0.isNumber) }
            .joined(separator: "-")
    }
}

/// Plays a word's recording if one is bundled (Audio/<name>.m4a etc.),
/// otherwise reads it aloud with the closest available system voice.
@MainActor
final class Speaker {
    static let shared = Speaker()
    private static let extensions = ["m4a", "mp3", "wav", "aac", "caf"]

    private let synth = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?

    func speak(_ word: Word) {
        synth.stopSpeaking(at: .immediate)
        player?.stop()

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)

        if let url = recordingURL(for: word), let p = try? AVAudioPlayer(contentsOf: url) {
            player = p
            p.play()
            return
        }
        speakWithVoice(word)
    }

    static func hasRecording(_ word: Word) -> Bool {
        shared.recordingURL(for: word) != nil
    }

    private func recordingURL(for word: Word) -> URL? {
        for ext in Self.extensions {
            if let url = Bundle.main.url(forResource: word.audioName, withExtension: ext)
                ?? Bundle.main.url(forResource: word.audioName, withExtension: ext, subdirectory: "Audio") {
                return url
            }
        }
        return nil
    }

    private func speakWithVoice(_ word: Word) {
        let utterance = AVSpeechUtterance(string: word.reo.replacingOccurrences(of: "___", with: ""))
        utterance.voice = AVSpeechSynthesisVoice(language: "mi-NZ")
            ?? AVSpeechSynthesisVoice(language: "en-NZ")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        synth.speak(utterance)
    }
}
