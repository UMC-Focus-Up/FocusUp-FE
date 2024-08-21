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

// 서버에서 반환하는 응답이 없거나 비어있는 경우
struct EmptyResponse: Decodable {
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


// 홈 화면 유저 정보 조회 (GET)
struct GetHomeResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: GetHomResult?
}

struct GetHomResult: Decodable {
    let life: Int
    let point: Int
    let level: Int
    let userLevel: Bool
}

// 홈화면 루틴 전송 (POST)
struct PostHomeResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: PostHomeResult?
}

struct PostHomeResult: Decodable {
    let routineId: Int
    let routineName: String
    let execTime: String
    let goalTime: String
}

// 반복 루틴 완료
struct PostRoutineRequest: Codable {
    let execTime: String        // execTime을 문자열로 정의
}

struct PostRoutineResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: Int?
}

