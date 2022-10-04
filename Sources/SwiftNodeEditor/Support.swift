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
