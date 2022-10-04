// swiftlint:disable file_length

import Everything
import SwiftUI

public struct NodeGraphEditorView <Node, Wire, Presentation>: View where Wire: WireProtocol, Node.Socket == Wire.Socket, Presentation: PresentationProtocol, Presentation.Node == Node {
    typealias Context = _Context<Node, Wire, Node.Socket, Presentation>

    let model: Model<Context>

    public init(nodes: Binding<[Node]>, wires: Binding<[Wire]>, selection: Binding<Set<Node.ID>>, presentation: Presentation) {
        model = Model<Context>(nodes: nodes, wires: wires, selection: selection, presentation: presentation)
    }

    public var body: some View {
        NodeGraphEditorView_<Context>()
            .environmentObject(model)
    }
}

// MARK: -

struct NodeGraphEditorView_ <Context>: View, ContextProvider where Context: ContextProtocol {
    @EnvironmentObject
    var model: Model<Context>

    @State
    var activeWire: ActiveWire<Socket, Wire>?

    @State
    var socketGeometries: [Socket: CGRect]?

    var body: some View {
        ZStack {
            Color.placeholderWhite
                .onTapGesture {
                    model.selection = []
                }
            NodesView<Context>()
            socketGeometries.map { socketGeometries in
                WiresView<Context>(wires: model.$wires, socketGeometries: socketGeometries)
            }
            socketGeometries.map { socketGeometries in
                activeWire.map { ActiveWireView<Context>(activeWire: $0, socketGeometries: socketGeometries) }
            }
        }
        .coordinateSpace(name: "canvas")
        .onPreferenceChange(ActiveWirePreferenceKey<Socket, Wire>.self) { activeWire in
            self.activeWire = activeWire
        }
        .onPreferenceChange(SocketGeometriesPreferenceKey<Socket>.self) { socketGeometries in
            self.socketGeometries = socketGeometries
        }
        .onActiveWireDragEnded {
            guard let activeWire else {
                fatalError("No active wire")
            }
            guard let socketGeometries else {
                fatalError("No socket geometries")
            }
            for (socket, frame) in socketGeometries {
                if frame.contains(activeWire.endLocation) {
                    model.wires.append(Wire(sourceSocket: activeWire.startSocket, destinationSocket: socket))
                    return
                }
            }
        }
    }
}

// MARK: NodesView

struct NodesView <Context>: View, ContextProvider where Context: ContextProtocol {
    @EnvironmentObject
    var model: Model<Context>

    var body: some View {
        ForEach(model.nodes) { node in
            let index = model.nodes.firstIndex(where: { node.id == $0.id })!
            let nodeBinding = Binding { model.nodes[index] } set: { model.nodes[index] = $0 }
            let selectedBinding = Binding {
                model.selection.contains(where: { $0 == node.id })
            }
            set: {
                if $0 {
                    model.selection = [node.id]
                }
                else {
                    model.selection.remove(node.id)
                }
            }
            NodeInteractionView<Context>(node: nodeBinding, selected: selectedBinding)
                .position(x: node.position.x, y: node.position.y)
        }
    }
}

// MARK: -

struct NodeInteractionView <Context>: View, ContextProvider where Context: ContextProtocol {
    @EnvironmentObject
    var model: Model<Context>

    @Binding
    var node: Node

    @Binding
    var selected: Bool

    @State
    var dragging = false

    @State
    var dragOffset: CGPoint = .zero

    var body: some View {
        model.presentation
            .content(for: _node)
            .nodeSelected(value: selected)
            .gesture(dragGesture())
            .onTapGesture {
                selected.toggle()
            }
    }

    func dragGesture() -> some Gesture {
        DragGesture(coordinateSpace: .named("canvas"))
            .onChanged { value in
                if dragging == false {
                    dragOffset = value.location - node.position
                }
                node.position = value.location - dragOffset
                dragging = true
            }
            .onEnded { _ in
                dragging = false
            }
    }
}

// MARK: -

struct WiresView <Context>: View, ContextProvider where Context: ContextProtocol {
    @Binding
    var wires: [Wire]

    let socketGeometries: [Socket: CGRect]

    var body: some View {
        ForEach(wires) { wire in
            if let sourceRect = socketGeometries[wire.sourceSocket], let destinationRect = socketGeometries[wire.destinationSocket] {
                let index = wires.firstIndex(where: { wire.id == $0.id })!
                let binding = Binding(get: { wires[index] }, set: { wires[index] = $0 })
                WireView<Context>(wire: binding, start: sourceRect.midXMidY, end: destinationRect.midXMidY)
            }
        }
    }
}

// MARK: -

struct WireView <Context>: View, ContextProvider where Context: ContextProtocol {
    @EnvironmentObject
    var model: Model<Context>

    @Binding
    var wire: Wire

    let start: CGPoint
    let end: CGPoint

    @State
    var activeWire: ActiveWire <Socket, Wire>?

    var body: some View {
        let active = activeWire?.existingWire == wire
        WireChromeView<Context>(wire: _wire, active: active, start: start, end: end)
        .onPreferenceChange(ActiveWirePreferenceKey<Socket, Wire>.self) { activeWire in
            self.activeWire = activeWire
        }
        .contextMenu {
            Button("Delete") {
                model.wires.removeAll(where: { wire.id == $0.id })
            }
        }
    }
}

// MARK: -

struct WireChromeView <Context>: View, ContextProvider where Context: ContextProtocol {
    @Binding
    var wire: Wire

// TODO: bundle into "WireState" and move into presentation

    let active: Bool
    let start: CGPoint
    let end: CGPoint

    var body: some View {
        let color = Color.placeholderBlack
        let path = Path.wire(start: start, end: end)
        path.stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .background(path.stroke(Color.placeholderWhite.opacity(0.75), style: StrokeStyle(lineWidth: 6, lineCap: .round)))
            .overlay(PinView<Context>(wire: _wire, socket: wire.sourceSocket, location: start))
            .overlay(PinView<Context>(wire: _wire, socket: wire.destinationSocket, location: end))
            .opacity(active ? 0.33 : 1)
    }
}

// MARK: -

struct PinView <Context>: View, ContextProvider where Context: ContextProtocol {
    @Binding
    var wire: Wire

    let socket: Socket

    let location: CGPoint

    var body: some View {
        let radius = 4
        WireDragSource(contextType: Context.self, socket: socket, existingWire: wire) {
            Path { path in
                path.addEllipse(in: CGRect(origin: location - CGPoint(x: radius, y: radius), size: CGSize(width: radius * 2, height: radius * 2)))
            }
            .fill(Color.placeholderBlack)
        }
    }
}

// MARK: -

struct WireDragSource <Context, Content>: View, ContextProvider where Context: ContextProtocol, Content: View {
    let socket: Socket
    let existingWire: Wire?
    let content: () -> Content

    @EnvironmentObject
    var model: Model<Context>

    @Environment(\.onActiveWireDragEnded)
    var onActiveWireDragEnded

    @State
    var activeWire: ActiveWire <Socket, Wire>?

    @State
    var dragging = false

    // TODO: contextType is a hack to allow us to create WireDragSources without having to specify both types.
    init(contextType: Context.Type, socket: Socket, existingWire: Wire? = nil, content: @escaping () -> Content) {
        self.socket = socket
        self.existingWire = existingWire
        self.content = content
    }

    var body: some View {
        content()
            .preference(key: ActiveWirePreferenceKey<Socket, Wire>.self, value: activeWire)
            .gesture(dragGesture())
    }

    func dragGesture() -> some Gesture {
        DragGesture(coordinateSpace: .named("canvas"))
            .onChanged { value in
                dragging = true

                activeWire = ActiveWire(startLocation: value.startLocation, endLocation: value.location, startSocket: socket, existingWire: existingWire)
            }
            .onEnded { _ in
                onActiveWireDragEnded?()
                dragging = false
                activeWire = nil
                if let existingWire = existingWire {
                    model.wires.removeAll { $0.id == existingWire.id }
                }
            }
    }
}

struct ActiveWireView <Context>: View, ContextProvider where Context: ContextProtocol {
    let start: CGPoint
    let end: CGPoint
    let color: Color

    init(activeWire: ActiveWire<Socket, Wire>, socketGeometries: [ActiveWireView<Context>.Socket: CGRect]) {
        var color: Color {
            for (_, frame) in socketGeometries {
                if frame.contains(activeWire.endLocation) {
                    return Color.placeholder1
                }
            }
            return Color.placeholderBlack
        }
        self.color = color

        var destinationSocket: Socket? {
            for (socket, frame) in socketGeometries {
                if frame.contains(activeWire.endLocation) {
                    return socket
                }
            }
            return nil
        }
        start = socketGeometries[activeWire.startSocket]!.midXMidY
        end = destinationSocket.map { socketGeometries[$0]! }.map(\.midXMidY) ?? activeWire.endLocation
    }

    var body: some View {
        AnimatedWire(start: start, end: end, color: color)
    }
}

// MARK: -

public struct SocketView <Node, Wire, Socket>: View where Node: NodeProtocol, Wire: WireProtocol, Socket == Node.Socket, Socket == Wire.Socket {
    @Binding
    var node: Node

    let socket: Socket

    public init(node: Binding<Node>, socket: Socket) {
        self.socket = socket
        self._node = node
    }

    typealias Context = _Context<Node, Wire, Socket, EmptyPresentation<Node, Wire, Socket>>

    public var body: some View {
        WireDragSource(contextType: Context.self, socket: socket) {
            GeometryReader { geometry in
                Circle().stroke(Color.placeholderBlack, lineWidth: 4)
                    .background(Circle().fill(Color.placeholderWhite))
                    .preference(key: SocketGeometriesPreferenceKey<Socket>.self, value: [socket: geometry.frame(in: .named("canvas"))])
            }
            .frame(width: 16, height: 16)
        }
    }
}

// MARK: -

struct AnimatedWire: View {
    let start: CGPoint
    let end: CGPoint
    @State
    var phase: CGFloat = 0
    let color: Color

    var body: some View {
        let path = Path.wire(start: start, end: end)
        path.stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10], dashPhase: phase))
            .onAppear {
                withAnimation(.linear.repeatForever(autoreverses: false)) {
                    phase -= 20
                }
            }
            .background(path.stroke(Color.placeholderWhite.opacity(0.75), style: StrokeStyle(lineWidth: 6, lineCap: .round)))
    }
}

// MARK: SocketGeometriesPreferenceKey

struct SocketGeometriesPreferenceKey <Socket>: PreferenceKey where Socket: SocketProtocol {
    typealias Value = [Socket: CGRect]

    static var defaultValue: Value {
        return [:]
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { _, rhs in
            rhs
        }
    }
}

// MARK: onActiveWireDragEnded

struct OnActiveWireDragEndedKey: EnvironmentKey {
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

struct OnActiveWireDragEndedModifier: ViewModifier {
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

// MARK: nodeSelected

public struct NodeSelectedKey: EnvironmentKey {
    public static var defaultValue = false
}

public extension EnvironmentValues {
    var nodeSelected: Bool {
        get {
            self[NodeSelectedKey.self]
        }
        set {
            self[NodeSelectedKey.self] = newValue
        }
    }
}

public struct NodeSelectedModifier: ViewModifier {
    public let value: Bool
    public func body(content: Content) -> some View {
        content.environment(\.nodeSelected, value)
    }
}

public extension View {
    func nodeSelected(value: Bool) -> some View {
        modifier(NodeSelectedModifier(value: value))
    }
}

// MARK: -

struct EmptyPresentation <Node, Wire, Socket>: PresentationProtocol where Node: NodeProtocol, Wire: WireProtocol, Socket: SocketProtocol {
    func content(for node: Binding<Node>) -> some View {
        EmptyView()
    }
    func content(for wire: Binding<Wire>) -> some View {
        EmptyView()
    }
    func content(for socket: Binding<Socket>) -> some View {
        EmptyView()
    }
}

struct _Context <Node, Wire, Socket, Presentation>: ContextProtocol where Wire: WireProtocol, Node.Socket == Wire.Socket, Presentation: PresentationProtocol, Presentation.Node == Node, Node.Socket == Socket {
    typealias Socket = Socket
    typealias Presentation = Presentation
}

// MARK: -

class Model <Context>: ObservableObject, ContextProvider where Context: ContextProtocol {
    @Binding
    var nodes: [Node]

    @Binding
    var wires: [Wire]

    @Binding
    var selection: Set<Node.ID>

    let presentation: Presentation

    init(nodes: Binding<[Node]>, wires: Binding<[Wire]>, selection: Binding<Set<Node.ID>>, presentation: Presentation) {
        self._nodes = nodes
        self._wires = wires
        self._selection = selection
        self.presentation = presentation
    }
}

// MARK: ActiveWire

struct ActiveWire <Socket, Wire>: Equatable where Wire: WireProtocol, Wire.Socket == Socket {
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

struct ActiveWirePreferenceKey <Socket, Wire>: PreferenceKey where Wire: WireProtocol, Wire.Socket == Socket {
    static var defaultValue: ActiveWire<Socket, Wire>? {
        return nil
    }

    static func reduce(value: inout ActiveWire<Socket, Wire>?, nextValue: () -> ActiveWire<Socket, Wire>?) {
        value = nextValue() ?? value
    }
}
