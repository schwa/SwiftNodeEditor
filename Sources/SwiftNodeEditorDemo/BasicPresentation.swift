import SwiftNodeEditor
import SwiftUI

struct BasicPresentation: PresentationProtocol {
    func content(for node: Binding<MyNode>, configuration: NodeConfiguration) -> some View {
        NodeView(node: node, configuration: configuration)
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

        let configuration: NodeConfiguration

        @State
        var editing: Bool = false

        @EnvironmentObject
        private var model: CanvasModel

        var body: some View {
            VStack {
                FinderStyleTextField(text: $node.name, isEditing: $editing)
                .frame(maxWidth: 160)
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

struct FinderStyleTextField: View {

    @Binding
    var text: String

    @Binding
    var isEditing: Bool

    var body: some View {
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
