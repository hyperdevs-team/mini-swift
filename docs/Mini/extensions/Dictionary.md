**EXTENSION**

# `Dictionary`

## Methods
### `getOrPut(_:defaultValue:)`

```swift
public mutating func getOrPut(_ key: Key, defaultValue: @autoclosure () -> Value) -> Value
```

> Returns the value for the given key. If the key is not found in the map, calls the `defaultValue` function,
> puts its result into the map under the given key and returns it.
