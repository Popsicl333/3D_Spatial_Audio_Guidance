//
//  FollowModels.swift
//  SpatialAudioGuidance
//
//  UI-facing state for the Follow tab.
//

import Foundation
import simd
import CoreGraphics

/// What the Follow screen shows each frame.
struct FollowState {
    var hasDetection = false
    /// Detection box in normalized view coordinates (origin top-left).
    var boundingBoxViewNorm: CGRect?
    var label = "target"
    var confidence: Float = 0

    var distance: Float = 0
    var azimuthDeg: Float = 0
    var elevationDeg: Float = 0
    var worldPosition = simd_float3()
    var worldValid = false

    var trackingStateText = "initializing"
    var statusText = "starting…"
}

/// Which kind of target the camera follows.
enum DetectorKind: String, CaseIterable, Identifiable {
    case handPose
    case colourMarker

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .handPose:     return "Hand"
        case .colourMarker: return "Marker"
        }
    }
}
