**CLASS**

# `Dispatcher`

```swift
public final class Dispatcher
```

## Properties
### `subscriptionCount`

```swift
public var subscriptionCount: Int
```

## Methods
### `init()`

```swift
public init()
```

### `add(middleware:)`

```swift
public func add(middleware: Middleware)
```

### `remove(middleware:)`

```swift
public func remove(middleware: Middleware)
```

### `register(service:)`

```swift
public func register(service: Service)
```

### `unregister(service:)`

```swift
public func unregister(service: Service)
```

### `subscribe(priority:tag:completion:)`

```swift
public func subscribe(priority: Int, tag: String, completion: @escaping (Action) -> Void) -> DispatcherSubscription
```

### `registerInternal(subscription:)`

```swift
public func registerInternal(subscription: DispatcherSubscription) -> DispatcherSubscription
```

### `unregisterInternal(subscription:)`

```swift
public func unregisterInternal(subscription: DispatcherSubscription)
```

### `subscribe(completion:)`

```swift
public func subscribe<T: Action>(completion: @escaping (T) -> Void) -> DispatcherSubscription
```

### `subscribe(tag:completion:)`

```swift
public func subscribe<T: Action>(tag: String, completion: @escaping (T) -> Void) -> DispatcherSubscription
```

### `subscribe(tag:completion:)`

```swift
public func subscribe(tag: String, completion: @escaping (Action) -> Void) -> DispatcherSubscription
```

### `dispatch(_:mode:)`

```swift
public func dispatch(_ action: Action, mode: Dispatcher.DispatchMode.UI)
```
