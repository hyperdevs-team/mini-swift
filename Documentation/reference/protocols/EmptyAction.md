**PROTOCOL**

# `EmptyAction`

```swift
public protocol EmptyAction: Action & PayloadAction where Payload == Swift.Never
```

## Methods
### `init(promise:)`

```swift
init(promise: Promise<Void>)
```
