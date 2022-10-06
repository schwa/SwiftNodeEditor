import Foundation
import SwiftUI

internal class Model<Presentation>: ObservableObject where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    @Binding
    var nodes: [Node]

    @Binding
    var wires: [Wire]

    @Binding
    var selection: Set<Node.ID>

    let presentation: Presentation

    init(nodes: Binding<[Node]>, wires: Binding<[Wire]>, selection: Binding<Set<Node.ID>>, presentation: Presentation) {
        _nodes = nodes
        _wires = wires
        _selection = selection
        self.presentation = presentation
    }
}


// MARK: PreferenceKeys & EnvironmentKeys (& relevant modifiers)

// MARK: SocketGeometriesPreferenceKey

internal struct SocketGeometriesPreferenceKey<Socket>: PreferenceKey where Socket: SocketProtocol {
    typealias Value = [Socket: CGRect]

    static var defaultValue: Value {
        [:]
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { _, rhs in
            rhs
        }
    }
}

// MARK: onActiveWireDragEnded

internal struct OnActiveWireDragEndedKey: EnvironmentKey {
    typealias Value = (() -> Void)?
    static var defaultValue: Value = nil
}

extension EnvironmentValues {
    var onActiveWireDragEnded: OnActiveWireDragEndedKey.Value {
        get {
            self[OnActiveWireDragEndedKey.self]
        }
        set {
            self[OnActiveWireDragEndedKey.self] = newValue
        }
    }
}

internal struct OnActiveWireDragEndedModifier: ViewModifier {
    let value: OnActiveWireDragEndedKey.Value

    func body(content: Content) -> some View {
        content.environment(\.onActiveWireDragEnded, value)
    }
}

extension View {
    func onActiveWireDragEnded(value: OnActiveWireDragEndedKey.Value) -> some View {
        modifier(OnActiveWireDragEndedModifier(value: value))
    }
}

// MARK: ActiveWire

struct ActiveWire<Presentation>: Equatable where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    let startLocation: CGPoint
    let endLocation: CGPoint
    let startSocket: Socket
    let existingWire: Wire?

    init(startLocation: CGPoint, endLocation: CGPoint, startSocket: Socket, existingWire: Wire?) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startSocket = startSocket
        self.existingWire = existingWire
    }
}

// MARK: ActiveWirePreferenceKey

struct ActiveWirePreferenceKey<Presentation>: PreferenceKey where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    static var defaultValue: ActiveWire<Presentation>? {
        nil
    }

    static func reduce(value: inout ActiveWire<Presentation>?, nextValue: () -> ActiveWire<Presentation>?) {
        value = nextValue() ?? value
    }
}
