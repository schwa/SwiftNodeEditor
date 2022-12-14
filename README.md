# SwiftNodeEditor

A package of SwiftUI code for making node editors

## Screenshot

![Screen Recording 1](Documentation/Screen%20Recording%201.gif)

## Usage

1. `import SwiftNodeEditor`
2. Conform your model types to `NodeProtocol` (nodes contain sockets), `SocketProtocol` (sockets are connected with wires) and `WireProtocol`.
3. Implement a `PresentationProtocol` to control how your model types are presented and can be interacted with.
4. Embed a `NodeGraphEditorView` in your SwiftUI view hierarchy and provide it with your model types and presentation protocol.

See SwiftNodeEditorDemo for a complex example showing multiple presentation protocols and several ways of interacting with your objects.

## License

See [LICENSE.md](LICENSE.md).

## Caveats

This project is (currently) undergoing active development and its API surface area is not yet stable.

See also [CAVEAT.md](CAVEAT.md).

## TODO

### High Priority

- [ ] Grep code for TODOs & fix 'em.
- [ ] Remove dependency on Everything (may need to put Everything's CoreGraphics in a new package?)
- [ ] That GeometryReader makes it hard for wire/pin presentation to work without hard-coding size. (Would a layout help?)
- [ ] Documentation.
- [ ] Fix project structure - the app and demo package should be merged.
- [ ] Simple demo.
- [X] Add presentation for pins.
- [X] Cannot debug in Xcode 14.0 beta 3 (TODO: file a feedback report).
- [X] Add presentation for sockets.
- [X] Add presentation for wires.

### Nice to Have

- [ ] The differences in the 'content(for:)' api are weird 
- [ ] It's silly that both pins and sockets need to register the same drag gesture - make one gesture and raise it above.
- [ ] Interface protocols only need to be Identifiable not Hashable also.
- [ ] Socket sizes are hard-coded.
- [ ] Pins are not the same colours as their wires.
- [ ] Add presentation for pins.
- [ ] Investigating use NodeStyle/WireStyle etc inside Presentation
- [ ] Turn README's TODO list into GitHub issues.
- [ ] Add tools to layout nodes.
- [ ] Add more streamlined HI for adding nodes.
- [ ] Add better z-layer behaviour.
- [ ] Unit tests for model-layer.
- [ ] Labels on wires.
- [ ] Marquee-based selection.
- [ ] Keyboard shortcuts.
- [ ] The Demo app needs a List representation.
- [ ] Selector mechanism for sockets and wires (can I connect this wire to this socket?)
- [ ] Many-to-many sockets
- [ ] Use OrderedSet (from swift-collections) in correct places.
- [ ] Use more from macOS13/iOS16 in this (layouts, backgroundStyle, etc?)
- [X] Make demo a document-based app with JSON serialization.
- [X] Make demo labels editable.
- [X] Get rid of weird underscore naming with generics.
