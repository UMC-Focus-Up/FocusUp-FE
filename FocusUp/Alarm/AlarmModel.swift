//
//  AlarmModel.swift
//  FocusUp
//
//  Created by 김민지 on 8/13/24.
//

import Foundation
import Alamofire

struct AlarmResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: AlarmResult
    
    struct AlarmResult: Decodable {
        let life: Int
        let point: Int
        let delayCount: Int
        let option: AlarmOption
    }
}

struct AlarmRequestModel: Encodable {
    let userId: Int
    let action: Int
}

enum AlarmOption: Int, Decodable {
    case now = 0
    case later = 1
    case no = 2
}

enum AlarmError: Error {
    case networkError(AFError)
    case noData
    case decodingError
}
