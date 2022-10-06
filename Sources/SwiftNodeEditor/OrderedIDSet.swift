import Collections
import Foundation

public struct OrderedIDSet<Element> where Element: Identifiable {
    fileprivate typealias Storage = OrderedDictionary<Element.ID, Element>
    fileprivate var storage = Storage()
}

// MARK: -

extension OrderedIDSet: Sequence {
    public typealias Iterator = AnyIterator<Element>

    public func makeIterator() -> Iterator {
        AnyIterator(storage.values.makeIterator())
    }
}

extension OrderedIDSet: Collection {
    public typealias Index = Int

    public var count: Int {
        storage.count
    }

    public var isEmpty: Bool {
        storage.isEmpty
    }

    public var startIndex: Index {
        storage.values.startIndex
    }

    public var endIndex: Index {
        storage.values.endIndex
    }

    public subscript(position: Index) -> Element {
        get {
            storage.values[position]
        }
        set {
            storage.values[position] = newValue
        }
    }

    public func index(after i: Index) -> Index {
        storage.values.index(after: i)
    }
}

extension OrderedIDSet: RandomAccessCollection {
}

// MARK: -

public extension OrderedIDSet {
    init<C>(_ elements: C) where C: Collection, C.Element == Element {
        storage = .init(uniqueKeysWithValues: elements.map { ($0.id, $0) })
    }

    mutating func insert(_ element: Element) {
        storage[element.id] = element
    }

    mutating func remove(_ element: Element) {
        storage[element.id] = nil
    }

    subscript(id id: Element.ID) -> Element? {
        get {
            storage[id]
        }
        set {
            storage[id] = newValue
        }
    }

    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try storage.removeAll { key, value in
            return try shouldBeRemoved(value)
        }
    }
}

public extension OrderedIDSet where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        storage[element.id] == element
    }
}

extension OrderedIDSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self = .init(elements)
    }
}

extension OrderedIDSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Array(self))
    }
}

extension OrderedIDSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode(Array<Element>.self)
        self = .init(elements)
    }
}
