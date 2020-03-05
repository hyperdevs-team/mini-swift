**EXTENSION**

# `Store`

## Methods
### `replaying()`

```swift
func replaying() -> Observable<Store.State>
```

### `dispatch(_:)`

```swift
public func dispatch<A: Action>(_ action: @autoclosure @escaping () -> A) -> Observable<Store.State>
```

### `withStateChanges(in:)`

```swift
public func withStateChanges<T>(in stateComponent: KeyPath<Element, T>) -> Observable<T>
```
