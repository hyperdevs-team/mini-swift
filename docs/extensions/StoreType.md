**EXTENSION**

# `StoreType`

## Properties
### `reducerGroup`

```swift
public var reducerGroup: ReducerGroup
```

> Property responsible of reduce the `State` given a certain `Action` being triggered.
> ```
> public var reducerGroup: ReducerGroup {
>    ReducerGroup {[
>        Reducer(of: SomeAction.self, on: self.dispatcher) { (action: SomeAction)
>            self.state = myCoolNewState
>        },
>        Reducer(of: OtherAction.self, on: self.dispatcher) { (action: OtherAction)
>            // Needed work
>            self.state = myAnotherState
>            }
>        }
>    ]}
> ```
> - Note : The property has a default implementation which complies with the @_functionBuilder's current limitations, where no empty blocks can be produced in this iteration.
