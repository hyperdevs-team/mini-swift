**CLASS**

# `Reducer`

```swift
public class Reducer<A: Action>: Disposable
```

## Properties
### `action`

```swift
public let action: A.Type
```

### `dispatcher`

```swift
public let dispatcher: Dispatcher
```

### `reducer`

```swift
public let reducer: (A) -> Void
```

## Methods
### `init(of:on:reducer:)`

```swift
public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void)
```

### `dispose()`

```swift
public func dispose()
```
