//
//  HomeModel.swift
//  FocusUp
//
//  Created by 김민지 on 8/15/24.
//

import Foundation

// 코인 전송
struct SendCoinData: Codable {
    let point: Int
}

struct EmptyResponse: Decodable {
    // 서버에서 반환하는 응답이 없거나 비어있는 경우
}


// 생명 정보
struct AlarmUserResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: AlarmUserResult
}

struct AlarmUserResult: Codable {
    let life: Int
    let point: Int
}


// 레벨 변경
//struct LevelChangeResponse: Decodable {
//    let isSuccess: Bool
//    let message: String
//    let result: LevelResult
//}
//
//struct LevelResult: Decodable {
//    let level: Int
//    let isUserLevel: Bool
//}


// 루틴 정보
struct HomeResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: HomeResult
}

struct HomeResult: Decodable {
    let life: Int
    let point: Int
    let level: Int
    let routineId: Int
    let routineName: String
    let execTime: String
}
