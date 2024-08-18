import Foundation

class RoutineDataModel {
    static let shared = RoutineDataModel()
    
    private init() {}
    
    var routineData: [(String, [Int], String, String, Int64, String)] = []
    
    func addRoutine(_ routine: (String, [Int], String, String, Int64, String)) {
        routineData.insert(routine, at: 0)
    }
    
    func deleteRoutine(at index: Int) {
        guard index >= 0 && index < routineData.count else { return }
        routineData.remove(at: index)
    }
}
