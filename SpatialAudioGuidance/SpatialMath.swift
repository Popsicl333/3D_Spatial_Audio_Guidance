//
//  SpatialMath.swift
//  SpatialAudioGuidance
//
//  Coordinate helpers using Apple's audio coordinate system.
//
//  Apple audio coordinate system (meters):
//    x > 0  = right,  x < 0 = left
//    y > 0  = up,     y < 0 = down
//    z < 0  = front,  z > 0 = behind
//  Listener default forward = (0, 0, -1), up = (0, 1, 0).
//

import Foundation

/// Spherical coordinates as presented in the UI.
/// - azimuth: degrees, positive = right, negative = left
/// - elevation: degrees, positive = up, negative = down
/// - distance: meters (always >= 0)
struct Spherical: Equatable {
    var azimuthDegrees: Float
    var elevationDegrees: Float
    var distance: Float
}

enum SpatialMath {

    /// Convert azimuth/elevation/distance to Apple x/y/z (relative to the listener at origin, facing -z).
    static func cartesian(from s: Spherical) -> SpatialPoint {
        let az = s.azimuthDegrees * .pi / 180
        let el = s.elevationDegrees * .pi / 180
        let x = s.distance * sin(az) * cos(el)
        let y = s.distance * sin(el)
        let z = -s.distance * cos(az) * cos(el)
        return SpatialPoint(x: x, y: y, z: z)
    }

    /// Convert a source position (relative to a listener position) to azimuth/elevation/distance.
    static func spherical(source: SpatialPoint, listener: SpatialPoint = .origin) -> Spherical {
        let dx = source.x - listener.x
        let dy = source.y - listener.y
        let dz = source.z - listener.z
        let distance = sqrt(dx * dx + dy * dy + dz * dz)
        // atan2(dx, -dz): 0 straight ahead (-z), +90 to the right (+x).
        let azimuth = atan2(dx, -dz) * 180 / .pi
        let horiz = sqrt(dx * dx + dz * dz)
        let elevation = horiz == 0 && dy == 0 ? 0 : atan2(dy, horiz) * 180 / .pi
        return Spherical(azimuthDegrees: azimuth, elevationDegrees: elevation, distance: distance)
    }

    /// Straight-line distance between two points.
    static func distance(_ a: SpatialPoint, _ b: SpatialPoint) -> Float {
        let dx = a.x - b.x, dy = a.y - b.y, dz = a.z - b.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    /// Linear interpolation between two points.
    static func lerp(_ a: SpatialPoint, _ b: SpatialPoint, _ t: Float) -> SpatialPoint {
        SpatialPoint(x: a.x + (b.x - a.x) * t,
                     y: a.y + (b.y - a.y) * t,
                     z: a.z + (b.z - a.z) * t)
    }
}

extension EasingType {
    /// Apply the easing curve to a normalized progress value in [0, 1].
    func apply(_ t: Float) -> Float {
        let x = min(max(t, 0), 1)
        switch self {
        case .linear:    return x
        case .easeIn:    return x * x
        case .easeOut:   return 1 - (1 - x) * (1 - x)
        case .easeInOut: return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2
        }
    }
}
