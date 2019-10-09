**CLASS**

# `Reducer`

```swift
public class Reducer<A: Action>: Disposable
```

> The `Reducer` defines the behavior to be executed when a certain
> `Action` object is received.

## Properties
### `action`

```swift
public let action: A.Type
```

> The `Action` type which the `Reducer` listens to.

### `dispatcher`

```swift
public let dispatcher: Dispatcher
```

> The `Dispatcher` object that sends the `Action` objects.

### `reducer`

```swift
public let reducer: (A) -> Void
```

> The behavior to be executed when the `Dispatcher` sends a certain `Action`

## Methods
### `init(of:on:reducer:)`

```swift
public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void)
```

> Initializes a new `Reducer` object.
> - Parameter action: The `Action` type that will be listened to.
> - Parameter dispatcher: The `Dispatcher` that sends the `Action`.
> - Parameter reducer: The closure that will be executed when the `Dispatcher`
> sends the defined `Action` type.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | The `Action` type that will be listened to. |
| dispatcher | The `Dispatcher` that sends the `Action`. |
| reducer | The closure that will be executed when the `Dispatcher` sends the defined `Action` type. |

### `dispose()`

```swift
public func dispose()
```

> Dispose resource.
