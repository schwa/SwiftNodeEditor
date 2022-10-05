import CoreGraphics
import SwiftUI

public protocol NodeProtocol: Identifiable {
    associatedtype Socket: SocketProtocol
    var position: CGPoint { get set }
    // TODO: Can add same socket twice. Need an OrderedSet
    var sockets: [Socket] { get set }
}

// TODO: You cannot go from Sockets to other types. This could be an issue for implementors - but there's no reason implementors can't provide this themselves.
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

    associatedtype NodeContent: View
    associatedtype WireContent: View
    associatedtype SocketContent: View
    // TODO: PinContent

    func content(for node: Binding<Node>, configuration: NodeConfiguration) -> NodeContent

    // TODO: Not used yet.
    func content(for wire: Binding<Wire>, configuration: WireConfiguration) -> WireContent

    // TODO: Not used yet.
    func content(for socket: Binding<Socket>) -> SocketContent

    // TODO: content(for pin:)
}

public struct NodeConfiguration {
    @Binding
    public var selected: Bool
}

public struct WireConfiguration {
    public let active: Bool
    public let start: CGPoint
    public let end: CGPoint
}

/*
 TODO: Use Style style protocols instead of content(for:)

  public protocol ButtonStyle {
     associatedtype Body : View
     @ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body
     typealias Configuration = ButtonStyleConfiguration
 }

 public struct ButtonStyleConfiguration {
     /// A type-erased label of a button.
     public struct Label : View {
         public typealias Body = Never
     }

     public let role: ButtonRole?
     public let label: ButtonStyleConfiguration.Label
     public let isPressed: Bool
 }
 */
