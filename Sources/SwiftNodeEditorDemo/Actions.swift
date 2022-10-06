import Foundation
import SwiftNodeEditor
import SwiftUI

struct ContextMenuForNodeModifier: ViewModifier {
    @Binding
    var node: MyNode

    @EnvironmentObject
    private var model: CanvasModel

    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Delete") {
                model.nodes.remove(node)
                model.wires.removeAll { node.sockets.map(\.id).contains($0.destinationSocket.id) }
            }
            Divider()
            Text("Colour")
            Button(action: { node.color = Color(hue: Double.random(in: 0 ..< 1), saturation: 1, brightness: 1) }, label: { Text("Random") })
            Button(action: { node.color = Color.red }, label: { Text("Red") })
            Button(action: { node.color = Color.green }, label: { Text("Green") })
            Button(action: { node.color = Color.blue }, label: { Text("Blue") })
            Button(action: { node.color = Color.purple }, label: { Text("Purple") })
        }
    }
}

extension View {
    func contextMenu(for node: Binding<MyNode>) -> some View {
        modifier(ContextMenuForNodeModifier(node: node))
    }
}

struct ContextMenuForSocketModifier: ViewModifier {
    @Binding
    var socket: MySocket

    @Binding
    var node: MyNode

    @EnvironmentObject
    private var model: CanvasModel

    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Delete", action: {
                node.sockets.remove(socket)
                model.wires.removeAll { socket.id == $0.sourceSocket.id || socket.id == $0.destinationSocket.id }
            })
        }
    }
}

extension View {
    func contextMenu(for socket: Binding<MySocket>, of node: Binding<MyNode>) -> some View {
        modifier(ContextMenuForSocketModifier(socket: socket, node: node))
    }
}
