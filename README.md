# Mini-Swift
The minimal expression of a Flux architecture in Swift.

Mini is built with be a first class citizen in Swift applications: **macOS, iOS and tvOS** applications.
With Mini, you can create a thread-safe application with a predictable unidirectional data flow, focusing on what really matters: build awesome applications.

[![Release Version](https://img.shields.io/github/release/bq/mini-swift.svg)](https://github.com/bq/mini-swift/releases) 
[![Release Date](https://img.shields.io/github/release-date/bq/mini-swift.svg)](https://github.com/bq/mini-swift/releases)
[![Pod](https://img.shields.io/cocoapods/v/Mini-Swift.svg?style=flat)](https://cocoapods.org/pods/Mini-Swift)
[![Platform](https://img.shields.io/cocoapods/p/Mini-Swift.svg?style=flat)](https://cocoapods.org/pods/Mini-Swift)
[![GitHub](https://img.shields.io/github/license/bq/mini-swift.svg)](https://github.com/bq/mini-swift/blob/master/LICENSE)

[![Build Status](https://travis-ci.org/bq/mini-swift.svg?branch=5.0)](https://travis-ci.org/bq/mini-swift)
[![codecov](https://codecov.io/gh/bq/mini-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/bq/mini-swift)

## Requirements

* Xcode 10 or later
* Swift 5.0 or later
* iOS 11 or later
* macOS 10.13 or later
* tvOS 11 or later

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

- Create a Package.swift file.

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "MiniSwiftProject",
  dependencies: [
    .package(url: "https://github.com/bq/mini-swift.git"),
  ],
  targets: [
    .target(name: "MiniSwiftProject", dependencies: ["Mini"])
  ]
)
```
```
$ swift build
```

### [Cocoapods](https://cocoapods.org/)

- Add this to you `Podfile`:

```
pod "Mini-Swift"
```

- We also offer two subpecs for logging and testing:
```
pod "Mini-Swift/Log"
pod "Mini-Swift/Test"
```


## Usage

- **MiniSwift** is a library which aims the ease of the usage of a Flux oriented architecture for Swift applications. Due its Flux-based nature, it heavily relies on some of its concepts like **Store**, **State**, **Dispatcher**, **Action**, **Task** and **Reducer**.

![Architecture](https://i.imgur.com/DioR3i0.png)

### State

- The minimal unit of the architecture is based on the idea of the **State**. **State** is, as its name says, the representation of a part of the application in a moment of time.

- The **State** is a simple `struct` which is conformed of different **Promises** that holds the individual pieces of information that represents the current state, this can be implemented as follows.

- For example:

```swift
struct MyCoolState: State {
    let cool: Promise<Bool>

    init(cool: Promise<Bool> = .idle()) {
        self.cool = cool
    }

    // Conform to State protocol
    func isEqual(to other: State) -> Bool {
        guard let state = other as? MyCoolState else { return false }
        return self.cool == state.cool
    }
}
```

- The default inner state of a `Promise` is `idle`. It means that no `Action` (see more below), has started any operation over that `Promise`.

- A `Promise` can hold any kind of aditional properties that the developer might encounter useful for its implementation, for example, hold a `Date` for cache usage:

```swift
let promise: Promise<Bool> = .idle()
promise.date = Date()
// Later on...
let date: Date = promise.date
```

- The core idea of a `State` is its [immutability](https://en.wikipedia.org/wiki/Immutable_object), so once created, no third-party objects are able to mutate it out of the control of the architecture flow.

- As can be seen in the example, a `State`  has a pair of  `Task` + `Result`  *usually* (that can be any object, if any), which is related with the execution of the `Task`. In the example above, `CoolTask` is responsible, through its `Reducer` to fulfill the `Action` with the `Task` result and furthermore, the new `State`.

### Action

- An `Action` is the piece of information that is being dispatched through the architecture. Any `class` can conform to the `Action` protocol, with the only requirement of being unique its name per application.

```swift
class RequestContactsAccess: Action {
  // As simple as this is.
}
```

- `Action`s are free of have some pieces of information attached to them, that's why **Mini** provides the user with two main utility protocols: `CompletableAction`, `EmptyAction` and `KeyedPayloadAction`.

    - A `CompletableAction` is a specialization of the `Action` protocol, which allows the user attach both a `Task` and some kind of object that gets fulfilled when the `Task` succeeds.

    ```swift
    class RequestContactsAccessResult: CompletableAction {

      let requestContactsAccessPromise: Promise<Bool?>

      typealias Payload = Bool

      required init(promise: Promise<Bool?>) {
          self.requestContactsAccessPromise = task
      }
    }
    ```
    - An `EmptyAction` is a specialization of `CompletableAction` where the `Payload` is a `Swift.Never`, this means it only has associated a `Task`.

    ```swift
    class ActivateVoucherLoaded: EmptyAction {

      let activateVoucherPromise: Promise<()>

      required init(promise: Promise<()>) {
          self.activateVoucherPromise = task
      }
    }
    ```
    - A `KeyedPayloadAction`, adds a `Key` (which is `Hashable`) to the `CompletableAction`. This is a special case where the same `Action` produces results that can be grouped together, tipically, under a `Dictionary` (i.e., an `Action` to search contacts, and grouped by their main phone number).

    ```swift
    class RequestContactLoadedAction: KeyedCompletableAction {

      typealias Payload = CNContact
      typealias Key = String

      let requestContactPromise: [Key: Promise<Payload?>]

      required init(promise: [Key: Promise<Payload?>]) {
          self.requestContactPromise = promise
      }
    }
    ```
### Store

- A `Store` is the hub where decissions and side-efects are made through the ingoing and outgoing `Action`s. A `Store` is a generic class to inherit from and associate a `State` for it.

- A `Store` may produce `State` changes that can be observed like any other **RxSwift**'s `Observable`. In this way a `View`, or any other object of your choice, can receive new `State`s produced by a certain `Store`.

- A `Store` reduces the flow of a certain amount of `Action`s through the `var reducerGroup: ReducerGroup` property.

- The `Store` is implemented in a way that has two generic requirements, a `State: StateType` and a `StoreController: Disposable`. The `StoreController` is usually a class that contains the logic to perform the `Actions` that might be intercepted by the store, i.e, a group of URL requests, perform a database query, etc.

- Through generic specialization, the `reducerGroup` variable can be rewritten for each case of pair `State` and `StoreController` without the need of subclassing the `Store`.

```swift
extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        return ReducerGroup { [
            Reducer(of: OneTestAction.self, on: self.dispatcher) { action in
                self.state = self.state.copy(testPromise: *.value(action.counter))
            }
        ] }
    }
}
```

- In the snippet above, we have a complete example of how a `Store` would work. We use the `ReducerGroup` to indicate how the `Store` will intercept `Action`s of type `OneTestAction` and that everytime it gets intercepted, the `Store`'s `State` gets copied (is not black magic 🧙‍, is through a set of [Sourcery](https://github.com/krzysztofzablocki/Sourcery) scripts that are distributed with this package). 

> If you are using SPM or Carthage, they doesn't really allow to distribute assets with the library, in that regard we recommend to just install `Sourcery` in your project and use the templates that can be downloaded directly from the repository under the `Templates` directory.

- When working with `Store` instances, you may retain a strong reference of its `reducerGroup`, this is done using the `subscribe()`  method, which is a `Disposable` that can be used like below:

```swift
var bag = DisposeBag()
let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController())
store
    .subscribe()
    .disposed(by: bag)
```

### Dispatcher

- The last piece of the architecture is the `Dispatcher`. In an application scope, there should be only one `Dispatcher` alive from which every action is being dispatched.

```swift
let action = TestAction()
dispatcher.dispatch(action, mode: .sync)
```

- With one line, we can notify every `Store` which has defined a reducer for that type of `Action`.

### Advanced usage

- **Mini** is built over a request-response unidirectional flow. This is achieved using pair of `Action`, one for making the request of a change in a certain `State`, and another `Action` to mutate the `State` over the result of the operation being made.

- This is much simplier to explain with a code example:

```swift
// We define our state in first place:
struct TestState: StateType {
    // Our state is defined over the Promise of an Integer type.
    let counter: Promise<Int>

    init(counter: Promise<Int> = .idle()) {
        self.counter = counter
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        return true
    }
}

// We define our actions, one of them represents the request of a change, the other one the response of that change requested.

// This is the request
class SetCounterAction: Action {

    let counter: Int

    init(counter: Int) {
        self.counter = counter
    }

    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterAction else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

// This is the response
class SetCounterActionLoaded: Action {
    
    let counter: Int
    
    init(counter: Int) {
        self.counter = counter
    }
    
    public func isEqual(to other: Action) -> Bool {
        guard let action = other as? SetCounterActionLoaded else { return false }
        guard counter == action.counter else { return false }
        return true
    }
}

// As you can see, both seems to be the same, same parameters, initializer, etc. But next, we define our StoreController.

// The StoreController define the side-effects that an Action might trigger.
class TestStoreController: Disposable {
    
    let dispatcher: Dispatcher
    
    init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
    }
    
    // This function dispatches (always in a async mode) the result of the operation, just giving out the number to the dispatcher.
    func counter(_ number: Int) {
        self.dispatcher.dispatch(SetCounterActionLoaded(counter: number), mode: .async)
    }
    
    public func dispose() {
        // NO-OP
    }
}

// Last, but not least, the Store definition with the Reducers
extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        return ReducerGroup { [
          // We set the state with a Promise as .pending, someone has to fill the requirement later on. This represents the Request.
            Reducer(of: SetCounterAction.self, on: self.dispatcher) { action in
                guard !self.state.counter.isOnProgress else { return }
                self.state = TestState(counter: .pending())
                self.storeController.counter(action.counter)
            },
          // Next we receive the Action dispatched by the StoreController with a result, we must fulfill our Promise and notify the store for the State change. This represents the Response.
            Reducer(of: SetCounterActionLoaded.self, on: self.dispatcher) { action in
                self.state.counter
                    .fulfill(action.counter)
                    .notify(to: self)
            }
        ]
        }
    }
}
```

## Authors & Collaborators

* **[Edilberto Lopez Torregrosa](https://github.com/ediLT)**
* **[Raúl Pedraza León](https://github.com/r-pedraza)**
* **[Jorge Revuelta](https://github.com/minuscorp)**
* **[Francisco García Sierra](https://github.com/FrangSierra)**
* **[Pablo Orgaz](https://github.com/pabloogc)**
* **[Sebastián Varela](https://github.com/sebastianvarela)**

## License

Mini-Swift is available under the Apache 2.0. See the LICENSE file for more info.
