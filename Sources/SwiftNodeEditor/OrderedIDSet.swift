import Collections
import Foundation

public struct OrderedIDSet<Element> where Element: Identifiable {
    typealias Storage = OrderedDictionary<Element.ID, Element>
    var storage = Storage()
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

// MARK: -

public extension OrderedIDSet {
    init<C>(_ elements: C) where C: Collection, C.Element == Element {
        storage = .init(uniqueKeysWithValues: elements.map { ($0.id, $0) })
    }

    mutating func insert(_ element: Element) {
        storage[element.id] = element
    }

    subscript(id id: Element.ID) -> Element? {
        get {
            storage[id]
        }
        set {
            storage[id] = newValue
        }
    }
}

public extension OrderedIDSet where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        storage[element.id] == element
    }
}
