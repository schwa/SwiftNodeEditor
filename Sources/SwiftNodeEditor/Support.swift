import Collections
import Foundation
import SwiftUI

extension Color {
    // TODO: This is silly. Replace with presentation.
    static let placeholderBlack = Color.black
    static let placeholderWhite = Color.white
    static let placeholder1 = Color.purple
}

public extension Path {
    static func wire(start: CGPoint, end: CGPoint) -> Path {
        Path { path in
            path.move(to: start)
            if abs(start.x - end.x) < 5 {
                path.addLine(to: end)
            }
            else {
                path.addCurve(to: end, control1: CGPoint(x: (start.x + end.x) / 2, y: start.y), control2: CGPoint(x: (start.x + end.x) / 2, y: end.y))
            }
        }
    }
}

public struct AnimatedWire: View {
    let start: CGPoint
    let end: CGPoint
    let foreground: Color
    // TODO: Use Environment.backgroundStyle
    let background: Color

    @State
    var phase: CGFloat = 0

    public init(start: CGPoint, end: CGPoint, foreground: Color, background: Color = Color.white.opacity(0.75), phase: CGFloat = 0) {
        self.start = start
        self.end = end
        self.phase = phase
        self.foreground = foreground
        self.background = background
    }

    public var body: some View {
        let path = Path.wire(start: start, end: end)
        path.stroke(foreground, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10], dashPhase: phase))
            .onAppear {
                withAnimation(.linear.repeatForever(autoreverses: false)) {
                    phase -= 20
                }
            }
            .background(path.stroke(background, style: StrokeStyle(lineWidth: 6, lineCap: .round)))
    }
}

extension OrderedDictionary where Value: Identifiable, Key == Value.ID {
    @discardableResult
    mutating func insert(_ value: Value) -> (inserted: Bool, memberAfterIndex: Value) {
        if let oldMember = self[value.id] {
            self[value.id] = value
            return (false, oldMember)
        }
        else {
            self[value.id] = value
            return (true, value)
        }
    }
}
