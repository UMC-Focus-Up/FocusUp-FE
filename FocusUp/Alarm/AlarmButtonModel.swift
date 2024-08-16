//
//  AlarmModel.swift
//  FocusUp
//
//  Created by 김민지 on 8/13/24.
//

import Foundation
import Alamofire

// 알람 버튼 
struct AlarmResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: AlarmResult
    
    struct AlarmResult: Decodable {
        let life: Int
        let point: Int
        let delayCount: Int
    }
}

struct AlarmRequestModel: Encodable {
    let routineId: Int         // 사용자 ID
    let option: AlarmOption // 버튼 옵션
}

enum AlarmOption: Int, Encodable {
    case now = 0                   // 지금 바로 갈게 (+30 포인트)
    case later = 1                 // 5분 뒤에 갈게 (-5 포인트)  *최대 6번까지만*
    case no = 2                    // 미안 오늘은 무리야 (-1 생명)
    
}

enum AlarmError: Error {
    case networkError(AFError)
    case noData
    case decodingError
}

// 생명과 코인 정보
