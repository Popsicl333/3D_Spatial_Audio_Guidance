//
//  LiveControlView.swift
//  SpatialAudioGuidance
//
//  Sound picker, playback, source/listener coordinates, and drag pads.
//

import SwiftUI

struct LiveControlView: View {
    @ObservedObject var vm: SceneViewModel
    @State private var useSpherical = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    audioSourceSection
                    playbackSection
                    editingTargetSection
                    HStack(alignment: .top, spacing: 12) {
                        TopDownPadView(vm: vm)
                        SideViewPadView(vm: vm)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    sourcePositionSection
                    listenerPositionSection
                }
                .padding()
            }
            .navigationTitle("Live Control")
        }
    }

    // MARK: - Sections

    private var audioSourceSection: some View {
        SectionCard(title: "Audio Source") {
            Picker("Sound", selection: Binding(
                get: { vm.source.soundType },
                set: { vm.source.soundType = $0 }
            )) {
                ForEach(SoundType.allCases) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.menu)

            if vm.source.soundType == .beep || vm.source.soundType == .sineTone || vm.source.soundType == .pulseBeep {
                LabeledSlider(label: "Frequency", value: $vm.frequency,
                              range: SpaceLimits.frequency, step: 10, unit: " Hz", format: "%.0f")
            }
            if vm.source.soundType == .pulseBeep || vm.source.soundType == .pulseNoise {
                LabeledDoubleSlider(label: "Pulse Interval", value: $vm.pulseInterval,
                                    range: SpaceLimits.pulseInterval, step: 0.05, unit: " s")
            }
            LabeledSlider(label: "Source Volume", value: Binding(
                get: { vm.source.volume }, set: { vm.source.volume = $0 }),
                          range: 0...1, step: 0.05)
        }
    }

    private var playbackSection: some View {
        SectionCard(title: "Playback") {
            HStack {
                Button(vm.isPlaying ? "Stop" : "Start Audio") {
                    vm.isPlaying ? vm.stop() : vm.play()
                }
                .buttonStyle(.borderedProminent)
                .tint(vm.isPlaying ? .red : .green)

                Button("Play Once") { vm.playOnce() }
                    .buttonStyle(.bordered)
                Spacer()
            }
            HStack {
                Button("Center Beep") { vm.centerBeep() }
                    .buttonStyle(.bordered)
                Button("Reset") { vm.resetScene() }
                    .buttonStyle(.bordered)
            }
        }
    }

    private var editingTargetSection: some View {
        SectionCard(title: "Drag Target") {
            Picker("Editing", selection: $vm.editingTarget) {
                ForEach(EditingTarget.allCases) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.segmented)
            HStack {
                CoordinateChip(title: "Source", point: vm.source.position, color: .orange)
                Spacer()
                CoordinateChip(title: "Listener", point: vm.listener.position, color: .blue)
            }
        }
    }

    private var sourcePositionSection: some View {
        SectionCard(title: "Sound Source Position") {
            Picker("Mode", selection: $useSpherical) {
                Text("X / Y / Z").tag(false)
                Text("Az / El / Dist").tag(true)
            }
            .pickerStyle(.segmented)

            if useSpherical {
                let s = vm.sourceSpherical
                sphericalEditor(current: s)
            } else {
                LabeledSlider(label: "X (right +)", value: $vm.source.position.x, range: SpaceLimits.x, unit: " m")
                LabeledSlider(label: "Y (up +)", value: $vm.source.position.y, range: SpaceLimits.y, unit: " m")
                LabeledSlider(label: "Z (front −)", value: $vm.source.position.z, range: SpaceLimits.z, unit: " m")
            }
            Button("Reset Source") { vm.resetSource() }.buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func sphericalEditor(current: Spherical) -> some View {
        // Local bindings that recompute cartesian on change.
        let azBinding = Binding<Float>(
            get: { current.azimuthDegrees },
            set: { vm.setSourceSpherical(azimuth: $0, elevation: current.elevationDegrees, distance: current.distance) })
        let elBinding = Binding<Float>(
            get: { current.elevationDegrees },
            set: { vm.setSourceSpherical(azimuth: current.azimuthDegrees, elevation: $0, distance: current.distance) })
        let distBinding = Binding<Float>(
            get: { current.distance },
            set: { vm.setSourceSpherical(azimuth: current.azimuthDegrees, elevation: current.elevationDegrees, distance: $0) })

        LabeledSlider(label: "Azimuth (right +)", value: azBinding, range: SpaceLimits.azimuth, step: 1, unit: "°", format: "%.0f")
        LabeledSlider(label: "Elevation (up +)", value: elBinding, range: SpaceLimits.elevation, step: 1, unit: "°", format: "%.0f")
        LabeledSlider(label: "Distance", value: distBinding, range: SpaceLimits.distance, step: 0.1, unit: " m")
    }

    private var listenerPositionSection: some View {
        SectionCard(title: "Listener Position") {
            LabeledSlider(label: "X", value: $vm.listener.position.x, range: SpaceLimits.x, unit: " m")
            LabeledSlider(label: "Y", value: $vm.listener.position.y, range: SpaceLimits.y, unit: " m")
            LabeledSlider(label: "Z", value: $vm.listener.position.z, range: SpaceLimits.z, unit: " m")
            if vm.orientationMode == .manual {
                LabeledSlider(label: "Yaw", value: $vm.listener.yaw, range: SpaceLimits.angle, step: 1, unit: "°", format: "%.0f")
                LabeledSlider(label: "Pitch", value: $vm.listener.pitch, range: SpaceLimits.pitch, step: 1, unit: "°", format: "%.0f")
                LabeledSlider(label: "Roll", value: $vm.listener.roll, range: SpaceLimits.angle, step: 1, unit: "°", format: "%.0f")
            }
            Button("Reset Listener") { vm.resetListener() }.buttonStyle(.bordered)
        }
    }
}
