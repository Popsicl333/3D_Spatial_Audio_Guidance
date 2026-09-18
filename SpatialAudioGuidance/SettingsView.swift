//
//  SettingsView.swift
//  SpatialAudioGuidance
//
//  Audio route, volume, rendering, orientation mode, head-tracking calibration.
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var vm: SceneViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Audio Output") {
                    LabeledContent("Route", value: currentRoute)
                    LabeledSlider(label: "Master Volume", value: $vm.volume, range: 0...1, step: 0.05)
                }

                Section("Spatial Rendering") {
                    Picker("Engine", selection: $vm.engineKind) {
                        ForEach(AudioEngineKind.allCases) { Text($0.displayName).tag($0) }
                    }
                    if vm.engineKind == .classic {
                        Picker("Algorithm", selection: $vm.renderingQuality) {
                            ForEach(RenderingQuality.allCases) { Text($0.displayName).tag($0) }
                        }
                    } else {
                        Text("PHASE is Apple's newer spatial engine. On iOS 18+ it tracks the head automatically with AirPods.")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Toggle("Room Reverb", isOn: $vm.reverbEnabled)
                    Text("Places sounds \"out in the room\" rather than inside your head.")
                        .font(.caption2).foregroundStyle(.secondary)
                }

                Section("Elevation Cues") {
                    Picker("Mode", selection: $vm.elevationCueMode) {
                        ForEach(ElevationCueMode.allCases) { Text($0.displayName).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    switch vm.elevationCueMode {
                    case .off:
                        Text("Plain spatial audio.")
                            .font(.caption2).foregroundStyle(.secondary)
                    case .spectral:
                        Text("Sounds above you get brighter; sounds below get duller.")
                            .font(.caption2).foregroundStyle(.secondary)
                    case .pitch:
                        Text("Sounds rise in pitch as they rise in height.")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    if vm.engineKind == .phase {
                        Text("Elevation cues run on the Classic HRTF engine only.")
                            .font(.caption2).foregroundStyle(.orange)
                    }
                }

                Section("Orientation") {
                    Picker("Mode", selection: $vm.orientationMode) {
                        ForEach(OrientationMode.allCases) { Text($0.displayName).tag($0) }
                    }
                    if vm.orientationMode == .airPods {
                        if vm.usesCoreMotionHeadTracking {
                            if vm.motion.isAvailable {
                                Button("Calibrate Forward") { vm.calibrateForward() }
                                    .buttonStyle(.borderedProminent)
                                Text("Face forward, then tap.")
                                    .font(.caption2).foregroundStyle(.secondary)
                            } else {
                                Text("Headphone motion is not available on this device.")
                                    .font(.caption2).foregroundStyle(.orange)
                            }
                        } else {
                            Text("Head tracking is handled by the PHASE engine.")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    if vm.orientationMode == .manual {
                        Text("Use the Yaw/Pitch/Roll sliders in Live Control.")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Reset All", role: .destructive) {
                        vm.resetAll()
                    }
                } footer: {
                    Text("3D Spatial Audio Guidance · hear where things are around you. Best with AirPods Pro in Transparency mode.")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var currentRoute: String {
        #if os(iOS)
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        return outputs.first?.portName ?? "Unknown"
        #else
        return "N/A"
        #endif
    }
}
