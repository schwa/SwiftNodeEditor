import SwiftNodeEditor
import SwiftUI

struct BasicPresentation: PresentationProtocol {
    func content(for node: Binding<MyNode>) -> some View {
        NodeView(node: node)
    }

    func content(for wire: Binding<MyWire>, configuration: WireConfiguration) -> some View {
        WireView(wire: wire, configuration: configuration)
    }

    func content(for socket: Binding<MySocket>) -> some View {
        EmptyView()
    }

    struct NodeView: View {
        @Binding
        var node: MyNode

        @Environment(\.nodeSelected)
        var selected

        @EnvironmentObject
        private var model: CanvasModel

        var body: some View {
            VStack {
                Text(verbatim: node.name)
                HStack {
                    ForEach(node.sockets) { socket in
                        SocketView<BasicPresentation>(node: _node, socket: socket)
                            .contextMenu(for: .constant(socket), of: $node)
                    }
                    Button {
                        node.sockets.append(MySocket())
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
            .background(selected ? Color.accentColor.cornerRadius(18) : Color.white.opacity(0.75).cornerRadius(16))
            .contextMenu(for: $node)
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
