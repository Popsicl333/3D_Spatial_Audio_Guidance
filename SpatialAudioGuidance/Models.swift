//
//  Models.swift
//  SpatialAudioGuidance
//
//  Codable data model.
//

import Foundation

// MARK: - Geometry

struct SpatialPoint: Codable, Equatable {
    var x: Float
    var y: Float
    var z: Float

    static let origin = SpatialPoint(x: 0, y: 0, z: 0)
}

// MARK: - Listener / Source

struct ListenerState: Codable, Equatable {
    var position: SpatialPoint = .origin
    var yaw: Float = 0     // degrees, + turns head to the right
    var pitch: Float = 0   // degrees, + tilts up
    var roll: Float = 0    // degrees

    static let `default` = ListenerState()
}

struct SoundSourceState: Codable, Equatable {
    var position: SpatialPoint
    var volume: Float
    var soundType: SoundType
}

// MARK: - Enums

enum SoundType: String, Codable, CaseIterable, Identifiable {
    case beep
    case pulseBeep
    case pulseNoise
    case whiteNoiseBurst
    case continuousWhiteNoise
    case sineTone

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beep:                 return "Beep"
        case .pulseBeep:            return "Pulse Beep"
        case .pulseNoise:           return "Noise Pulses"
        case .whiteNoiseBurst:      return "Noise Burst"
        case .continuousWhiteNoise: return "Continuous Noise"
        case .sineTone:             return "Sine Tone"
        }
    }

    /// Whether the sound plays continuously (looped) vs. a single one-shot.
    var isContinuous: Bool {
        switch self {
        case .beep, .whiteNoiseBurst:                                   return false
        case .pulseBeep, .pulseNoise, .continuousWhiteNoise, .sineTone: return true
        }
    }
}

enum MovingTarget: String, Codable, CaseIterable, Identifiable {
    case source
    case listener
    case both

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum EasingType: String, Codable, CaseIterable, Identifiable {
    case linear
    case easeIn
    case easeOut
    case easeInOut

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .linear:    return "Linear"
        case .easeIn:    return "Ease In"
        case .easeOut:   return "Ease Out"
        case .easeInOut: return "Ease In-Out"
        }
    }
}

enum EditingTarget: String, CaseIterable, Identifiable {
    case source
    case listener
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum OrientationMode: String, CaseIterable, Identifiable {
    case fixed
    case manual
    case airPods

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .fixed:   return "Fixed"
        case .manual:  return "Manual Sliders"
        case .airPods: return "AirPods Head Tracking"
        }
    }
}

enum RenderingQuality: String, CaseIterable, Identifiable {
    case hrtf
    case hrtfHQ

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .hrtf:   return "HRTF"
        case .hrtfHQ: return "HRTF HQ"
        }
    }
}

/// Extra cues that make up/down easier to hear.
enum ElevationCueMode: String, CaseIterable, Identifiable {
    case off
    case spectral
    case pitch

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .off:      return "Off"
        case .spectral: return "Spectral"
        case .pitch:    return "Pitch Map"
        }
    }
}

enum AudioEngineKind: String, CaseIterable, Identifiable {
    case classic   // AVAudioEngine + AVAudioEnvironmentNode
    case phase     // Apple PHASE

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .classic: return "Classic HRTF"
        case .phase:   return "PHASE"
        }
    }
}

// MARK: - Trajectory

struct Trajectory: Codable, Equatable {
    var target: MovingTarget
    var startSource: SpatialPoint
    var endSource: SpatialPoint
    var startListener: SpatialPoint
    var endListener: SpatialPoint
    var duration: Double
    var loop: Bool
    var reverse: Bool
    var easing: EasingType
}
