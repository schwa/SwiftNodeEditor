import Foundation
import SwiftUI
import Algorithms

// TODO: use LolUID from Everything
public struct LolID: Hashable {
    private var rawValue: Int
    private static var nextValue: Int = 0
    private static var lock = os_unfair_lock_t()

    public init() {
        rawValue = LolID.lock.withLock {
            defer {
                LolID.nextValue += 1
            }
            return LolID.nextValue
        }
    }
}

extension LolID: CustomStringConvertible {
    public var description: String {
        "\(rawValue)"
    }
}

// MARK: -

extension UnsafeMutablePointer where Pointee == os_unfair_lock {
    init() {
        self = UnsafeMutablePointer.allocate(capacity: 1)
        initialize(to: os_unfair_lock())
    }

    func lock() {
        os_unfair_lock_lock(self)
    }

    func unlock() {
        os_unfair_lock_unlock(self)
    }

    func withLock<R>(_ transaction: () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try transaction()
    }
}

extension View {
    func offset(angle: Angle, radius: CGFloat) -> some View {
        offset(x: cos(angle.radians) * radius, y: sin(angle.radians) * radius)
    }
}

enum DynamicColor: String, RawRepresentable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown
    case white
    case gray
    case black
    case clear
    case primary
    case secondary

    init?(color: Color) {
        switch color {
        case .red:
            self = .red
        case .orange:
            self = .orange
        case .yellow:
            self = .yellow
        case .green:
            self = .green
        case .mint:
            self = .mint
        case .teal:
            self = .teal
        case .cyan:
            self = .cyan
        case .blue:
            self = .blue
        case .indigo:
            self = .indigo
        case .purple:
            self = .purple
        case .pink:
            self = .pink
        case .brown:
            self = .brown
        case .white:
            self = .white
        case .gray:
            self = .gray
        case .black:
            self = .black
        case .clear:
            self = .clear
        case .primary:
            self = .primary
        case .secondary:
            self = .secondary
        default:
            return nil
        }
    }

    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        case .white:
            return .white
        case .gray:
            return .gray
        case .black:
            return .black
        case .clear:
            return .clear
        case .primary:
            return .primary
        case .secondary:
            return .secondary
        }
    }
}

@available(macOS 13.0, *)
extension Color: Codable {
    public func encode(to encoder: Encoder) throws {
        if let dynamicColor = DynamicColor(color: self) {
            var container = encoder.singleValueContainer()
            try container.encode(dynamicColor.rawValue)
        }
        else {
            guard let cgColor else {
                fatalError()
            }
            // TODO: This assumes RGBA
            guard let components = cgColor.components else {
                fatalError()
            }
            let hex = "#" + components.map { UInt8($0 * 255) }.map { ("0" + String($0, radix: 16)).suffix(2) }.joined()
            var container = encoder.singleValueContainer()
            try container.encode(hex)
        }
    }

    public init(from decoder: Decoder) throws {
        // This is one way of extract three integers from a string :-)
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        if let dynamicColor = DynamicColor(rawValue: string) {
            self = dynamicColor.color
        }
        else {
            guard string.hasPrefix("#") else {
                fatalError()
            }
            let stringComponents = string.dropFirst(1)
            let components: [CGFloat]
            switch stringComponents.count {
            case 3:
                components = stringComponents.map { UInt8(String($0), radix: 16)! }.map { CGFloat($0) / 255 }
            case 6, 8:
                components = stringComponents.chunks(ofCount: 2).map { UInt8(String($0), radix: 16)! }.map { CGFloat($0) / 255 }
            default:
                fatalError()
            }
            let cgColor = CGColor(red: components[0], green: components[1], blue: components[2], alpha: components.count > 3 ? components[3] : 1.0)
            self = Color(cgColor: cgColor)
        }
    }
}
