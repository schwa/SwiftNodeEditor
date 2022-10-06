import SwiftNodeEditor
import SwiftUI

public struct NodeGraphEditorDemoView: View {
    @Binding
    var document: GraphDocument

    @StateObject
    var model = CanvasModel()

    enum PresentationMode {
        case basic
        case radial
    }

    @State
    var presentationMode: PresentationMode = .basic

    @State
    var selection: Set<MyNode.ID> = []

    public init(document: Binding<GraphDocument>) {
        _document = document
        presentationMode = .basic
    }

    public var body: some View {
        Group {
            #if os(macOS)
                HSplitView {
                    editorView
                        .frame(minWidth: 320, minHeight: 240)
                        .layoutPriority(1)

                    detailView
                        .ignoresSafeArea(.all, edges: .top)
                }
            #elseif os(iOS)
                editorView
            #endif
        }
        .toolbar {
            toolbar
        }
        .environmentObject(model)
        .onAppear {
            model.nodes = document.nodes
            model.wires = document.wires
        }
        .onReceive(model.objectWillChange) {
            document.nodes = model.nodes
            document.wires = model.wires
        }
    }

    @ViewBuilder
    var toolbar: some View {
        Button(systemImage: "plus") {
            model.nodes.append(MyNode(position: CGPoint(x: 100, y: 100)))
        }

        Button(systemImage: "paintpalette") {
            model.nodes = model.nodes.map {
                var node = $0
                node.color = Color(hue: Double.random(in: 0 ..< 1), saturation: 1, brightness: 1)
                return node
            }
            model.wires = model.wires.map {
                var wire = $0
                wire.color = Color(hue: Double.random(in: 0 ..< 1), saturation: 1, brightness: 1)
                return wire
            }
        }

        Picker("Mode", selection: $presentationMode) {
            Text("Basic").tag(PresentationMode.basic)
            Text("Radial").tag(PresentationMode.radial)
        }
        .pickerStyle(MenuPickerStyle())
    }

    @ViewBuilder
    var editorView: some View {
        Group {
            switch presentationMode {
            case .basic:
                NodeGraphEditorView(nodes: $model.nodes, wires: $model.wires, selection: $selection, presentation: BasicPresentation())
            case .radial:
                NodeGraphEditorView(nodes: $model.nodes, wires: $model.wires, selection: $selection, presentation: RadialPresentation())
            }
        }
        .backgroundStyle(.gray.opacity(0.05))
    }

    @ViewBuilder
    var detailView: some View {
        if let id = model.selection.first {
            let binding = Binding<MyNode> {
                model.nodes.first { id == $0.id }!
            }
            set: { node in
                let index = model.nodes.firstIndex(where: { $0.id == node.id })!
                model.nodes[index] = node
            }
            NodeInfoView(node: binding)
        }
    }
}

// MARK: -

struct NodeInfoView: View {
    @Binding
    var node: MyNode

    var body: some View {
        VStack {
            TextField("Node", text: $node.name)
            ColorPicker("Color", selection: $node.color).fixedSize()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
