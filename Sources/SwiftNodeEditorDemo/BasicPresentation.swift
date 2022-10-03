import SwiftNodeEditor
import SwiftUI

struct BasicPresentation: PresentationProtocol {
    func content(for node: Binding<MyNode>) -> some View {
        NodeChromeView(node: node)
    }
    func content(for wire: Binding<MyWire>) -> some View {
        EmptyView()
    }

    struct NodeChromeView: View {
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
                        SocketView<MyNode, MyWire, MySocket>(node: _node, socket: socket)
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
