**CLASS**

# `Promise`

```swift
public final class Promise<T>: PromiseType
```

## Properties
### `result`

```swift
public var result: Result<T, Swift.Error>?
```

## Methods
### `value(_:)`

```swift
public class func value(_ value: T) -> Promise<T>
```

### `error(_:)`

```swift
public class func error(_ error: Swift.Error) -> Promise<T>
```

### `init(error:)`

```swift
public init(error: Swift.Error)
```

### `init()`

```swift
public init()
```

### `idle(with:)`

```swift
public class func idle(with options: [String: Any] = [:]) -> Promise<T>
```

### `pending(options:)`

```swift
public class func pending(options: [String: Any] = [:]) -> Promise<T>
```

### `fulfill(_:)`

```swift
public func fulfill(_ value: T) -> Self
```

> - Note: `fulfill` do not trigger an object reassignment,
> so no notifications about it can be triggered. It is recommended
> to call the method `notify` afterwards.

### `reject(_:)`

```swift
public func reject(_ error: Swift.Error) -> Self
```

> - Note: `reject` do not trigger an object reassignment,
> so no notifications about it can be triggered. It is recommended
> to call the method `notify` afterwards.

### `resolve(_:)`

```swift
public func resolve(_ result: Result<T, Error>?) -> Self?
```

> Resolves the current `Promise` with the optional `Result` parameter.
> - Returns: `self` or `nil` if no `result` was not provided.
> - Note: The optional parameter and restun value are helpers in order to
> make optional chaining in the `Reducer` context.

### `dynamicallyCall(withKeywordArguments:)`

```swift
public func dynamicallyCall<T>(withKeywordArguments args: KeyValuePairs<String, T>)
```
