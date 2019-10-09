**CLASS**

# `DispatcherSubscription`

```swift
public final class DispatcherSubscription: Comparable, Disposable
```

## Properties
### `id`

```swift
public let id: Int
```

### `tag`

```swift
public let tag: String
```

## Methods
### `init(dispatcher:id:priority:tag:completion:)`

```swift
public init(dispatcher: Dispatcher,
            id: Int,
            priority: Int,
            tag: String,
            completion: @escaping (Action) -> Void)
```

### `dispose()`

```swift
public func dispose()
```

### `on(_:)`

```swift
public func on(_ action: Action)
```

### `==(_:_:)`

```swift
public static func == (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `>(_:_:)`

```swift
public static func > (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `<(_:_:)`

```swift
public static func < (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `>=(_:_:)`

```swift
public static func >= (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `<=(_:_:)`

```swift
public static func <= (lhs: DispatcherSubscription, rhs: DispatcherSubscription) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |