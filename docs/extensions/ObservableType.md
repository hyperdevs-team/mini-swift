**EXTENSION**

# `ObservableType`

## Methods
### `filterOne(_:)`

```swift
public func filterOne(_ condition: @escaping (Element) -> Bool) -> Observable<Element>
```

> Take the first element that matches the filter function.
>
> - Parameter fn: Filter closure.
> - Returns: The first element that matches the filter.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fn | Filter closure. |

### `filter(_:)`

```swift
public func filter(_ keyPath: KeyPath<Element, Bool>) -> Observable<Element>
```

### `map(_:)`

```swift
public func map<T>(_ keyPath: KeyPath<Element, T>) -> Observable<T>
```

### `one()`

```swift
public func one() -> Observable<Element>
```

### `skippingCurrent()`

```swift
public func skippingCurrent() -> Observable<Element>
```

### `select(_:)`

```swift
public func select<T: OptionalType>(_ keyPath: KeyPath<Element, T>) -> Observable<T.Wrapped> where T.Wrapped: Equatable
```

> Selects a property component from an `Element` filtering `nil` and emitting only distinct contiguous elements.

### `filterNil()`

```swift
func filterNil() -> Observable<Element.Wrapped>
```

> Unwraps and filters out `nil` elements.
> - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.

### `withStateChanges(in:that:)`

```swift
public func withStateChanges<T>(in stateComponent: KeyPath<Element, T>, that componentProperty: KeyPath<T, Bool>) -> Observable<T>
```

> Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
