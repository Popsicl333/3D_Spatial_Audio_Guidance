//
//  FollowAnnouncer.swift
//  SpatialAudioGuidance
//
//  Says out loud what the triple-tap gesture just did, with a haptic, so the
//  person wearing the phone knows the tap registered without looking.
//

import Foundation
import AVFoundation
#if os(iOS)
import UIKit
#endif

final class FollowAnnouncer {

    private let synthesizer = AVSpeechSynthesizer()

    func announce(following: Bool) {
        haptic(following: following)
        // Cut off any previous announcement: only the latest state matters.
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: following ? "Following." : "Paused.")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }

    func say(_ text: String, interrupting: Bool = false) {
        if interrupting { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }

    private func haptic(following: Bool) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(following ? .success : .warning)
        #endif
    }
}
