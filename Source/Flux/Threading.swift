import Foundation

/// Executes a blocking function in UI thread.
public func onUiSync(block: () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

/// Executes a function in UI thread.
public func onUi(block: @escaping () -> Void) {
    DispatchQueue.main.async {
        block()
    }
}

/// Asserts that the caller function is called in the UI thread.
public func assertOnUiThread() {
    if !Thread.isMainThread {
        fatalError(MiniError.onUiThread.message)
    }
}

/// Asserts that the caller function is not called in the UI thread.
public func assertNotOnUiThread() {
    if Thread.isMainThread {
        fatalError(MiniError.onUiThread.message)
    }
}
