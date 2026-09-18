//
//  TrajectoryRunner.swift
//  SpatialAudioGuidance
//
//  Drives smooth position updates for a trajectory using CADisplayLink (~60 fps).
//  The sound keeps playing; only the node positions are updated each frame.
//

import QuartzCore

final class TrajectoryRunner {

    /// Called each frame with the interpolated source & listener positions.
    var onUpdate: ((_ source: SpatialPoint?, _ listener: SpatialPoint?) -> Void)?
    /// Called when a non-looping trajectory finishes.
    var onFinished: (() -> Void)?

    private var displayLink: CADisplayLink?
    private var trajectory: Trajectory = Trajectory()
    private var startTime: CFTimeInterval = 0
    private(set) var isRunning = false

    func start(_ trajectory: Trajectory) {
        stop()
        self.trajectory = trajectory
        self.startTime = CACurrentMediaTime()
        isRunning = true

        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFramesPerSecond = 60
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        isRunning = false
    }

    @objc private func tick() {
        let duration = max(trajectory.duration, 0.01)
        var elapsed = CACurrentMediaTime() - startTime
        var finished = false

        var progress: Double
        if trajectory.loop {
            let period = trajectory.reverse ? duration * 2 : duration
            var phase = elapsed.truncatingRemainder(dividingBy: period) / duration
            if trajectory.reverse && phase > 1 { phase = 2 - phase } // ping-pong
            progress = phase
        } else {
            if elapsed >= duration {
                elapsed = duration
                finished = true
            }
            var p = elapsed / duration
            if trajectory.reverse { p = 1 - p }
            progress = p
        }

        let eased = trajectory.easing.apply(Float(progress))

        var source: SpatialPoint?
        var listener: SpatialPoint?
        switch trajectory.target {
        case .source:
            source = SpatialMath.lerp(trajectory.startSource, trajectory.endSource, eased)
        case .listener:
            listener = SpatialMath.lerp(trajectory.startListener, trajectory.endListener, eased)
        case .both:
            source = SpatialMath.lerp(trajectory.startSource, trajectory.endSource, eased)
            listener = SpatialMath.lerp(trajectory.startListener, trajectory.endListener, eased)
        }

        onUpdate?(source, listener)

        if finished {
            stop()
            onFinished?()
        }
    }
}
