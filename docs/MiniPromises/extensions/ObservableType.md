**EXTENSION**

# `ObservableType`

## Methods
### `dispatch(using:factory:taskMap:on:lifetime:)`

```swift
public static func dispatch<A: Action, Type, T: Promise<Type>>(
    using dispatcher: Dispatcher? = nil,
    factory action: @autoclosure @escaping () -> A,
    taskMap: @escaping (Self.Element.State) -> T?,
    on store: Self.Element,
    lifetime: Promises.Lifetime = .once
)
    -> Observable<Self.Element.State>
```

### `dispatch(using:factory:key:taskMap:on:lifetime:)`

```swift
public static func dispatch<A: Action, K: Hashable, Type, T: Promise<Type>>(
    using dispatcher: Dispatcher? = nil,
    factory action: @autoclosure @escaping () -> A,
    key: K,
    taskMap: @escaping (Self.Element.State) -> [K: T],
    on store: Self.Element,
    lifetime: Promises.Lifetime = .once
)
    -> Observable<Self.Element.State>
```
