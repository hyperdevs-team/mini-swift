/*
 Copyright [2019] [BQ]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
        return filter {
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
                .skipWhile {
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
                .filter { taskMap($0)[task: key].isTerminal }
        case .forever:
            return self
                .skipWhile { taskMap($0)[task: key].status == .idle || taskMap($0)[task: key].isTerminal }
                .filter { taskMap($0).hasValue(for: key) }
                .filter { taskMap($0)[task: key].isTerminal }
                .take(1)
        }
    }

    private func subscribe<Type, T: TypedTask<Type>> (
        taskMap: @escaping ((Self.Element) -> T?),
        lifetime: Task.Lifetime = .once,
        success: @escaping (Self.Element) -> Void = { _ in },
        error: @escaping (Self.Element) -> Void = { _ in })
        -> Disposable {
            return self
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
            return self
                .filterForKeyedLifetime(key: key, taskMap: taskMap, lifetime: lifetime)
                .subscribe(onNext: { state in
                    let task = taskMap(state)[task: key]
                    if task.isSuccessful {
                        success(state)
                    } else if task.isFailure {
                        error(state)
                    } else {
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
                dispatcher.dispatch(action, mode: .sync)
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
                dispatcher.dispatch(action, mode: .sync)
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
