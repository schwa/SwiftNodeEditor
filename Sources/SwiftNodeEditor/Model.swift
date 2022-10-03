import CoreGraphics
import SwiftUI

public protocol NodeProtocol: Identifiable {
    associatedtype Socket: SocketProtocol
    var name: String { get set }
    var position: CGPoint { get set }
    var sockets: [Socket] { get set }
}

// TODO: You cannot go from Node -> Socket -> Wire -> Socket -> Node. This is an issue.
public protocol WireProtocol: Identifiable, Equatable {
    associatedtype Socket: SocketProtocol
    var sourceSocket: Socket { get }
    var destinationSocket: Socket { get }

    init(sourceSocket: Socket, destinationSocket: Socket)
}

public protocol SocketProtocol: Identifiable, Hashable {
}

// MARK: -

public protocol PresentationProtocol {
    associatedtype Node: NodeProtocol
    associatedtype Wire: WireProtocol
    associatedtype NodeContent: View
    associatedtype WireContent: View
    func content(for node: Binding<Node>) -> NodeContent

    // TODO: This is likely NOT the presentation we use. Perhaps a view modifier instead.
    func content(for wire: Binding<Wire>) -> WireContent
}

struct ActiveWire <Socket, Wire>: Equatable where Wire: WireProtocol, Wire.Socket == Socket {
    let startLocation: CGPoint
    let endLocation: CGPoint
    let startSocket: Socket
    let existingWire: Wire?

    init(startLocation: CGPoint, endLocation: CGPoint, startSocket: Socket, existingWire: Wire?) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startSocket = startSocket
        self.existingWire = existingWire
    }
}
