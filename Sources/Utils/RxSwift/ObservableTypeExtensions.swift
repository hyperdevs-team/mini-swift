import Foundation
import RxSwift

extension Task {
    public enum Lifetime {
        case once
        case forever(ignoringOld: Bool)
    }
}

extension ObservableType {
    /// Take the first element that matches the filter function.
    ///
    /// - Parameter fn: Filter closure.
    /// - Returns: The first element that matches the filter.
    public func filterOne(_ condition: @escaping (Element) -> Bool) -> Observable<Element> {
        filter {
            return condition($0)
        }.take(1)
    }
}

extension ObservableType where Self.Element: StateType {
    private func filterForLifetime<Type, T: TypedTask<Type>> (
        taskMap: @escaping ((Self.Element) -> T?),
        lifetime: Task.Lifetime) -> Observable<Element> {
        switch lifetime {
        case .once:
            return self
                .filterOne { taskMap($0)?.isTerminal ?? true }

        case .forever(let ignoreOld):
            let date = Date()
            return self
                .skip {
                    if ignoreOld {
                        if let task = taskMap($0) {
                            return task.started < date
                        }
                        return false
                    } else {
                        return false
                    }
                }
                .filter { taskMap($0)?.isTerminal ?? true }
        }
    }

    private func filterForKeyedLifetime<K: Hashable> (
        key: K,
        taskMap: @escaping ((Self.Element) -> KeyedTask<K>),
        lifetime: Task.Lifetime) -> Observable<Element> {
        switch lifetime {
        case .once:
            return self
                .filter { taskMap($0).hasValue(for: key) }
                .filter { taskMap($0).isTerminal(key: key) }

        case .forever:
            return self
                .skip { taskMap($0).isIdle(key: key) || taskMap($0).isTerminal(key: key) }
                .filter { taskMap($0).hasValue(for: key) }
                .filter { taskMap($0).isTerminal(key: key) }
                .take(1)
        }
    }

    private func subscribe<Type, T: TypedTask<Type>> (
        taskMap: @escaping ((Self.Element) -> T?),
        lifetime: Task.Lifetime = .once,
        success: @escaping (Self.Element) -> Void = { _ in },
        error: @escaping (Self.Element) -> Void = { _ in })
        -> Disposable {
            self
                .filterForLifetime(taskMap: taskMap, lifetime: lifetime)
                .subscribe(onNext: { state in
                    if let task = taskMap(state) {
                        if task.isSuccessful {
                            success(state)
                        } else if task.isFailure {
                            error(state)
                        } else {
                            success(state)
                        }
                    }
                })
    }

    private func subscribe<K: Hashable> (
        key: K,
        taskMap: @escaping ((Self.Element) -> KeyedTask<K>),
        lifetime: Task.Lifetime = .once,
        success: @escaping (Self.Element) -> Void = { _ in },
        error: @escaping (Self.Element) -> Void = { _ in })
        -> Disposable {
            self
                .filterForKeyedLifetime(key: key, taskMap: taskMap, lifetime: lifetime)
                .subscribe(onNext: { state in
                    switch taskMap(state)[task: key]?.status {
                    case .success:
                        success(state)

                    case .failure:
                        error(state)

                    default:
                        success(state)
                    }
                })
    }
}

extension ObservableType where Element: StoreType & ObservableType, Self.Element.State == Self.Element.Element {
    public static func dispatch<A: Action, T: Task> (
        using dispatcher: Dispatcher,
        factory action: @autoclosure @escaping () -> A,
        taskMap: @escaping (Self.Element.State) -> T?,
        on store: Self.Element,
        lifetime: Task.Lifetime = .once)
        -> Observable<Self.Element.State> {
            let observable: Observable<Self.Element.State> = Observable.create { observer in
                let action = action()
                dispatcher.dispatch(action)
                let subscription = store.subscribe(
                    taskMap: taskMap,
                    lifetime: lifetime,
                    success: { state in
                        observer.on(.next(state))
                    },
                    error: { state in
                        if let task = taskMap(state), let error = task.error {
                            observer.on(.error(error))
                        }
                    }
                )
                return Disposables.create([subscription])
            }
            return observable
    }

    public static func dispatch<A: Action, K: Hashable> (
        using dispatcher: Dispatcher,
        factory action: @autoclosure @escaping () -> A,
        key: K,
        taskMap: @escaping (Self.Element.State) -> KeyedTask<K>,
        on store: Self.Element,
        lifetime: Task.Lifetime = .once)
        -> Observable<Self.Element.State> {
            let observable: Observable<Self.Element.State> = Observable.create { observer in
                let action = action()
                dispatcher.dispatch(action)
                let subscription = store.subscribe(
                    key: key,
                    taskMap: taskMap,
                    lifetime: lifetime,
                    success: { state in
                        observer.on(.next(state))
                    },
                    error: { state in
                        if let task = taskMap(state)[key], let error = task.error {
                            observer.on(.error(error))
                        }
                    }
                )
                return Disposables.create([subscription])
            }
            return observable
    }
}
