import SwiftNodeEditor
import SwiftUI

public struct NodeGraphEditorDemoView: View {
    @StateObject
    var model = CanvasModel()

    enum PresentationMode {
        case basic
        case radial
    }

    @State
    var presentationMode: PresentationMode = .basic

    public init() {
    }

    public var body: some View {
        #if os(macOS)
        return HSplitView {
            // NodeGraphEditorView(nodes: $model.nodes, wires: $model.wires, selection: $model.selection, presentation: BasicPresentation())
            editorView()
            .frame(minWidth: 320, minHeight: 240)
            .layoutPriority(1)
            // TODO: mess
            model.selection.first.map { id in NodeInfoView(node: Binding(get: {
                model.nodes.first { id == $0.id }!
            }, set: { node in
                let index = model.nodes.firstIndex(where: { $0.id == node.id })!
                model.nodes[index] = node
            }))
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .toolbar {
            Button(action: { model.nodes.append(MyNode(position: CGPoint(x: 100, y: 100))) }, label: { Image(systemName: "plus") })
            Button(action: {
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
            }, label: { Image(systemName: "paintpalette") })
            Picker("Mode", selection: $presentationMode) {
                Text("Basic").tag(PresentationMode.basic)
                Text("Radial").tag(PresentationMode.radial)
            }
            .pickerStyle(MenuPickerStyle())
        }
        .environmentObject(model)
        #elseif os(iOS)
        editorView()
        .environmentObject(model)
        #endif
    }

    @ViewBuilder
    func editorView() -> some View {
        switch presentationMode {
        case .basic:
            NodeGraphEditorView(nodes: $model.nodes, wires: $model.wires, selection: $model.selection, presentation: BasicPresentation())
        case .radial:
            NodeGraphEditorView(nodes: $model.nodes, wires: $model.wires, selection: $model.selection, presentation: RadialPresentation())
        }
    }
}

// MARK: -

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
