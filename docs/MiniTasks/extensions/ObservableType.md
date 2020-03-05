**EXTENSION**

# `ObservableType`

## Methods
### `withStateChanges(in:)`

```swift
func withStateChanges<T>(
    in stateComponent: KeyPath<Element, T>
) -> Observable<T>
```

> Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.

### `withStateChanges(in:that:)`

```swift
func withStateChanges<T, Type, U: TypedTask<Type>>(
    in stateComponent: KeyPath<Element, T>,
    that taskComponent: KeyPath<Element, U>
)
    -> Observable<T>
```

> Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes using a `taskComponent` (i.e. a Task component in the State) to be completed (either successfully or failed).
