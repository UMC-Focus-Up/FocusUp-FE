//
//  CharacterModel.swift
//  FocusUp
//
//  Created by 김서윤 on 8/13/24.
//

import Foundation

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
