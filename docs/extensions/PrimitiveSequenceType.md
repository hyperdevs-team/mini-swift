**EXTENSION**

# `PrimitiveSequenceType`

## Methods
### `dispatch(action:on:mode:fillOnError:)`

```swift
func dispatch<A: CompletableAction>(action: A.Type,
                                    on dispatcher: Dispatcher,
                                    mode: Dispatcher.DispatchMode.UI = .async,
                                    fillOnError errorPayload: A.Payload? = nil)
    -> Disposable where A.Payload == Self.Element
```

### `dispatch(action:key:on:mode:fillOnError:)`

```swift
func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                         key: A.Key,
                                         on dispatcher: Dispatcher,
                                         mode: Dispatcher.DispatchMode.UI = .async,
                                         fillOnError errorPayload: A.Payload? = nil)
    -> Disposable where A.Payload == Self.Element
```

### `action(_:fillOnError:)`

```swift
func action<A: CompletableAction>(_ action: A.Type,
                                  fillOnError errorPayload: A.Payload? = nil)
    -> Single<A> where A.Payload == Self.Element
```

### `dispatch(action:on:mode:)`

```swift
func dispatch<A: EmptyAction>(action: A.Type,
                              on dispatcher: Dispatcher,
                              mode: Dispatcher.DispatchMode.UI = .async)
    -> Disposable
```

### `action(_:)`

```swift
func action<A: EmptyAction>(_ action: A.Type)
    -> Single<A>
```
