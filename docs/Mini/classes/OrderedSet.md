**CLASS**

# `OrderedSet`

```swift
public class OrderedSet<T: Comparable>
```

> An Ordered Set is a collection where all items in the set follow an ordering,
> usually ordered from 'least' to 'most'. The way you value and compare items
> can be user-defined.

## Properties
### `count`

```swift
public var count: Int
```

> Returns the number of elements in the OrderedSet.

### `max`

```swift
public var max: T?
```

> Returns the 'maximum' or 'largest' value in the set.

### `min`

```swift
public var min: T?
```

> Returns the 'minimum' or 'smallest' value in the set.

## Methods
### `init(initial:)`

```swift
public init(initial: [T] = [])
```

### `insert(_:)`

```swift
public func insert(_ item: T) -> Bool
```

> Inserts an item. Performance: O(n)

### `insert(_:)`

```swift
public func insert(_ items: [T]) -> Bool
```

> Insert an array of items

### `remove(_:)`

```swift
public func remove(_ item: T) -> Bool
```

> Removes an item if it exists. Performance: O(n)

### `exists(_:)`

```swift
public func exists(_ item: T) -> Bool
```

> Returns true if and only if the item exists somewhere in the set.

### `indexOf(_:)`

```swift
public func indexOf(_ item: T) -> Int?
```

> Returns the index of an item if it exists, or nil otherwise.

### `kLargest(element:)`

```swift
public func kLargest(element: Int) -> T?
```

> Returns the k-th largest element in the set, if k is in the range
> [1, count]. Returns nil otherwise.

### `kSmallest(element:)`

```swift
public func kSmallest(element: Int) -> T?
```

> Returns the k-th smallest element in the set, if k is in the range
> [1, count]. Returns nil otherwise.

### `forEach(_:)`

```swift
public func forEach(_ body: (T) -> Swift.Void)
```

> For each function

### `enumerated()`

```swift
public func enumerated() -> EnumeratedSequence<[T]>
```

> Enumerated function
