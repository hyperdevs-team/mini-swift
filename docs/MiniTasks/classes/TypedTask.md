**CLASS**

# `TypedTask`

```swift
public class TypedTask<T>: Equatable
```

## Properties
### `status`

```swift
public let status: Status
```

### `data`

```swift
public let data: T?
```

### `error`

```swift
public let error: Error?
```

### `initDate`

```swift
public let initDate = Date()
```

### `isRunning`

```swift
public var isRunning: Bool
```

### `isCompleted`

```swift
public var isCompleted: Bool
```

### `isSuccessful`

```swift
public var isSuccessful: Bool
```

### `isFailure`

```swift
public var isFailure: Bool
```

## Methods
### `init(status:data:error:)`

```swift
public init(status: Status = .idle,
            data: T? = nil,
            error: Error? = nil)
```

### `idle()`

```swift
public static func idle() -> AnyTask
```

### `running()`

```swift
public static func running() -> AnyTask
```

### `success(_:)`

```swift
public static func success<T>(_ data: T? = nil) -> TypedTask<T>
```

### `success()`

```swift
public static func success() -> AnyTask
```

### `failure(_:)`

```swift
public static func failure(_ error: Error) -> AnyTask
```

### `==(_:_:)`

```swift
public static func == (lhs: TypedTask<T>, rhs: TypedTask<T>) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |