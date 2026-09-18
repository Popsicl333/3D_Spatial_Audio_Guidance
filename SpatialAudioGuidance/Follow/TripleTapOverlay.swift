//
//  TripleTapOverlay.swift
//  SpatialAudioGuidance
//
//  Triple-tap anywhere on the camera view to start following, triple-tap
//  again to pause, plus a border showing which state it is in.
//

import SwiftUI

/// Wraps the camera view with the start/pause gesture and a state border.
struct TripleTapOverlay<Content: View>: View {

    let isFollowing: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var tapTimestamps: [TimeInterval] = []

    private var borderColor: Color { isFollowing ? .green : .orange }

    var body: some View {
        ZStack {
            content()

            // A transparent layer above the camera preview owns the gesture,
            // so the preview's own gesture recognisers cannot swallow taps.
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    let now = Date().timeIntervalSinceReferenceDate
                    tapTimestamps.append(now)
                    tapTimestamps = tapTimestamps.filter { now - $0 <= TapTiming.window }
                    if tapTimestamps.count >= 3 {
                        tapTimestamps.removeAll()
                        onToggle()
                    }
                }

            // Border only, never a dimming layer, so the camera image stays
            // visible while aiming.
            Rectangle()
                .strokeBorder(borderColor, lineWidth: 6)
                .allowsHitTesting(false)
        }
    }
}
