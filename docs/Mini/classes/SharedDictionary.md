**CLASS**

# `SharedDictionary`

```swift
public class SharedDictionary<Key: Hashable, Value>
```

> Wrapper class to allow pass dictionaries with a memory reference

## Properties
### `innerDictionary`

```swift
public var innerDictionary: [Key: Value]
```

## Methods
### `init()`

```swift
public init()
```

### `getOrPut(_:defaultValue:)`

```swift
public func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value
```

### `get(withKey:)`

```swift
public func get(withKey key: Key) -> Value?
```
