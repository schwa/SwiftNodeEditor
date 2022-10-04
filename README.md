# SwiftNodeEditor

A package of SwiftUI code for making node editors
## Screenshot

<!-- ![Screenshot 1](Documentation/Screenshot%201.png) -->
![Screen Recording 1](Documentation/Screen%20Recording%201.gif)


## Usage

1. `import SwiftNodeEditor`
2. Conform your model types to `NodeProtocol` (nodes contain pins), `PinProtocol` (pins are connected by wires) and `WireProtocol`.
3. Implement a `PresentationProtocol` to control how your model types are presented and can be interacted with.
4. Embed a `NodeGraphEditorView` in your SwiftUI view hierarchy and provide it with your model types and presentation protocol.

See SwiftNodeEditorDemo for a complex example showing multiple presentation protocols and several ways of interacting with your objects.

## License

See [LICENSE.md](LICENSE.md).

## Caveats

See [CAVEAT.md](CAVEAT.md).

## TODO

- [ ] Grep code for TODOs & fix 'em.
- [ ] Make demo a document-based app with JSON serialization.
- [ ] Add tools to layout nodes.
- [ ] Add more streamlined HI for adding nodes.
- [ ] Add better z-layer behaviour.
- [ ] Unit tests for model-layer.
- [ ] Documentation.
- [ ] Get rid of weird underscore naming with generics.
- [ ] Add presentation for pins.
- [ ] Add presentation for wires(?).
- [ ] Make demo labels editable.
- [ ] Labels on wires.
- [ ] Remove dependency on Everything.
