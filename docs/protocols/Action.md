**PROTOCOL**

# `Action`

```swift
public protocol Action
```

> Protocol that has to be conformed by any object that can be dispatcher
> by a `Dispatcher` object.

## Methods
### `isEqual(to:)`

```swift
func isEqual(to other: Action) -> Bool
```

> Equality function between `Action` objects
> - Returns: If an `Action` is the same as other.
