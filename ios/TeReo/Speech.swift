import AVFoundation

/// Reads a word aloud. Uses a Māori voice if the device has one,
/// otherwise falls back to the closest available voice.
@MainActor
final class Speaker {
    static let shared = Speaker()
    private let synth = AVSpeechSynthesizer()

    func speak(_ word: Word) {
        let utterance = AVSpeechUtterance(string: word.reo.replacingOccurrences(of: "___", with: ""))
        utterance.voice = AVSpeechSynthesisVoice(language: "mi-NZ")
            ?? AVSpeechSynthesisVoice(language: "en-NZ")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        synth.stopSpeaking(at: .immediate)
        synth.speak(utterance)
    }
}
