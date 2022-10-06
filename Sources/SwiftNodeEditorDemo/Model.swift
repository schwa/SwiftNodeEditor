import Foundation
import RegexBuilder
import SwiftNodeEditor
import SwiftUI
import UniformTypeIdentifiers

public struct MyNode: Identifiable, NodeProtocol, Codable {
    public var id = UUID()
    public var name: String
    public var position: CGPoint
    public var sockets: [MySocket] = [
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

enum DynamicColor: String, RawRepresentable, CaseIterable {
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case mint = "mint"
    case teal = "teal"
    case cyan = "cyan"
    case blue = "blue"
    case indigo = "indigo"
    case purple = "purple"
    case pink = "pink"
    case brown = "brown"
    case white = "white"
    case gray = "gray"
    case black = "black"
    case clear = "clear"
    case primary = "primary"
    case secondary = "secondary"

    init?(color: Color) {
        switch color {
        case .red:
            self = .red
        case .orange:
            self = .orange
        case .yellow:
            self = .yellow
        case .green:
            self = .green
        case .mint:
            self = .mint
        case .teal:
            self = .teal
        case .cyan:
            self = .cyan
        case .blue:
            self = .blue
        case .indigo:
            self = .indigo
        case .purple:
            self = .purple
        case .pink:
            self = .pink
        case .brown:
            self = .brown
        case .white:
            self = .white
        case .gray:
            self = .gray
        case .black:
            self = .black
        case .clear:
            self = .clear
        case .primary:
            self = .primary
        case .secondary:
            self = .secondary
        default:
            return nil
        }
    }

    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        case .white:
            return .white
        case .gray:
            return .gray
        case .black:
            return .black
        case .clear:
            return .clear
        case .primary:
            return .primary
        case .secondary:
            return .secondary
        }
    }
}

@available(macOS 13.0, *)
extension Color: Codable {
    public func encode(to encoder: Encoder) throws {
        if let dynamicColor = DynamicColor(color: self) {
            var container = encoder.singleValueContainer()
            try container.encode(dynamicColor.rawValue)
        }
        else {
            guard let cgColor else {
                fatalError()
            }
            guard let components = cgColor.components else {
                fatalError()
            }
            let hex = "#" + components.map { UInt8($0 * 255) }.map { ("0" + String($0, radix: 16)).suffix(2) }.joined()
            var container = encoder.singleValueContainer()
            try container.encode(hex)
        }
    }

    public init(from decoder: Decoder) throws {
        // This is one way of extract three integers from a string :-)
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        if let dynamicColor = DynamicColor(rawValue: string) {
            self = dynamicColor.color
        }
        else {
            guard string.hasPrefix("#") else {
                fatalError()
            }
            let stringComponents = string.dropFirst(1)
            let components: [CGFloat]
            switch stringComponents.count {
            case 3:
                components = stringComponents.split(by: 1).map { UInt8($0, radix: 16)! }.map { CGFloat($0) / 255 }
            case 6, 8:
                components = stringComponents.split(by: 2).map { UInt8($0, radix: 16)! }.map { CGFloat($0) / 255 }
            default:
                fatalError()
            }
            let cgColor = CGColor(red: components[0], green: components[1], blue: components[2], alpha: components.count > 3 ? components[3] : 1.0)
            self = Color(cgColor: cgColor)
        }
    }

    //    public init(from decoder: Decoder) throws {
//        // This is one way of extract three integers from a string :-)
//        let container = try decoder.singleValueContainer()
//        let hex = try container.decode(String.self)
//        enum Component {
//            static let red = Reference(Substring.self)
//            static let green = Reference(Substring.self)
//            static let blue = Reference(Substring.self)
//        }
//        let regex = Regex {
//            Anchor.startOfLine
//            Anchor.startOfLine
//            "#"
//            Capture(as: Component.red) {
//                One(.digit)
//            }
//            Capture(as: Component.green) {
//                One(.digit)
//            }
//            Capture(as: Component.blue) {
//                One(.digit)
//            }
//            Anchor.endOfLine
//        }
//        guard let match = try regex.firstMatch(in: hex) else {
//            fatalError()
//        }
//        guard let red = UInt8(match[Component.red]).map({ CGFloat($0) }),
//            let green = UInt8(match[Component.red]).map({ CGFloat($0) }),
//            let blue = UInt8(match[Component.red]).map({ CGFloat($0) }) else {
//            fatalError()
//        }
//        let cgColor = CGColor(red: red, green: green, blue: blue, alpha: 1.0)
//        self = Color(cgColor: cgColor)
//    }
}

public struct Graph: Codable {
    public var nodes: [MyNode] = []
    public var wires: [MyWire] = []
}

public struct GraphDocument: FileDocument {
    public static let readableContentTypes: [UTType] = [
        UTType(exportedAs: "io.schwa.nodegraph") // TODO
    ]

    public var nodes: [MyNode] = []
    public var wires: [MyWire] = []

    public init() {
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            fatalError()
        }

        let graph = try JSONDecoder().decode(Graph.self, from: data)
        nodes = graph.nodes

        wires = graph.wires
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let graph = Graph(nodes: nodes, wires: wires)
        let data = try JSONEncoder().encode(graph)
        return .init(regularFileWithContents: data)
    }
}
