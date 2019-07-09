# Mini-Swift
The re-imagined Re-Flux architecture for Swift.

[![Release Version](https://img.shields.io/github/release/bq/mini-swift.svg)](https://github.com/bq/mini-swift/releases) 
[![Release Date](https://img.shields.io/github/release-date/bq/mini-swift.svg)](https://github.com/bq/mini-swift/releases)
[![Pod](https://img.shields.io/cocoapods/v/Mini-Swift.svg?style=flat)](https://cocoapods.org/pods/Mini-Swift)
[![Platform](https://img.shields.io/cocoapods/p/Mini-Swift.svg?style=flat)](https://cocoapods.org/pods/Mini-Swift)
[![GitHub](https://img.shields.io/github/license/bq/mini-swift.svg)](https://github.com/bq/mini-swift/blob/master/LICENSE)

[![Build Status](https://travis-ci.org/bq/mini-swift.svg?branch=master)](https://travis-ci.org/bq/mini-swift)
[![codecov](https://codecov.io/gh/bq/mini-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/bq/mini-swift)

## Requirements

* Xcode 11
* Swift 5.1

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

- Create a Package.swift file.

```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "MiniSwiftProject",
  dependencies: [
    .package(url: "https://github.com/bq/mini-swift.git", from: "1.0.0")
  ],
  targets: [
    .target(name: "MiniSwiftProject", dependencies: ["MiniSwift"])
  ]
)
```
```
$ swift build
```

## Usage

- **MiniSwift** is a library which aims the ease of the usage of a Flux oriented architecture for Swift applications. Due its Flux-based nature, it heavily relies on some of its concepts like **Store**, **State**, **Dispatcher**, **Action**, **Task** and **Reducer**.

- The minimal unit of the architecture is based on the idea of the **State**. **State** is, as its name says, the representation of a part of the application in a moment of time.

- The **State** is a simple `struct` which is conformed of different **Tasks** and different pieces of data that are potentially fulfilled by the execution of those tasks.

- For example:

```swift
struct MyCoolState: State {
    let cool: Bool?
    let coolTask: Task

    init(cool: Bool = nil,
         coolTask: Task = Task()
        ) {
        self.cool = cool
        self.coolTask = coolTask
    }

    // Conform to State protocol
    func isEqual(to other: State) -> Bool {
        guard let state = other as? MyCoolState else { return false }
        return self.cool == state.cool && self.coolTask == state.coolState
    }
}
```

- The core idea of a **State** is its [immutability](https://en.wikipedia.org/wiki/Immutable_object), so once created, no third-party objects are able to mutate it out of the control of the architecture flow.

*[...]*

## Authors & Collaborators

* **[Edilberto Lopez Torregrosa](https://github.com/ediLT)**
* **[Raúl Pedraza León](https://github.com/r-pedraza)**
* **[Jorge Revuelta](https://github.com/minuscorp)**
* **[Francisco García Sierra](https://github.com/FrangSierra)**
* **[Pablo Orgaz](https://github.com/pabloogc)**
* **[Sebastián Varela](https://github.com/sebastianvarela)**

## License

Mini-Swift is available under the Apache 2.0. See the LICENSE file for more info.
