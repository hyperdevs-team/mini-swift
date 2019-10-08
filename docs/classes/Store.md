**CLASS**

# `Store`

```swift
public class Store<State: StateType, StoreController: Disposable>: ObservableType, StoreType
```

## Properties
### `objectWillChange`

```swift
public var objectWillChange: ObjectWillChangePublisher
```

### `dispatcher`

```swift
public let dispatcher: Dispatcher
```

### `storeController`

```swift
public var storeController: StoreController
```

### `state`

```swift
public var state: State
```

### `initialState`

```swift
public var initialState: State
```

### `reducerGroup`

```swift
public var reducerGroup: ReducerGroup
```

## Methods
### `init(_:dispatcher:storeController:)`

```swift
public init(_ state: State,
            dispatcher: Dispatcher,
            storeController: StoreController)
```

### `notify()`

```swift
public func notify()
```

### `replayOnce()`

```swift
public func replayOnce()
```

### `reset()`

```swift
public func reset()
```

### `subscribe(_:)`

```swift
public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Store.Element
```
