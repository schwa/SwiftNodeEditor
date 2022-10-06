import SwiftNodeEditor
import SwiftUI

public struct BasicPresentation: PresentationProtocol {
    public func content(for node: Binding<MyNode>, configuration: NodeConfiguration) -> some View {
        NodeView(node: node, configuration: configuration)
    }

    public func content(for wire: Binding<MyWire>, configuration: WireConfiguration) -> some View {
        WireView(wire: wire, configuration: configuration)
    }

    public func content(for socket: MySocket) -> some View {
        Circle().stroke(Color.black, lineWidth: 4)
            .background(Circle().fill(Color.white))
    }

    public func content(forPin socket: MySocket) -> some View {
        let radius = 4
        return Path { path in
            path.addEllipse(in: CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: radius * 2, height: radius * 2)))
        }
        .fill(Color.black)
    }

    struct NodeView: View {
        @Binding
        var node: MyNode

        let configuration: NodeConfiguration

        @State
        var editing: Bool = false

        var body: some View {
            VStack {
                FinderStyleTextField(text: $node.name, isEditing: $editing)
                    .frame(maxWidth: 80)
                HStack {
                    ForEach(node.sockets) { socket in
                        SocketView<BasicPresentation>(node: _node, socket: socket)
                            .contextMenu(for: .constant(socket), of: $node)
                    }
                    Button {
                        node.sockets.insert(MySocket())
                    }
                    label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding()
            .cornerRadius(16)
            .background(node.color.cornerRadius(14))
            .padding(4)
            .background(configuration.selected ? Color.accentColor.cornerRadius(18) : Color.white.opacity(0.75).cornerRadius(16))
            .contextMenu(for: $node)
            .onChange(of: configuration.selected) { selected in
                if selected == false {
                    editing = false
                }
            }
            .onChange(of: editing) { editing in
                if editing == true {
                    configuration.selected = true
                }
            }
        }
    }

    struct WireView: View {
        @Binding
        var wire: MyWire

        let configuration: WireConfiguration

        var body: some View {
            let path = Path.wire(start: configuration.start, end: configuration.end)
            path.stroke(wire.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .background(path.stroke(Color.white.opacity(0.75), style: StrokeStyle(lineWidth: 6, lineCap: .round)))
        }
    }
}

public struct FinderStyleTextField: View {
    @Binding
    var text: String

    @Binding
    var isEditing: Bool

    public init(text: Binding<String>, isEditing: Binding<Bool>) {
        self._text = text
        self._isEditing = isEditing
    }

    public var body: some View {
        switch isEditing {
        case false:
            Text(verbatim: text)
                .onTapGesture {
                    isEditing = true
                }
        case true:
            TextField("text", text: _text)
        }
    }
}
