//
//  UIComponents.swift
//  SpatialAudioGuidance
//
//  Small reusable SwiftUI controls.
//

import SwiftUI

/// A labeled slider with a numeric read-out.
struct LabeledSlider: View {
    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    var step: Float = 0.1
    var unit: String = ""
    var format: String = "%.2f"

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.caption)
                Spacer()
                Text(String(format: format, value) + unit)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

struct LabeledDoubleSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.1
    var unit: String = ""
    var format: String = "%.2f"

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.caption)
                Spacer()
                Text(String(format: format, value) + unit)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

/// Read-only x/y/z coordinate chip.
struct CoordinateChip: View {
    let title: String
    let point: SpatialPoint
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 8) {
            Text(title).font(.caption.bold()).foregroundStyle(color)
            Text(String(format: "x %.1f  y %.1f  z %.1f", point.x, point.y, point.z))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}
