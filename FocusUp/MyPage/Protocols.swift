import Foundation

protocol RoutineUpdateDelegate: AnyObject {
    func didUpdateRoutine()
}

protocol RoutineDataDelegate: AnyObject {
    func didReceiveData(_ data: (String, [Int], String, String))
}

protocol RoutineDeleteDelegate: AnyObject {
    func didDeleteRoutine(at index: Int)
}
