//
//  HeadphoneMotionManager.swift
//  SpatialAudioGuidance
//
//  Head tracking via CMHeadphoneMotionManager (AirPods Pro, etc).
//

import Foundation
#if canImport(CoreMotion)
import CoreMotion
#endif

final class HeadphoneMotionManager {

    /// Delivers yaw/pitch/roll (degrees) relative to the calibrated forward.
    var onUpdate: ((_ yaw: Float, _ pitch: Float, _ roll: Float) -> Void)?

    #if canImport(CoreMotion)
    private let manager = CMHeadphoneMotionManager()
    private var baselineYaw = 0.0
    private var baselinePitch = 0.0
    private var baselineRoll = 0.0
    private var hasBaseline = false
    #endif

    var isAvailable: Bool {
        #if canImport(CoreMotion)
        return manager.isDeviceMotionAvailable
        #else
        return false
        #endif
    }

    func start() {
        #if canImport(CoreMotion)
        guard manager.isDeviceMotionAvailable else { return }
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let m = motion else { return }
            let att = m.attitude
            if !self.hasBaseline {
                self.baselineYaw = att.yaw
                self.baselinePitch = att.pitch
                self.baselineRoll = att.roll
                self.hasBaseline = true
            }
            // Yaw sign flipped so that turning the head right is positive.
            let yaw = Float(-(att.yaw - self.baselineYaw) * 180 / .pi)
            let pitch = Float((att.pitch - self.baselinePitch) * 180 / .pi)
            let roll = Float((att.roll - self.baselineRoll) * 180 / .pi)
            self.onUpdate?(yaw, pitch, roll)
        }
        #endif
    }

    func stop() {
        #if canImport(CoreMotion)
        manager.stopDeviceMotionUpdates()
        hasBaseline = false
        #endif
    }

    /// Store the current head attitude as the new "forward" baseline.
    func calibrate() {
        #if canImport(CoreMotion)
        hasBaseline = false
        #endif
    }
}
