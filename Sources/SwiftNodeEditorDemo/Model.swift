import Foundation
import SwiftNodeEditor
import SwiftUI

public struct MyNode: Identifiable, NodeProtocol, Codable {
    public var id = UUID()
    public var name: String
    public var position: CGPoint
    public var sockets: OrderedIDSet<MySocket> = [
        Socket(),
        Socket(),
    ]
    public var color: Color = .mint

    public init(position: CGPoint) {
        name = "Node \(LolID())"
        self.position = position
    }
}

public struct MyWire: WireProtocol, Codable {
    public var id = UUID()
    public var color: Color
    public let sourceSocket: MySocket
    public let destinationSocket: MySocket

    public init(sourceSocket: MySocket, destinationSocket: MySocket) {
        color = .black
        self.sourceSocket = sourceSocket
        self.destinationSocket = destinationSocket
    }

    public init(color: Color, sourceSocket: MySocket, destinationSocket: MySocket) {
        self.color = color
        self.sourceSocket = sourceSocket
        self.destinationSocket = destinationSocket
    }
}

public struct MySocket: SocketProtocol, Codable {
    public var id = UUID()

    public init() {}
}

// MARK: -

public class CanvasModel: ObservableObject {
    @Published
    public var nodes: OrderedIDSet<MyNode> = [] // TODO: We do a lot of brute force lookup via id - make into a "ordered id set" type container

    @Published
    public var wires: OrderedIDSet<MyWire> = [] // TODO: We do a lot of brute force lookup via id - make into a "ordered id set" type container

    @Published
    public var selection: Set<MyNode.ID> = []

    public init() {
        nodes = [
            MyNode(position: CGPoint(x: 100, y: 100)),
            MyNode(position: CGPoint(x: 200, y: 100)),
            MyNode(position: CGPoint(x: 300, y: 100)),
            MyNode(position: CGPoint(x: 100, y: 200)),
            MyNode(position: CGPoint(x: 200, y: 200)),
            MyNode(position: CGPoint(x: 300, y: 200)),
        ]
        wires = [
            MyWire(sourceSocket: nodes[0].sockets[0], destinationSocket: nodes[1].sockets[0]),
        ]
    }
}

public struct Graph: Codable {
    public var nodes: [MyNode] = []
    public var wires: [MyWire] = []
}
