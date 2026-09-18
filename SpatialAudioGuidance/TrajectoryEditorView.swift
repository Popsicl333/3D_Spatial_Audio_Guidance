//
//  TrajectoryEditorView.swift
//  SpatialAudioGuidance
//
//  Tab 2: define and play simple line trajectories.
//

import SwiftUI

struct TrajectoryEditorView: View {
    @ObservedObject var vm: SceneViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionCard(title: "Moving Target") {
                        Picker("Target", selection: $vm.trajectory.target) {
                            ForEach(MovingTarget.allCases) { Text($0.displayName).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    SectionCard(title: "Start / End") {
                        CoordinateChip(title: "Start (source)", point: vm.trajectory.startSource, color: .orange)
                        CoordinateChip(title: "End (source)", point: vm.trajectory.endSource, color: .orange)
                        if vm.trajectory.target != .source {
                            CoordinateChip(title: "Start (listener)", point: vm.trajectory.startListener, color: .blue)
                            CoordinateChip(title: "End (listener)", point: vm.trajectory.endListener, color: .blue)
                        }
                        HStack {
                            Button("Set Current as Start") { vm.setTrajectoryStartFromCurrent() }
                                .buttonStyle(.bordered)
                            Button("Set Current as End") { vm.setTrajectoryEndFromCurrent() }
                                .buttonStyle(.bordered)
                        }
                    }

                    SectionCard(title: "Timing & Motion") {
                        LabeledDoubleSlider(label: "Duration", value: $vm.trajectory.duration,
                                            range: 0.5...15, step: 0.1, unit: " s")
                        Picker("Easing", selection: $vm.trajectory.easing) {
                            ForEach(EasingType.allCases) { Text($0.displayName).tag($0) }
                        }
                        .pickerStyle(.menu)
                        Toggle("Loop", isOn: $vm.trajectory.loop)
                        Toggle("Reverse", isOn: $vm.trajectory.reverse)
                    }

                    SectionCard(title: "Run") {
                        HStack {
                            Button(vm.isTrajectoryRunning ? "Stop Trajectory" : "Play Trajectory") {
                                vm.isTrajectoryRunning ? vm.stopTrajectory() : vm.playTrajectory()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(vm.isTrajectoryRunning ? .red : .green)

                            Button("Reset") { vm.stopTrajectory(); vm.resetSource(); vm.resetListener() }
                                .buttonStyle(.bordered)
                        }
                        Text("The sound keeps playing while the position moves smoothly (~60 fps).")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Trajectory")
        }
    }
}
