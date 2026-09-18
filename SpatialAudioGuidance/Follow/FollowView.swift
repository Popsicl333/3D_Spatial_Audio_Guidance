//
//  FollowView.swift
//  SpatialAudioGuidance
//
//  Follow tab: live camera preview, the target's box and position, and the
//  audio and target settings.
//

import SwiftUI
import UIKit
import SceneKit
import ARKit

struct FollowView: View {
    @StateObject private var vm = FollowViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            if vm.arSupported {
                // The gesture lives on the preview, not the whole screen, so
                // quick taps on the buttons cannot toggle following by accident.
                TripleTapOverlay(isFollowing: vm.isFollowing, onToggle: { vm.toggleFollowing() }) {
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            CameraPreview(vm: vm)
                            TargetBoxOverlay(debug: vm.debug, viewSize: geo.size)
                        }
                        .onAppear { vm.viewportSize = geo.size }
                        .onChange(of: geo.size) { _, newSize in
                            vm.viewportSize = newSize
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
            } else {
                ContentUnavailableView(
                    "Camera not available",
                    systemImage: "camera.metering.unknown",
                    description: Text("Following needs a real device with a rear camera."))
            }

            VStack(spacing: 8) {
                statusBar
                Spacer()
                PositionReadout(debug: vm.debug)
                controlBar
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
        .sheet(isPresented: $showSettings) {
            FollowSettingsSheet(vm: vm)
        }
    }

    // MARK: - Status / controls

    private var statusBar: some View {
        HStack {
            Circle()
                .fill(vm.debug.hasDetection ? Color.green : Color.orange)
                .frame(width: 9, height: 9)
            Text(vm.debug.statusText)
                .font(.caption.monospaced())
            Spacer()
            Text(vm.isFollowing ? "FOLLOWING" : "PAUSED")
                .font(.caption2.monospaced().bold())
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(vm.isFollowing ? Color.green : Color.orange, in: Capsule())
                .foregroundStyle(.black)
            Spacer().frame(width: 8)
            Text(vm.detectorKind.displayName)
                .font(.caption2.monospaced().bold())
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(vm.detectorKind == .colourMarker ? Color.pink : Color.blue,
                            in: Capsule())
        }
        .padding(8)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(.white)
    }

    private var controlBar: some View {
        HStack(spacing: 14) {
            Button {
                vm.muted.toggle()
            } label: {
                Image(systemName: vm.muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel(vm.muted ? "Unmute" : "Mute")

            Button {
                vm.toggleFollowing()
            } label: {
                Image(systemName: vm.isFollowing ? "pause.fill" : "play.fill")
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel(vm.isFollowing ? "Pause following" : "Start following")

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("Settings")
        }
        .font(.title3)
        .padding(.horizontal, 12)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
        .foregroundStyle(.white)
    }
}

// MARK: - Camera preview + target sphere

private struct CameraPreview: UIViewRepresentable {
    @ObservedObject var vm: FollowViewModel

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.session = vm.session
        view.automaticallyUpdatesLighting = false
        view.antialiasingMode = .none

        // Small sphere drawn at the target's position.
        let sphere = SCNSphere(radius: 0.03)
        sphere.firstMaterial?.diffuse.contents = UIColor.systemCyan
        sphere.firstMaterial?.emission.contents = UIColor.systemCyan
        sphere.firstMaterial?.transparency = 0.85
        let node = SCNNode(geometry: sphere)
        node.isHidden = true
        view.scene.rootNode.addChildNode(node)
        context.coordinator.sphereNode = node
        return view
    }

    func updateUIView(_ view: ARSCNView, context: Context) {
        let d = vm.debug
        if let node = context.coordinator.sphereNode {
            node.isHidden = !(d.hasDetection && d.worldValid && vm.showSphere)
            node.simdPosition = d.worldPosition
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var sphereNode: SCNNode?
    }
}

// MARK: - Detection box

private struct TargetBoxOverlay: View {
    let debug: FollowState
    let viewSize: CGSize

    var body: some View {
        if let norm = debug.boundingBoxViewNorm, debug.hasDetection {
            let rect = CGRect(x: norm.origin.x * viewSize.width,
                              y: norm.origin.y * viewSize.height,
                              width: norm.width * viewSize.width,
                              height: norm.height * viewSize.height)
            ZStack(alignment: .topLeading) {
                Path { p in p.addRect(rect) }
                    .stroke(Color.green, lineWidth: 2)

                Path { p in
                    let c = CGPoint(x: rect.midX, y: rect.midY)
                    p.move(to: CGPoint(x: c.x - 8, y: c.y))
                    p.addLine(to: CGPoint(x: c.x + 8, y: c.y))
                    p.move(to: CGPoint(x: c.x, y: c.y - 8))
                    p.addLine(to: CGPoint(x: c.x, y: c.y + 8))
                }
                .stroke(Color.green, lineWidth: 1.5)

                Text("\(debug.label)  \(String(format: "%.2f m", debug.distance))")
                    .font(.caption2.monospaced().bold())
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.85), in: RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(.black)
                    .offset(x: max(rect.minX, 2), y: max(rect.minY - 20, 2))
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Position readout

private struct PositionReadout: View {
    let debug: FollowState

    var body: some View {
        HStack(spacing: 16) {
            item("Distance", debug.hasDetection ? String(format: "%.1f m", debug.distance) : "--")
            item("Direction", debug.hasDetection ? String(format: "%+.0f°", debug.azimuthDeg) : "--")
            item("Height", debug.hasDetection ? String(format: "%+.0f°", debug.elevationDeg) : "--")
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(.white)
        .accessibilityElement(children: .combine)
    }

    private func item(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.callout.monospacedDigit().bold())
        }
    }
}

// MARK: - Settings sheet

private struct FollowSettingsSheet: View {
    @ObservedObject var vm: FollowViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Target") {
                    Picker("Follow", selection: $vm.detectorKind) {
                        ForEach(DetectorKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(vm.detectorKind == .colourMarker
                         ? "Follow a printed marker worn by the person you are walking with."
                         : "Follow a hand held in front of the camera.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if vm.detectorKind == .colourMarker {
                    Section("Marker") {
                        Button("Match marker colour") { vm.calibrateColour() }
                        Text("Point the camera at the marker so it fills the middle of the frame, then tap.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if vm.colourCalibratedAt != nil {
                            Button("Reset marker colour", role: .destructive) {
                                vm.clearColourCalibration()
                            }
                        }
                        if let message = vm.calibrationMessage {
                            Text(message).font(.caption)
                                .foregroundStyle(vm.calibrationMessageIsProblem ? Color.orange : Color.green)
                        }
                    }
                }

                Section("Sound") {
                    Toggle("Closer sounds higher", isOn: $vm.distancePitchEnabled)
                    Toggle("Closer pulses faster", isOn: $vm.pulseRateEnabled)
                    Toggle("Approach accent", isOn: $vm.approachAccentEnabled)
                    HStack {
                        Image(systemName: "speaker.wave.1")
                        Slider(value: $vm.masterVolume, in: 0...1)
                        Image(systemName: "speaker.wave.3")
                    }
                }

                Section("Headphones") {
                    Button("Set forward (stand still, look ahead)") { vm.alignHead() }
                    Text("Tells the app which way you are facing. Repeat it whenever the sound seems off to one side.")
                        .font(.caption2).foregroundStyle(.secondary)
                }

                Section("Display") {
                    Toggle("Show target sphere", isOn: $vm.showSphere)
                }
            }
            .navigationTitle("Follow Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    FollowView()
}
