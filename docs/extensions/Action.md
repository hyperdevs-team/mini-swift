**EXTENSION**

# `Action`

## Properties
### `innerTag`

```swift
public var innerTag: String
```

> String used as tag of the given Action based on his name.
> - Returns: The name of the action as a String.

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: Self, rhs: Self) -> Bool
```

> Equality operator between `Action` objects.
> - Returns: If the `Action`s are equal or not.

### `isEqual(to:)`

```swift
public func isEqual(to other: Action) -> Bool
```

> Convenience `isEqual` implementation when the `Action` object
> implements `Equatable`.
> - Returns: Whether the `Action` object is the same as other.
