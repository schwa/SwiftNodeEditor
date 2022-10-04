import Foundation

// TODO: use LolUID from Everything
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
