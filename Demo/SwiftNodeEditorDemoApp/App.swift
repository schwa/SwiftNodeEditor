import SwiftNodeEditorDemo
import SwiftUI

@main
struct SwiftNodeEditorDemoApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: GraphDocument()) { file in
            NodeGraphEditorDemoView(document: file.$document)
        }
    }
}
