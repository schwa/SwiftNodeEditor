// swiftlint:disable file_length

import Everything
import SwiftUI

public struct NodeGraphEditorView<Presentation>: View where Presentation: PresentationProtocol {
    // TODO: This is NOT a StateObject - it should be.
    let model: Model<Presentation>

    public init(nodes: Binding<[Presentation.Node]>, wires: Binding<[Presentation.Wire]>, selection: Binding<Set<Presentation.Node.ID>>, presentation: Presentation) {
        model = Model<Presentation>(nodes: nodes, wires: wires, selection: selection, presentation: presentation)
    }

    public var body: some View {
        NodeGraphEditorView_()
            .environmentObject(model)
    }

    struct NodeGraphEditorView_: View {
        typealias Node = Presentation.Node
        typealias Wire = Presentation.Wire
        typealias Socket = Presentation.Socket

        @EnvironmentObject
        var model: Model<Presentation>

        @State
        var activeWire: ActiveWire<Presentation>?

        @State
        var socketGeometries: [Socket: CGRect]?

        @Environment(\.backgroundStyle)
        var backgroundStyle

        var body: some View {
            ZStack {
                Rectangle().fill(backgroundStyle ?? AnyShapeStyle(.white))
                    .onTapGesture {
                        model.selection = []
                    }
                NodesView<Presentation>()
                socketGeometries.map { socketGeometries in
                    WiresView<Presentation>(wires: model.$wires, socketGeometries: socketGeometries)
                }
                socketGeometries.map { socketGeometries in
                    activeWire.map { ActiveWireView<Presentation>(activeWire: $0, socketGeometries: socketGeometries) }
                }
            }
            .coordinateSpace(name: CoordinateSpace.canvasName)
            .onPreferenceChange(ActiveWirePreferenceKey<Presentation>.self) { activeWire in
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
}

// MARK: Node Views

internal struct NodesView<Presentation>: View where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    @EnvironmentObject
    var model: Model<Presentation>

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
            NodeInteractionView<Presentation>(node: nodeBinding, selected: selectedBinding)
                .position(x: node.position.x, y: node.position.y)
        }
    }
}

internal struct NodeInteractionView<Presentation>: View where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    @EnvironmentObject
    var model: Model<Presentation>

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
            .content(for: _node, configuration: NodeConfiguration(selected: _selected))
            .gesture(dragGesture())
            .onTapGesture {
                selected.toggle()
            }
    }

    func dragGesture() -> some Gesture {
        DragGesture(coordinateSpace: .canvas)
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

// MARK: Wire Views

internal struct WiresView<Presentation>: View where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    @Binding
    var wires: [Wire]

    let socketGeometries: [Socket: CGRect]

    var body: some View {
        ForEach(wires) { wire in
            if let sourceRect = socketGeometries[wire.sourceSocket], let destinationRect = socketGeometries[wire.destinationSocket] {
                let index = wires.firstIndex(where: { wire.id == $0.id })!
                let binding = Binding(get: { wires[index] }, set: { wires[index] = $0 })
                WireView<Presentation>(wire: binding, start: sourceRect.midXMidY, end: destinationRect.midXMidY)
            }
        }
    }
}

internal struct WireView<Presentation>: View where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    @EnvironmentObject
    var model: Model<Presentation>

    @Binding
    var wire: Wire

    let start: CGPoint
    let end: CGPoint

    @State
    var activeWire: ActiveWire<Presentation>?

    var body: some View {
        let configuration = WireConfiguration(active: activeWire?.existingWire == wire, start: start, end: end)
        ChromeView(wire: _wire, configuration: configuration)
            .onPreferenceChange(ActiveWirePreferenceKey<Presentation>.self) { activeWire in
                self.activeWire = activeWire
            }
            .contextMenu {
                Button("Delete") {
                    model.wires.removeAll(where: { wire.id == $0.id })
                }
            }
    }

    struct ChromeView: View {
        @Binding
        var wire: Wire

        @EnvironmentObject
        var model: Model<Presentation>

        let configuration: WireConfiguration

        var body: some View {
            model.presentation.content(for: _wire, configuration: configuration)
                .overlay(PinView<Presentation>(wire: _wire, socket: wire.sourceSocket, location: configuration.start))
                .overlay(PinView<Presentation>(wire: _wire, socket: wire.destinationSocket, location: configuration.end))
                .opacity(configuration.active ? 0.33 : 1)
        }
    }
}

internal struct ActiveWireView<Presentation>: View where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    let start: CGPoint
    let end: CGPoint
    let color: Color

    init(activeWire: ActiveWire<Presentation>, socketGeometries: [ActiveWireView<Presentation>.Socket: CGRect]) {
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
        AnimatedWire(start: start, end: end, foreground: color)
    }
}

// MARK: Socket Views

public struct SocketView<Presentation>: View where Presentation: PresentationProtocol {
    public typealias Node = Presentation.Node
    public typealias Socket = Presentation.Socket

    @Binding
    var node: Node

    @EnvironmentObject
    var model: Model<Presentation>

    let socket: Socket

    public init(node: Binding<Node>, socket: Socket) {
        self.socket = socket
        _node = node
    }

    public var body: some View {
        WireDragSource(presentationType: Presentation.self, socket: socket, existingWire: nil) {
            GeometryReader { geometry in
                model.presentation.content(for: socket)
                    .preference(key: SocketGeometriesPreferenceKey<Socket>.self, value: [socket: geometry.frame(in: .canvas)])
            }
            .frame(width: 16, height: 16)
        }
    }
}

// MARK: Pin Views

internal struct PinView<Presentation>: View where Presentation: PresentationProtocol {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    @EnvironmentObject
    var model: Model<Presentation>

    @Binding
    var wire: Wire

    let socket: Socket
    let location: CGPoint

    var body: some View {
        WireDragSource(presentationType: Presentation.self, socket: socket, existingWire: wire) {
            model.presentation.content(forPin: socket)
                .offset(location)
        }
    }
}

// MARK: Misc views

internal struct WireDragSource<Presentation, Content>: View where Presentation: PresentationProtocol, Content: View {
    typealias Node = Presentation.Node
    typealias Wire = Presentation.Wire
    typealias Socket = Presentation.Socket

    let socket: Socket
    let existingWire: Wire?
    let content: () -> Content

    @EnvironmentObject
    var model: Model<Presentation>

    @Environment(\.onActiveWireDragEnded)
    var onActiveWireDragEnded

    @State
    var activeWire: ActiveWire<Presentation>?

    @State
    var dragging = false

    // TODO: presentationType is a hack to allow us to create WireDragSources without having to specify both types.
    init(presentationType: Presentation.Type, socket: Socket, existingWire: Wire?, content: @escaping () -> Content) {
        self.socket = socket
        self.existingWire = existingWire
        self.content = content
    }

    var body: some View {
        content()
            .preference(key: ActiveWirePreferenceKey<Presentation>.self, value: activeWire)
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

private extension CoordinateSpace {
    static let canvasName = "canvas"
    static let canvas = CoordinateSpace.named(canvasName)
}

