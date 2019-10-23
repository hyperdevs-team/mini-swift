**CLASS**

# `PreSealedBox`

```swift
final class PreSealedBox<T>: Box<T>
```

## Properties
### `sealant`

```swift
private var sealant: Sealant<T> = .completed
```

## Methods
### `init()`

```swift
override init()
```

### `inspect()`

```swift
override func inspect() -> Sealant<T>
```

### `seal(_:)`

### `fill(_:)`
