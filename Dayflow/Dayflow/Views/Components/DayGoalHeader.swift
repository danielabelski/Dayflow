//
//  DayGoalHeader.swift
//  Dayflow
//
//  Top-of-right-rail target progress header for the timeline summary.
//

import SwiftUI

struct TargetCategoryProgress: Identifiable {
  let id: String
  let name: String
  let colorHex: String
  let duration: TimeInterval

  var color: Color {
    Color(hex: colorHex)
  }
}

struct DayGoalHeader: View {
  let focusTargetDuration: TimeInterval
  let focusDuration: TimeInterval
  let focusCategories: [TargetCategoryProgress]
  let distractionLimitDuration: TimeInterval
  let distractedDuration: TimeInterval
  let recordingControlMode: RecordingControlMode
  let onSetGoals: () -> Void

  private enum Design {
    static let panelBackground = Color(hex: "FFFDFB")
    static let border = Color(hex: "EDE5E1")
    static let title = Color(hex: "333333")
    static let subtitle = Color(hex: "707070")
    static let label = Color(hex: "787878")
    static let distraction = Color(hex: "FA8282")
  }

  private var distractionUsedRatio: Double {
    guard distractionLimitDuration > 0 else { return 0 }
    return min(max(distractedDuration / distractionLimitDuration, 0), 1)
  }

  private var statusText: String {
    switch recordingControlMode {
    case .active:
      return "Tracking progress from your focus and distraction categories."
    case .pausedTimed, .pausedIndefinite:
      return "Dayflow is paused. Resume to continue tracking your progress."
    case .stopped:
      return "Start Dayflow to continue tracking your progress."
    }
  }

  var body: some View {
    GeometryReader { geometry in
      let xOffset = max((geometry.size.width - 360) / 2, 0)

      ZStack(alignment: .topLeading) {
        Design.panelBackground

        Text("Today’s targets")
          .font(.custom("InstrumentSerif-Regular", size: 24))
          .foregroundColor(Design.title)
          .lineLimit(1)
          .fixedSize()
          .offset(x: xOffset + 17, y: 18.96)

        setGoalsButton
          .offset(x: xOffset + 270.75, y: 12)

        Text(statusText)
          .font(.custom("Figtree", size: 11))
          .foregroundColor(Design.subtitle)
          .lineLimit(1)
          .fixedSize()
          .offset(x: xOffset + 17, y: 55.68)

        focusLabels
          .offset(x: xOffset, y: 88)

        FocusTargetProgressBar(
          categories: focusCategories,
          targetDuration: focusTargetDuration,
          actualDuration: focusDuration
        )
        .frame(width: 269, height: 14)
        .offset(x: xOffset + 39, y: 106.04)

        focusLegend
          .offset(x: xOffset + 38, y: 120)

        TargetIconBubble(kind: .focus)
          .frame(width: 36, height: 36)
          .offset(x: xOffset + 11, y: 102)

        Text(distractionSummary)
          .font(.custom("Figtree-Regular", size: 11))
          .foregroundColor(.black)
          .lineLimit(1)
          .fixedSize()
          .offset(x: xOffset + 57.08, y: 158)

        Text("Distraction limit")
          .font(.custom("Figtree-Regular", size: 11))
          .foregroundColor(Design.label)
          .lineLimit(1)
          .fixedSize()
          .offset(x: xOffset + 225.15, y: 160)

        DistractionLimitBar(usedRatio: distractionUsedRatio, color: Design.distraction)
          .frame(width: 259, height: 14)
          .offset(x: xOffset + 57.25, y: 177.04)

        TargetIconBubble(kind: .distraction)
          .frame(width: 36, height: 36)
          .offset(x: xOffset + 305.25, y: 161.08)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Design.border)
          .frame(height: 1)
      }
    }
    .frame(height: 213)
    .accessibilityElement(children: .contain)
  }

  private var setGoalsButton: some View {
    Button(action: onSetGoals) {
      Text("Set goals")
        .font(.custom("Figtree", size: 12).weight(.medium))
        .foregroundColor(.white)
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(
          LinearGradient(
            colors: [
              Color(hex: "FFB18D").opacity(0.6),
              Color(hex: "FFB18D"),
              Color(hex: "FFA46F"),
              Color(hex: "FFB18D"),
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .clipShape(Capsule())
        .overlay(
          Capsule()
            .stroke(Color(hex: "F2D2BD"), lineWidth: 1.25)
        )
        .shadow(color: Color.white.opacity(0.5), radius: 4, x: -3, y: 0)
        .shadow(color: Color.white.opacity(0.5), radius: 4, x: 3, y: 0)
    }
    .buttonStyle(DayflowPressScaleButtonStyle(pressedScale: 0.97))
    .hoverScaleEffect(scale: 1.02)
    .pointingHandCursorOnHover(reassertOnPressEnd: true)
    .accessibilityLabel("Set goals")
  }

  private var focusLabels: some View {
    ZStack(alignment: .topLeading) {
      Text("Focus")
        .font(.custom("Figtree-Regular", size: 11))
        .foregroundColor(Design.label)
        .lineLimit(1)
        .fixedSize()
        .offset(x: 49, y: 2.5)

      Text(focusSummary)
        .font(.custom("Figtree-Regular", size: 11))
        .foregroundColor(.black)
        .lineLimit(1)
        .fixedSize()
        .offset(x: 222.15, y: 0)
    }
  }

  private var focusLegend: some View {
    ZStack(alignment: .leading) {
      TargetLegendTail()
        .fill(Color(hex: "D9D9D9").opacity(0.72))
        .frame(width: 232.277, height: 14)

      HStack(spacing: 6) {
        ForEach(focusCategories) { category in
          TargetLegendItem(category: category)
        }
      }
      .padding(.leading, 13.06)
      .frame(width: 225, alignment: .leading)
    }
    .frame(width: 232.277, height: 14)
  }

  private var focusSummary: String {
    "\(formatCompactHours(focusDuration)) / \(formatCompactHours(focusTargetDuration)) hr fulfilled"
  }

  private var distractionSummary: String {
    "\(formatUsedDuration(distractedDuration)) / \(formatLimitDuration(distractionLimitDuration)) used"
  }

  private func formatCompactHours(_ duration: TimeInterval) -> String {
    let hours = duration / 3600
    if abs(hours.rounded() - hours) < 0.01 {
      return "\(Int(hours.rounded()))"
    }
    return String(format: "%.1f", hours)
  }

  private func formatUsedDuration(_ duration: TimeInterval) -> String {
    let totalMinutes = Int(duration / 60)
    if totalMinutes < 60 {
      return "\(totalMinutes) mins"
    }

    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if minutes == 0 {
      return hours == 1 ? "1 hour" : "\(hours) hours"
    }
    return "\(hours)h \(minutes)m"
  }

  private func formatLimitDuration(_ duration: TimeInterval) -> String {
    let totalMinutes = Int(duration / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    if hours > 0 && minutes == 0 {
      return hours == 1 ? "1 hour" : "\(hours) hours"
    }
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    }
    return "\(totalMinutes) mins"
  }
}

private struct FocusTargetProgressBar: View {
  let categories: [TargetCategoryProgress]
  let targetDuration: TimeInterval
  let actualDuration: TimeInterval

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var isFulfilled: Bool {
    targetDuration > 0 && actualDuration >= targetDuration
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        trackShape
          .fill(isFulfilled ? Color(hex: "ECECEC") : Color(hex: "E7E7E7"))
          .shadow(
            color: isFulfilled ? Color(hex: "628CFF").opacity(0.5) : .clear,
            radius: isFulfilled ? 3 : 0,
            x: 0,
            y: 0
          )
          .overlay(
            trackShape
              .stroke(isFulfilled ? Color(hex: "91AEFF").opacity(0.9) : .clear, lineWidth: 0.5)
          )

        HStack(spacing: 2.55) {
          ForEach(Array(visibleSegments.enumerated()), id: \.element.id) { index, category in
            FocusTargetProgressSegment(
              color: category.color,
              index: index,
              isFulfilled: isFulfilled,
              reduceMotion: reduceMotion
            )
            .frame(
              width: segmentWidth(for: category, availableWidth: geometry.size.width), height: 8)
          }
        }
        .frame(height: 8)
        .padding(.vertical, 3)
        .frame(width: geometry.size.width, alignment: .leading)
        .clipShape(trackShape)
      }
    }
  }

  private var visibleSegments: [TargetCategoryProgress] {
    categories.filter { $0.duration > 0 }
  }

  private var displayedDuration: TimeInterval {
    let segmentTotal = visibleSegments.reduce(0) { $0 + $1.duration }
    return max(targetDuration, segmentTotal)
  }

  private var trackShape: RoundedRectangle {
    RoundedRectangle(cornerRadius: 2)
  }

  private func segmentWidth(for category: TargetCategoryProgress, availableWidth: CGFloat)
    -> CGFloat
  {
    guard displayedDuration > 0 else { return 0 }
    let ratio = min(max(category.duration / displayedDuration, 0), 1)
    return max(0, availableWidth * ratio)
  }
}

private struct FocusTargetProgressSegment: View {
  let color: Color
  let index: Int
  let isFulfilled: Bool
  let reduceMotion: Bool

  var body: some View {
    if isFulfilled && !reduceMotion {
      TimelineView(.animation(minimumInterval: 1 / 30)) { context in
        segmentBody(at: context.date.timeIntervalSinceReferenceDate)
      }
    } else {
      segmentBody(at: nil)
    }
  }

  private func segmentBody(at time: TimeInterval?) -> some View {
    let pulse = pulseAmount(at: time)

    return Capsule()
      .fill(segmentFill)
      .overlay {
        if isFulfilled && !reduceMotion, let time {
          shimmerOverlay(at: time)
        }
      }
      .shadow(
        color: color.opacity(isFulfilled ? 0.18 + 0.18 * pulse : 0),
        radius: isFulfilled ? 2 + 5 * pulse : 0,
        x: 0,
        y: 0
      )
  }

  private var segmentFill: LinearGradient {
    LinearGradient(
      colors: [
        color.opacity(isFulfilled ? 0.82 : 1),
        color,
        color.opacity(isFulfilled ? 0.72 : 1),
      ],
      startPoint: .leading,
      endPoint: .trailing
    )
  }

  private func shimmerOverlay(at time: TimeInterval) -> some View {
    GeometryReader { geometry in
      let width = max(geometry.size.width * 0.7, 18)
      let xOffset = shimmerOffset(at: time, in: geometry.size.width, shimmerWidth: width)

      LinearGradient(
        stops: [
          .init(color: .white.opacity(0), location: 0),
          .init(color: .white.opacity(0.28), location: 0.46),
          .init(color: .white.opacity(0.34), location: 0.5),
          .init(color: .white.opacity(0.22), location: 0.56),
          .init(color: .white.opacity(0), location: 1),
        ],
        startPoint: .leading,
        endPoint: .trailing
      )
      .frame(width: width)
      .offset(x: xOffset)
      .blendMode(.screen)
    }
    .clipShape(Capsule())
  }

  private func pulseAmount(at time: TimeInterval?) -> Double {
    guard let time, isFulfilled, !reduceMotion else {
      return isFulfilled ? 0.4 : 0
    }

    let duration = 3.2
    let stagger = Double(index) * 0.48
    let progress = ((time + stagger) / duration).truncatingRemainder(dividingBy: 1)
    return 0.5 + 0.5 * sin(progress * 2 * .pi - (.pi / 2))
  }

  private func shimmerOffset(at time: TimeInterval, in segmentWidth: CGFloat, shimmerWidth: CGFloat)
    -> CGFloat
  {
    let duration = 5.4
    let phase = (time / duration + phaseOffset).truncatingRemainder(dividingBy: 1)
    return -shimmerWidth + (segmentWidth + shimmerWidth * 2) * phase
  }

  private var phaseOffset: Double {
    switch index % 4 {
    case 1:
      return 0.43
    case 2:
      return 0.71
    case 3:
      return 0.18
    default:
      return 0
    }
  }
}

private struct DistractionLimitBar: View {
  let usedRatio: Double
  let color: Color

  var body: some View {
    GeometryReader { geometry in
      let clampedRatio = min(max(usedRatio, 0), 1)
      let startX = geometry.size.width * clampedRatio
      let remainingWidth = geometry.size.width - startX

      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 2)
          .fill(Color(hex: "E7E7E7"))

        RoundedRectangle(cornerRadius: 6)
          .fill(color)
          .frame(width: remainingWidth, height: 6)
          .offset(x: startX)
      }
      .frame(height: geometry.size.height)
    }
  }
}

private struct TargetLegendItem: View {
  let category: TargetCategoryProgress

  var body: some View {
    HStack(spacing: 2) {
      Circle()
        .fill(category.color)
        .frame(width: 4, height: 4)

      Text(category.name)
        .font(.custom("Figtree", size: 8).weight(.medium))
        .foregroundColor(Color(hex: "333333"))
        .lineLimit(1)
        .fixedSize()
    }
  }
}

private struct TargetIconBubble: View {
  enum Kind {
    case focus
    case distraction
  }

  let kind: Kind

  var body: some View {
    ZStack {
      Circle()
        .fill(Color(hex: "E7E7E7"))
        .overlay(
          Circle()
            .stroke(Color(hex: "FCF9F6"), lineWidth: 2)
        )

      switch kind {
      case .focus:
        assetImage("DayGoalFocus")
          .frame(width: 25, height: 26)

      case .distraction:
        assetImage("DayGoalDistraction")
          .frame(width: 23, height: 23)
      }
    }
  }

  private func assetImage(_ name: String) -> some View {
    Image(name)
      .resizable()
      .scaledToFit()
  }
}

private struct TargetLegendTail: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let slant: CGFloat = min(rect.width * 0.12, 28)

    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - slant, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX + 6, y: rect.maxY))
    path.closeSubpath()

    return path
  }
}

#Preview("Day Goal Header") {
  DayGoalHeader(
    focusTargetDuration: 4.5 * 60 * 60,
    focusDuration: 2 * 60 * 60,
    focusCategories: [
      TargetCategoryProgress(
        id: "research",
        name: "Research",
        colorHex: "8BAAFF",
        duration: 52 * 60
      ),
      TargetCategoryProgress(
        id: "coding",
        name: "Coding",
        colorHex: "CF8FFF",
        duration: 46 * 60
      ),
      TargetCategoryProgress(
        id: "code-review",
        name: "Code review",
        colorHex: "90DDF0",
        duration: 28 * 60
      ),
      TargetCategoryProgress(
        id: "debugging",
        name: "Debugging",
        colorHex: "6E66D4",
        duration: 0
      ),
    ],
    distractionLimitDuration: 2 * 60 * 60,
    distractedDuration: 25 * 60,
    recordingControlMode: .active,
    onSetGoals: {}
  )
  .frame(width: 360, height: 213)
}
