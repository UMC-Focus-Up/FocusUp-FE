//
//  MyPageModel.swift
//  FocusUp
//
//  Created by 성호은 on 8/15/24.
//

import Foundation

// MARK: - 레벨 변경
struct LevelRequest: Encodable {
    let level: Int
}

struct LevelResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: LevelResult?
}

struct LevelResult: Decodable {
    let level: Int
    let isUserLevel: Bool
}

// MARK: - 마이페이지 조회
struct MyPageResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: MyPageResult?
}

struct MyPageResult: Codable {
    let userRoutines: [UserRoutines]        // 사용자별 루틴 Id
    let level: Int
    let successCount: Int
    let routines: [RoutineDetails]          // 루틴 전체 Id
}

struct UserRoutines: Codable {
    let id: Int
    let name: String
}

struct RoutineDetails: Codable {
    let date: String
    let totalAchieveRate: Double
    let routines: [Routines]
}

struct Routines: Codable {
    let id: Int
    let name: String
    let targetTime: String
    let execTime: String
    let achieveRate: Double
}
