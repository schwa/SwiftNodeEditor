import SwiftNodeEditor
import SwiftUI

struct RadialPresentation: PresentationProtocol {
    func content(for node: Binding<MyNode>, configuration: NodeConfiguration) -> some View {
        NodeView(node: node, configuration: configuration)
    }

    func content(for wire: Binding<MyWire>, configuration: WireConfiguration) -> some View {
        WireView(wire: wire, configuration: configuration)
    }

    func content(for socket: MySocket) -> some View {
        Circle().stroke(Color.black, lineWidth: 4)
            .background(Circle().fill(Color.white))
    }

    func content(forPin socket: MySocket) -> some View {
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

        var body: some View {
            let radius = 36.0
            let angle = Angle(degrees: 360 / Double(node.sockets.count + 1))
            let enumeration = Array(node.sockets.enumerated())

            return ZStack {
                Text(verbatim: node.name)
                ZStack {
                    Button {
                        node.sockets.insert(MySocket())
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
            .background(Circle().fill(configuration.selected ? Color.accentColor : Color.white.opacity(0.75)).frame(width: radius * 2 + 8, height: radius * 2 + 8))
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
