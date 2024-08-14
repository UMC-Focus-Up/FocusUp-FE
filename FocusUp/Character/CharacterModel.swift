//
//  CharacterModel.swift
//  FocusUp
//
//  Created by 김서윤 on 8/13/24.
//

import Foundation

// MARK: - 캐릭터 화면 조회
struct CharacterResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: CharacterResult?
}

struct CharacterResult: Decodable {
    let life: Int
    let point: Int
    let status: Bool
    let item: CharacterItem?
}

struct CharacterItem: Decodable {
    let id: Int
    let name: String
    let type: String
    let imageUrl: String
}

// MARK: - 상점 조회
struct ShopResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: ShopResult?
}

struct ShopResult: Codable {
    let point: Int
    let itemList: [ShopItem]
}

struct ShopItem: Codable {
    let id: Int
    let price: Int
    let name: String
    let type: String?
    let imageUrl: String
    let purchased: Bool
}

// MARK: - 아이템 구매
struct PurchaseRequest: Encodable {
    let itemId: Int
}

struct PurchaseResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: PurchaseResult?
}

struct PurchaseResult: Decodable {
    let point: Int
}

// MARK: - 마이룸 조회
struct RoomResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: RoomResult?
}

struct RoomResult: Codable {
    let itemList: [RoomItem]
}

struct RoomItem: Codable {
    let id: Int
    let name: String
    let type: String?
    let imageUrl: String
}

// MARK: - 아이템 선택
struct ItemRequest: Encodable {
    let itemId: Int
}

struct ItemResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: String?
}

// MARK: - 아이템 삭제
struct DeleteResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: String?
}
