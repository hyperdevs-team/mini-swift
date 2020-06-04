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
[![Documentation](https://img.shields.io/badge/Documentation-passing-green.svg)](http://opensource.bq.com/mini-swift/docs/)

## Requirements

* Xcode 10 or later
* Swift 5.0 or later
* iOS 11 or later
* macOS 10.13 or later
* tvOS 11 or later

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

- Create a `Package.swift` file.

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "MiniSwiftProject",
  dependencies: [
    .package(url: "https://github.com/bq/mini-swift.git"),
  ],
  targets: [
    .target(name: "MiniSwiftProject", dependencies: ["Mini" /*, "MiniPromises, MiniTasks"*/])
  ]
)
```
- Mini comes with a bare implementation and two external utility packages in order to ease the usage of the library named `MiniTasks` and `MiniPromises`, both dependant on the `Mini` base or core package.

```
$ swift build
```

### [Cocoapods](https://cocoapods.org/)

- Add this to you `Podfile`:

```
pod "Mini-Swift"
# pod "Mini-Swift/MiniPromises"
# pod "Mini-Swift/MiniTasks"
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
// If you're using MiniPromises
struct MyCoolState: StateType {
    let cool: Promise<Bool>
}

// If you're using MiniTasks
struct MyCoolState: StateType {
    let cool: Bool?
    let coolTask: AnyTask
}
```

- The default inner state of a `Promise` is `idle`. On the other hand, the default inner state of a `Task` is `idle` as well. This means that no `Action` (see more below), has started any operation over that `Promise` or `Task`.

- Both `Promise` and `Task` can hold any kind of aditional properties that the developer might encounter useful for its implementation, for example, hold a `Date` for cache usage:

```swift
let promise: Promise<Bool> = .idle()
promise.date = Date()
// Later on...
let date: Date = promise.date

let task: AnyTask = .idle()
task.date = Date()
// Later on...
let date: Date = task.date
```

- The core idea of a `State` is its [immutability](https://en.wikipedia.org/wiki/Immutable_object), so once created, no third-party objects are able to mutate it out of the control of the architecture flow.

- As can be seen in the example, a `State` has a pair of  `Task` + `Result`  *usually* (that can be any object, if any), which is related with the execution of the `Task`. In the example above, `CoolTask` is responsible, through its `Reducer` to fulfill the `Action` with the `Task` result and furthermore, the new `State`.

- Furthermore, the `Promise` object unifies the _Status_ + _Result_ tuple, so it can store both the status of an ongoing task and the associated payload produced by it.

### Action

- An `Action` is the piece of information that is being dispatched through the architecture. Any `struct` can conform to the `Action` protocol, with the only requirement of being unique its name per application.

```swift
struct RequestContactsAccess: Action {
  // As simple as this is.
}
```

- `Action`s are free of have some pieces of information attached to them, that's why **Mini** provides the user with two main utility protocols: `CompletableAction`, `EmptyAction` and `KeyedPayloadAction`.

    - A `CompletableAction` is a specialization of the `Action` protocol, which allows the user attach both a `Task` and some kind of object that gets fulfilled when the `Task` succeeds.

    ```swift
    struct RequestContactsAccessResult: CompletableAction {
      let promise: Promise<Bool>

      typealias Payload = Bool
    }
    ```
    - An `EmptyAction` is a specialization of `CompletableAction` where the `Payload` is a `Swift.Void`, this means it only has associated a `Promise<Void>`.

    ```swift
    struct ActivateVoucherLoaded: EmptyAction {
      let promise: Promise<Void>
    }
    ```
    - A `KeyedPayloadAction`, adds a `Key` (which is `Hashable`) to the `CompletableAction`. This is a special case where the same `Action` produces results that can be grouped together, tipically, under a `Dictionary` (i.e., an `Action` to search contacts, and grouped by their main phone number).

    ```swift
    struct RequestContactLoadedAction: KeyedCompletableAction {

      typealias Payload = CNContact
      typealias Key = String

      let promise: [Key: Promise<Payload?>]
    }
    ```

> We take the advantage of using `struct`, so all initializers are automatically synthesized.

> Examples are done with `Promise`, but there're equivalent to be used with `Task`s.

### Store

- A `Store` is the hub where decissions and side-efects are made through the ingoing and outgoing `Action`s. A `Store` is a generic class to inherit from and associate a `State` for it.

- A `Store` may produce `State` changes that can be observed like any other **RxSwift**'s `Observable`. In this way a `View`, or any other object of your choice, can receive new `State`s produced by a certain `Store`.

- A `Store` reduces the flow of a certain amount of `Action`s through the `var reducerGroup: ReducerGroup` property.

- The `Store` is implemented in a way that has two generic requirements, a `State: StateType` and a `StoreController: Disposable`. The `StoreController` is usually a class that contains the logic to perform the `Actions` that might be intercepted by the store, i.e, a group of URL requests, perform a database query, etc.

- Through generic specialization, the `reducerGroup` variable can be rewritten for each case of pair `State` and `StoreController` without the need of subclassing the `Store`.

```swift
extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        return ReducerGroup(
            // Using Promises
            Reducer(of: OneTestAction.self, on: dispatcher) { action in
                self.state = self.state.copy(testPromise: *.value(action.counter))
            },
            // Using Tasks
            Reducer(of: OneTestAction.self, on: dispatcher) { action in
                self.state = self.state.copy(data: *action.payload, dataTask: *action.task)
            }
        )
    }
}
```

- In the snippet above, we have a complete example of how a `Store` would work. We use the `ReducerGroup` to indicate how the `Store` will intercept `Action`s of type `OneTestAction` and that everytime it gets intercepted, the `Store`'s `State` gets copied (is not black magic 🧙‍, is through a set of [Sourcery](https://github.com/krzysztofzablocki/Sourcery) scripts that are distributed with this package). 

> If you are using SPM or Carthage, they doesn't really allow to distribute assets with the library, in that regard we recommend to just install `Sourcery` in your project and use the templates that can be downloaded directly from the repository under the `Templates` directory.

- When working with `Store` instances, you may retain a strong reference of its `reducerGroup`, this is done using the `subscribe()`  method, which is a `Disposable` that can be used like below:

```swift
let bag = DisposeBag()
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

#### Using Promises

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
struct SetCounterAction: Action {
    let counter: Int
}

// This is the response
struct SetCounterActionLoaded: Action {
    let counter: Int
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
        ReducerGroup(
            // We can use Promises:
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
        )
    }
}
```

#### Using Tasks

```swift
// We define our state in first place:
struct TestState: StateType {
    // Our state is defined over the Promise of an Integer type.
    let counter: Int?
    let counterTask: AnyTask

    init(counter: Int = nil,
         counterTask: AnyTask = .idle()) {
        self.counter = counter
        self.counterTask = counterTask
    }

    public func isEqual(to other: StateType) -> Bool {
        guard let state = other as? TestState else { return false }
        guard counter == state.counter else { return false }
        guard counterTask == state.counterTask else { return false }
        return true
    }
}

// We define our actions, one of them represents the request of a change, the other one the response of that change requested.

// This is the request
struct SetCounterAction: Action {
    let counter: Int
}

// This is the response
struct SetCounterActionLoaded: Action {
    let counter: Int
    let counterTask: AnyTask
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
        self.dispatcher.dispatch(
            SetCounterActionLoaded(counter: number, 
            counterTask: .success()
            ),
            mode: .async)
    }
    
    public func dispose() {
        // NO-OP
    }
}

// Last, but not least, the Store definition with the Reducers
extension Store where State == TestState, StoreController == TestStoreController {

    var reducerGroup: ReducerGroup {
        ReducerGroup(
            // We can use Tasks:
            // We set the state with a Task as .running, someone has to fill the requirement later on. This represents the Request.
            Reducer(of: SetCounterAction.self, on: dispatcher) { action in
                guard !self.state.counterTask.isRunning else { return }
                self.state = TestState(counterTask: .running())
                self.storeController.counter(action.counter)
            },
            // Next we receive the Action dispatched by the StoreController with a result, we must fulfill our Task and update the data associated with the execution of it on the State. This represents the Response.
            Reducer(of: SetCounterActionLoaded.self, on: dispatcher) { action in
                guard self.state.rawCounterTask.isRunning else { return }
                self.state = TestState(counter: action.counter, counterTask: action.counterTask)
            }
        )
    }
}
```

## Documentation

All the documentation available can be found **[here](http://github.com/bq/mini-swift/tree/master/docs)**

## Maintainers

* **[Jorge Revuelta](https://github.com/minuscorp)**
* **[Francisco García Sierra](https://github.com/FrangSierra)**

## Authors & Collaborators

* **[Edilberto Lopez Torregrosa](https://github.com/ediLT)**
* **[Raúl Pedraza León](https://github.com/r-pedraza)**
* **[Pablo Orgaz](https://github.com/pabloogc)**
* **[Sebastián Varela](https://github.com/sebastianvarela)**

## License
```
   Copyright 2019 BQ

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
