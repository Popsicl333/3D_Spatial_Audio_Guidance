//
//  TopDownPadView.swift
//  SpatialAudioGuidance
//
//  Bird's-eye drag pad. Horizontal axis = x (left/right),
//  vertical axis = z (front is up on screen = -z, behind is down = +z).
//

import SwiftUI

struct TopDownPadView: View {
    @ObservedObject var vm: SceneViewModel

    var body: some View {
        PadCanvas(
            title: "Top-Down (X / Z)",
            hAxisLabel: "Left  —  Right (x)",
            vAxisLabelTop: "Front (−z)",
            vAxisLabelBottom: "Behind (+z)",
            hRange: SpaceLimits.x,
            vRange: SpaceLimits.z,
            sourceH: vm.source.position.x,
            sourceV: vm.source.position.z,
            listenerH: vm.listener.position.x,
            listenerV: vm.listener.position.z,
            invertV: true, // front (−z) shown at top
            editing: vm.editingTarget
        ) { h, v in
            switch vm.editingTarget {
            case .source:
                vm.source.position.x = h
                vm.source.position.z = v
            case .listener:
                vm.listener.position.x = h
                vm.listener.position.z = v
            }
        }
    }
}

struct SideViewPadView: View {
    @ObservedObject var vm: SceneViewModel

    var body: some View {
        PadCanvas(
            title: "Side View (Z / Y)",
            hAxisLabel: "Front (−z)  —  Behind (+z)",
            vAxisLabelTop: "Up (+y)",
            vAxisLabelBottom: "Down (−y)",
            hRange: SpaceLimits.z,
            vRange: SpaceLimits.y,
            sourceH: vm.source.position.z,
            sourceV: vm.source.position.y,
            listenerH: vm.listener.position.z,
            listenerV: vm.listener.position.y,
            invertV: false,
            invertH: true, // front (−z) at left
            editing: vm.editingTarget
        ) { h, v in
            switch vm.editingTarget {
            case .source:
                vm.source.position.z = h
                vm.source.position.y = v
            case .listener:
                vm.listener.position.z = h
                vm.listener.position.y = v
            }
        }
    }
}

// MARK: - Shared canvas

private struct PadCanvas: View {
    let title: String
    let hAxisLabel: String
    let vAxisLabelTop: String
    let vAxisLabelBottom: String
    let hRange: ClosedRange<Float>
    let vRange: ClosedRange<Float>
    let sourceH: Float
    let sourceV: Float
    let listenerH: Float
    let listenerV: Float
    var invertV: Bool = false
    var invertH: Bool = false
    let editing: EditingTarget
    let onDrag: (_ h: Float, _ v: Float) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).bold()
            Text(vAxisLabelTop).font(.caption2).foregroundStyle(.secondary)
            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.12))
                    // grid center lines
                    Path { p in
                        p.move(to: CGPoint(x: size.width / 2, y: 0))
                        p.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                        p.move(to: CGPoint(x: 0, y: size.height / 2))
                        p.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                    }
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))

                    // listener dot
                    dot(color: .blue, filled: editing == .listener,
                        pos: point(h: listenerH, v: listenerV, size: size), label: "L")
                    // source dot
                    dot(color: .orange, filled: editing == .source,
                        pos: point(h: sourceH, v: sourceV, size: size), label: "S")
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            let (h, v) = value(at: g.location, size: size)
                            onDrag(h, v)
                        }
                )
            }
            .frame(height: 160)
            Text(vAxisLabelBottom).font(.caption2).foregroundStyle(.secondary)
            Text(hAxisLabel).font(.caption2).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func point(h: Float, v: Float, size: CGSize) -> CGPoint {
        var hn = (h - hRange.lowerBound) / (hRange.upperBound - hRange.lowerBound)
        var vn = (v - vRange.lowerBound) / (vRange.upperBound - vRange.lowerBound)
        if invertH { hn = 1 - hn }
        if invertV { vn = 1 - vn }
        // Screen y grows downward; higher value should be near top -> invert vn for screen.
        let x = CGFloat(hn) * size.width
        let y = (1 - CGFloat(vn)) * size.height
        return CGPoint(x: x.clamped(0, size.width), y: y.clamped(0, size.height))
    }

    private func value(at loc: CGPoint, size: CGSize) -> (Float, Float) {
        var hn = Float(loc.x / max(size.width, 1))
        var vn = Float(1 - loc.y / max(size.height, 1)) // flip screen y back to value-up
        hn = min(max(hn, 0), 1)
        vn = min(max(vn, 0), 1)
        if invertH { hn = 1 - hn }
        if invertV { vn = 1 - vn }
        let h = hRange.lowerBound + hn * (hRange.upperBound - hRange.lowerBound)
        let v = vRange.lowerBound + vn * (vRange.upperBound - vRange.lowerBound)
        return (h, v)
    }

    @ViewBuilder
    private func dot(color: Color, filled: Bool, pos: CGPoint, label: String) -> some View {
        ZStack {
            Circle()
                .fill(filled ? color : color.opacity(0.35))
                .frame(width: filled ? 22 : 16, height: filled ? 22 : 16)
            Text(label).font(.caption2).bold().foregroundStyle(.white)
        }
        .position(pos)
    }
}

private extension CGFloat {
    func clamped(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat { Swift.min(Swift.max(self, lo), hi) }
}
