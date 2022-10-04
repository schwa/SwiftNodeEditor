import SwiftNodeEditor
import SwiftUI

struct BasicPresentation: PresentationProtocol {
    func content(for node: Binding<MyNode>) -> some View {
        NodeView(node: node)
    }
    func content(for wire: Binding<MyWire>) -> some View {
        EmptyView()
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
}
