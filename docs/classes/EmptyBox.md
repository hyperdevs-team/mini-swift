**CLASS**

# `EmptyBox`

```swift
class EmptyBox<T>: Box<T>
```

## Properties
### `sealant`

```swift
private var sealant: Sealant<T> = .pending
```

## Methods
### `fill(_:)`

```swift
override func fill(_ sealant: Sealant<T>)
```

### `seal(_:)`

```swift
override func seal(_ value: T)
```

### `inspect()`

```swift
override func inspect() -> Sealant<T>
```
