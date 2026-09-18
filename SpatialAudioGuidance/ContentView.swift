//
//  ContentView.swift
//  SpatialAudioGuidance
//
//  Root tab layout.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = SceneViewModel()

    var body: some View {
        TabView {
            LiveControlView(vm: vm)
                .tabItem { Label("Live", systemImage: "dot.radiowaves.left.and.right") }

            FollowView()
                .tabItem { Label("Follow", systemImage: "camera.viewfinder") }

            TrajectoryEditorView(vm: vm)
                .tabItem { Label("Trajectory", systemImage: "point.topleft.down.curvedto.point.bottomright.up") }

            SettingsView(vm: vm)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
}
