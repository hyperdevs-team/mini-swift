import Foundation

/**
 An Ordered Set is a collection where all items in the set follow an ordering,
 usually ordered from 'least' to 'most'. The way you value and compare items
 can be user-defined.
 */
public class OrderedSet<T: Comparable> {
    private var internalSet = [T]()

    public init(initial: [T] = []) {
        insert(initial)
    }

    /// Returns the number of elements in the OrderedSet.
    public var count: Int {
        internalSet.count
    }

    /// Inserts an item. Performance: O(n)
    @discardableResult
    public func insert(_ item: T) -> Bool {
        if exists(item) {
            return false // don't add an item if it already exists
        }

        // Insert new the item just before the one that is larger.
        for i in 0..<count where internalSet[i] > item {
            internalSet.insert(item, at: i)
            return true
        }

        // Append to the back if the new item is greater than any other in the set.
        internalSet.append(item)
        return true
    }

    /// Insert an array of items
    @discardableResult
    public func insert(_ items: [T]) -> Bool {
        var success = false
        items.forEach {
            success = insert($0) || success
        }
        return success
    }

    /// Removes an item if it exists. Performance: O(n)
    @discardableResult
    public func remove(_ item: T) -> Bool {
        if let index = indexOf(item) {
            internalSet.remove(at: index)
            return true
        }
        return false
    }

    /// Returns true if and only if the item exists somewhere in the set.
    public func exists(_ item: T) -> Bool {
        indexOf(item) != nil
    }

    /// Returns the index of an item if it exists, or nil otherwise.
    public func indexOf(_ item: T) -> Int? {
        var leftBound = 0
        var rightBound = count - 1

        while leftBound <= rightBound {
            let mid = leftBound + ((rightBound - leftBound) / 2)

            if internalSet[mid] > item {
                rightBound = mid - 1
                continue
            }

            if internalSet[mid] < item {
                leftBound = mid + 1
                continue
            }

            if internalSet[mid] == item {
                return mid
            }

            // When we get here, we've landed on an item whose value is equal to the
            // value of the item we're looking for, but the items themselves are not
            // equal. We need to check the items with the same value to the right
            // and to the left in order to find an exact match.
            // Check to the right.
            for value in stride(from: mid, to: count - 1, by: 1) {
                if internalSet[value + 1] == item {
                    return value + 1
                }
                if internalSet[value] < internalSet[value + 1] {
                    break
                }
            }

            // Check to the left.
            for value in stride(from: mid, to: 0, by: -1) {
                if internalSet[value - 1] == item {
                    return value - 1
                }
                if internalSet[value] > internalSet[value - 1] {
                    break
                }
            }

            // value not found, the value are equal but the item not, break the loop:
            break
        }
        return nil
    }

    /// Returns the item at the given index.
    /// Assertion fails if the index is out of the range of [0, count).
    public subscript(index: Int) -> T {
        assert(index >= 0 && index < count)
        return internalSet[index]
    }

    /// Returns the 'maximum' or 'largest' value in the set.
    public var max: T? {
        internalSet.isEmpty ? nil : internalSet[count - 1]
    }

    /// Returns the 'minimum' or 'smallest' value in the set.
    public var min: T? {
        internalSet.isEmpty ? nil : internalSet[0]
    }

    /// Returns the k-th largest element in the set, if k is in the range
    /// [1, count]. Returns nil otherwise.
    public func kLargest(element: Int) -> T? {
        element > count || element <= 0 ? nil : internalSet[count - element]
    }

    /// Returns the k-th smallest element in the set, if k is in the range
    /// [1, count]. Returns nil otherwise.
    public func kSmallest(element: Int) -> T? {
        element > count || element <= 0 ? nil : internalSet[element - 1]
    }

    /// For each function
    public func forEach(_ body: (T) -> Swift.Void) {
        internalSet.forEach(body)
    }

    /// Enumerated function
    public func enumerated() -> EnumeratedSequence<[T]> {
        internalSet.enumerated()
    }
}
