import Foundation

protocol RoutineUpdateDelegate: AnyObject {
    func didUpdateRoutine()
}

protocol RoutineDataDelegate: AnyObject {
    func didReceiveData(_ data: (String, [Int], String, String, Int64, String)) // 데이터 타입 수정
}

protocol RoutineDeleteDelegate: AnyObject {
    func didDeleteRoutine(at index: Int)
}
