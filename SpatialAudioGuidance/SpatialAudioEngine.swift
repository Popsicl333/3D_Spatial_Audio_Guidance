//
//  SpatialAudioEngine.swift
//  SpatialAudioGuidance
//
//  Common interface for the spatial renderers so the app can switch between
//  the classic AVAudioEnvironmentNode engine and the PHASE engine at runtime.
//

import Foundation

protocol SpatialAudioEngine: AnyObject {

    var isRunning: Bool { get }
    var isPlaying: Bool { get }

    /// True when the engine itself rotates the listener using system head
    /// tracking. The app then skips its own head-tracking path so head
    /// rotation isn't applied twice.
    var supportsAutomaticHeadTracking: Bool { get }
    func setAutomaticHeadTracking(_ enabled: Bool)

    func start()
    func stopEngine()

    func setRenderingQuality(_ quality: RenderingQuality)

    /// Master output volume, 0...1.
    func setVolume(_ volume: Float)

    /// Wet/dry room-reverb mix for the spatialized source, 0...1.
    func setReverbBlend(_ blend: Float)

    func setElevationCue(_ mode: ElevationCueMode)

    func setSourcePosition(_ p: SpatialPoint)
    func setListener(_ listener: ListenerState)

    /// Per-source gain, 0...1.
    func setSourceVolume(_ volume: Float)

    /// Configure the sound characteristics. Does not start playback.
    func configureSound(type: SoundType, frequency: Float, pulseInterval: Double)

    /// Start playing the currently configured sound. Continuous types loop.
    func play()

    /// Play a single one-shot of the given type (nil = currently configured).
    func playOnce(type: SoundType?)

    func stopPlayback()
}

extension SpatialAudioEngine {
    func playOnce() { playOnce(type: nil) }
}
