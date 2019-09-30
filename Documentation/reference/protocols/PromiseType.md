**PROTOCOL**

# `PromiseType`

```swift
public protocol PromiseType
```

## Properties
### `result`

```swift
var result: Result<Element, Swift.Error>?
```

### `isIdle`

```swift
var isIdle: Bool
```

### `isPending`

```swift
var isPending: Bool
```

### `isResolved`

```swift
var isResolved: Bool
```

### `isFulfilled`

```swift
var isFulfilled: Bool
```

### `isRejected`

```swift
var isRejected: Bool
```

### `isOnProgress`

```swift
var isOnProgress: Bool
```

### `value`

```swift
var value: Element?
```

### `error`

```swift
var error: Swift.Error?
```

## Methods
### `resolve(_:)`

```swift
func resolve(_ result: Result<Element, Swift.Error>?) -> Self?
```

### `fulfill(_:)`

```swift
func fulfill(_ value: Element) -> Self
```

### `reject(_:)`

```swift
func reject(_ error: Swift.Error) -> Self
```
