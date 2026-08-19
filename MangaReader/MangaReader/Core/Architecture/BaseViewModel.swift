import Foundation
import SwiftUI

@MainActor
public protocol BaseViewModel: AnyObject, Sendable {
    func reset()
}
