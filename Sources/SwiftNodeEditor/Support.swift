import Foundation
import SwiftUI

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

public struct LolID: Hashable {
    var rawValue: Int

    static var nextValue: Int = 0

    static var lock = os_unfair_lock_t()

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
        return "\(rawValue)"
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

    func withLock <R>(_ transaction: () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try transaction()
    }
}

extension View {
    func loggingPreference<K>(key: K.Type = K.self, value: K.Value) -> some View where K: PreferenceKey {
        print("SET PREFERENCES", key)
        return preference(key: key, value: value)
    }
}
