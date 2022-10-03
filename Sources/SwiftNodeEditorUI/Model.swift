import Foundation
import SwiftNodeEditor
import SwiftUI

public struct MyNode: Identifiable, NodeProtocol {
    public let id = LolID()
    public var name: String
    public var position: CGPoint
    public var sockets: [MySocket] = [
        Socket(),
        Socket(),
    ]
    public var color: Color = .mint

    public init(position: CGPoint) {
        name = "Node \(id)"
        self.position = position
    }
}

public struct MyWire: WireProtocol {
    public let id = LolID()
    public var color: Color
    public let sourceSocket: MySocket
    public let destinationSocket: MySocket

    public init(sourceSocket: MySocket, destinationSocket: MySocket) {
        self.color = .black
        self.sourceSocket = sourceSocket
        self.destinationSocket = destinationSocket
    }

    public init(color: Color, sourceSocket: MySocket, destinationSocket: MySocket) {
        self.color = color
        self.sourceSocket = sourceSocket
        self.destinationSocket = destinationSocket
    }
}

public struct MySocket: SocketProtocol {
    public let id = LolID()

    public init() {}
}

public class CanvasModel: ObservableObject {
    @Published
    public var nodes: [MyNode] = [] // TODO: We do a lot of brute force lookup via id - make into a "ordered id set" type container

    @Published
    public var wires: [MyWire] = [] // TODO: We do a lot of brute force lookup via id - make into a "ordered id set" type container

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
