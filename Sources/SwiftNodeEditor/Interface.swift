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

public protocol ContextProtocol {
    associatedtype Node: NodeProtocol where Node.Socket == Socket
    associatedtype Wire: WireProtocol where Wire.Socket == Socket
    associatedtype Socket: SocketProtocol
    associatedtype Presentation: PresentationProtocol where Presentation.Node == Node
}

public protocol PresentationProtocol {
    associatedtype Node: NodeProtocol
    associatedtype Wire: WireProtocol
    associatedtype Socket: SocketProtocol

    associatedtype NodeContent: View
    associatedtype WireContent: View
    associatedtype SocketContent: View

    func content(for node: Binding<Node>) -> NodeContent

    // TODO: This is likely NOT the presentation we use. Perhaps a view modifier instead.
    func content(for wire: Binding<Wire>) -> WireContent

    func content(for socket: Binding<Socket>) -> SocketContent

}


// TODO: Maybe Internal?
public protocol ContextProvider {
    associatedtype Context: ContextProtocol
    typealias Node = Context.Node
    typealias Wire = Context.Wire
    typealias Socket = Context.Socket
    typealias Presentation = Context.Presentation
}
