import Foundation
import RegexBuilder
import SwiftNodeEditor
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let nodeGraph = UTType(exportedAs: "io.schwa.nodegraph") // TODO:
}

public struct GraphDocument: FileDocument {
    public static let readableContentTypes: [UTType] = [.nodeGraph]

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
