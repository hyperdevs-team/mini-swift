**EXTENSION**

# `Dictionary`

## Methods
### `getOrPut(_:defaultValue:)`

```swift
public mutating func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value
```

> Returns the value for the given key. If the key is not found in the map, calls the `defaultValue` function,
> puts its result into the map under the given key and returns it.

### `hasValue(for:)`

```swift
public func hasValue(for key: Dictionary.Key) -> Bool
```

### `resolve(with:)`

```swift
public func resolve(with other: [Key: Value]) -> Self
```

### `mergingNew(with:)`

```swift
public func mergingNew(with other: [Key: Value]) -> Self
```

### `==(_:_:)`

```swift
static func == (lhs: [Key: Value], rhs: [Key: Value]) -> Bool
```
