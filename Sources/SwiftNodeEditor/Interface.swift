import CoreGraphics
import SwiftUI

public protocol NodeProtocol: Identifiable {
    associatedtype Socket: SocketProtocol
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
    associatedtype Node: NodeProtocol where Node.Socket == Socket
    associatedtype Wire: WireProtocol where Wire.Socket == Socket
    associatedtype Socket: SocketProtocol
    // TODO: Pin: PinProtocol

    // TODO: Use ViewModifiers here instead of Views?

    associatedtype NodeContent: View
    associatedtype WireContent: View
    associatedtype SocketContent: View
    // TODO: PinContent

    func content(for node: Binding<Node>) -> NodeContent

    // TODO: Not used yet.
    func content(for wire: Binding<Wire>) -> WireContent

    // TODO: Not used yet.
    func content(for socket: Binding<Socket>) -> SocketContent

    // TODO: content(for pin:)
}
