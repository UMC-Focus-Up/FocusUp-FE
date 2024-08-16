//
//  ShopThings.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit

struct ShopThing {
    let id: Int
    let title: String
    let category: String?
    var image: String
    let price: String
}

extension ShopThing {
    static func getImageName(for title: String, category: String?) -> String {
        if let category = category {
            switch category {
            case "소지품":
                return title == "조개껍데기" ? "item_shell" :
                       title == "불가사리" ? "item_starfish" :
                       title == "물고기" ? "item_fish" : "default_image"
            case "목":
                return title == "리본" ? "item_ribbon" : "default_image"
            case "머리":
                return title == "흰색 꽃" ? "item_hairpin_flower_white" :
                       title == "꽃" ? "item_hairpin_flower" :
                       title == "불가사리" ? "item_hairpin_starfish" :
                       title == "모자" ? "item_hat" : "default_image"
            case "눈":
                return title == "안경" ? "item_glasses" :
                       title == "선글라스" ? "item_sunglasses" : "default_image"
            case "배경":
                return title == "물고기" ? "item_bg_fish" :
                       title == "불가사리" ? "item_bg_starfish" :
                       title == "문어" ? "item_bg_octopus" :
                       title == "바위" ? "item_bg_rock" : "default_image"
            default:
                return "default_image"
            }
        } else {
            // category가 nil일 경우의 처리
            return title == "생명권" ? "item_life" :
                   title == "부활권" ? "item_resurrection" : "default_image"
        }
    }
}
