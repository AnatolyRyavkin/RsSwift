import Foundation

public func example(_ rxOperator: String, action: () -> ()) {
    print("\n--- example of:", rxOperator, "---")
    action()
}
