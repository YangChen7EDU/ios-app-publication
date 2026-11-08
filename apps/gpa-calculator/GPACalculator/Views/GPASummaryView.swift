import SwiftUI

/// Weighted and unweighted GPA side by side, with the credit total.
struct GPASummaryView: View {
    let title: String
    let result: GPAResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline) {
                value("Weighted", GPA.format(result.weighted), prominent: true)
                Spacer()
                value("Unweighted", GPA.format(result.unweighted), prominent: false)
                Spacer()
                value("Credits", result.credits.formatted(.number.precision(.fractionLength(0...2))), prominent: false)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private func value(_ label: String, _ text: String, prominent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(text)
                .font(prominent ? .system(.largeTitle, design: .rounded).weight(.bold) : .system(.title2, design: .rounded).weight(.semibold))
                .foregroundStyle(prominent ? Color.accentColor : .primary)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
