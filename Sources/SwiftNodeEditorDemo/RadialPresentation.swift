import SwiftNodeEditor
import SwiftUI

struct RadialPresentation: PresentationProtocol {
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
            let radius = 36.0
            let angle = Angle(degrees: 360 / Double(node.sockets.count + 1))
            let enumeration = Array(node.sockets.enumerated())

            return ZStack {
                Text(verbatim: node.name)
                ZStack {
                    Button {
                        node.sockets.append(MySocket())
                    }
                    label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .background(Circle().fill(Color.white))
                    .offset(angle: angle * 0, radius: radius)
                    ForEach(enumeration, id: \.0) { index, socket in
                        SocketView<RadialPresentation>(node: _node, socket: socket)
                            .offset(angle: angle * Double(index + 1), radius: radius)
                            .contextMenu(for: .constant(socket), of: $node)
                    }
                }
            }
            .background(Circle().fill(node.color).frame(width: radius * 2, height: radius * 2))
            .background(Circle().fill(selected ? Color.accentColor : Color.white.opacity(0.75)).frame(width: radius * 2 + 8, height: radius * 2 + 8))
            .contextMenu(for: $node)
        }
    }
}

extension View {
    func offset(angle: Angle, radius: CGFloat) -> some View {
        offset(x: cos(angle.radians) * radius, y: sin(angle.radians) * radius)
    }
}
