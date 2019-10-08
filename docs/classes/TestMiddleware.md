**CLASS**

# `TestMiddleware`

```swift
public class TestMiddleware: Middleware
```

> Interceptor class for testing purposes which mute all the received actions.

## Properties
### `id`

```swift
public var id: UUID = UUID()
```

### `perform`

```swift
public var perform: MiddlewareChain
```

## Methods
### `init()`

```swift
public init()
```

### `contains(action:)`

```swift
public func contains(action: Action) -> Bool
```

> Check if a given action have been intercepted before by the Middleware.
>
> - Parameter action: action to be checked
> - Returns: returns true if an action with the same params have been intercepted before.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | action to be checked |

### `actions(of:)`

```swift
public func actions<T: Action>(of kind: T.Type) -> [T]
```

> Check for actions of certain type being intercepted.
>
> - Parameter kind: Action type to be checked against the intercepted actions.
> - Returns: Array of actions of `kind` being intercepted.

#### Parameters

| Name | Description |
| ---- | ----------- |
| kind | Action type to be checked against the intercepted actions. |

### `clear()`

```swift
public func clear()
```

> Clear all the intercepted actions
