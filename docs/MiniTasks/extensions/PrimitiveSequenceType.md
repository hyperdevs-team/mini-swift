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

> Dispatches an given action from the result of the `Single` trait. This is only usable when the `Action` is a `CompletableAction`.
> - Parameter action: The `CompletableAction` type to be dispatched.
> - Parameter dispatcher: The `Dispatcher` object that will dispatch the action.
> - Parameter mode: The `Dispatcher` dispatch mode, `.async` by default.
> - Parameter fillOnError: The payload that will replace the action's payload in case of failure.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | The `CompletableAction` type to be dispatched. |
| dispatcher | The `Dispatcher` object that will dispatch the action. |
| mode | The `Dispatcher` dispatch mode, `.async` by default. |
| fillOnError | The payload that will replace the action’s payload in case of failure. |

### `dispatch(action:key:on:mode:fillOnError:)`

```swift
func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                         key: A.Key,
                                         on dispatcher: Dispatcher,
                                         mode: Dispatcher.DispatchMode.UI = .async,
                                         fillOnError errorPayload: A.Payload? = nil)
    -> Disposable where A.Payload == Self.Element
```

> Dispatches an given action from the result of the `Single` trait. This is only usable when the `Action` is a `CompletableAction`.
> - Parameter action: The `CompletableAction` type to be dispatched.
> - Parameter key: The key associated with the `Task` result.
> - Parameter dispatcher: The `Dispatcher` object that will dispatch the action.
> - Parameter mode: The `Dispatcher` dispatch mode, `.async` by default.
> - Parameter fillOnError: The payload that will replace the action's payload in case of failure or `nil`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | The `CompletableAction` type to be dispatched. |
| key | The key associated with the `Task` result. |
| dispatcher | The `Dispatcher` object that will dispatch the action. |
| mode | The `Dispatcher` dispatch mode, `.async` by default. |
| fillOnError | The payload that will replace the action’s payload in case of failure or `nil`. |

### `action(_:fillOnError:)`

```swift
func action<A: CompletableAction>(_ action: A.Type,
                                  fillOnError errorPayload: A.Payload? = nil)
    -> Single<A> where A.Payload == Self.Element
```

> Builds a `CompletableAction` from a `Single`
> - Parameter action: The `CompletableAction` type to be built.
> - Parameter fillOnError: The payload that will replace the action's payload in case of failure or `nil`.
> - Returns: A `Single` of the `CompletableAction` type declared by the action parameter.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | The `CompletableAction` type to be built. |
| fillOnError | The payload that will replace the action’s payload in case of failure or `nil`. |

### `dispatch(action:on:mode:)`

```swift
func dispatch<A: EmptyAction>(action: A.Type,
                              on dispatcher: Dispatcher,
                              mode: Dispatcher.DispatchMode.UI = .async)
    -> Disposable
```

> Dispatches an given action from the result of the `Completable` trait. This is only usable when the `Action` is an `EmptyAction`.
> - Parameter action: The `CompletableAction` type to be dispatched.
> - Parameter dispatcher: The `Dispatcher` object that will dispatch the action.
> - Parameter mode: The `Dispatcher` dispatch mode, `.async` by default.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | The `CompletableAction` type to be dispatched. |
| dispatcher | The `Dispatcher` object that will dispatch the action. |
| mode | The `Dispatcher` dispatch mode, `.async` by default. |

### `action(_:)`

```swift
func action<A: EmptyAction>(_ action: A.Type)
    -> Single<A>
```

> Builds an `EmptyAction` from a `Completable`
> - Parameter action: The `EmptyAction` type to be built.
> - Returns: A `Single` of the `EmptyAction` type declared by the action parameter.

#### Parameters

| Name | Description |
| ---- | ----------- |
| action | The `EmptyAction` type to be built. |