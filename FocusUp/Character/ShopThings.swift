//
//  ShopThings.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit

struct ShopThing {
    let title: String
    let category: String?
    var image: String
    let price: String
}

extension ShopThing {
    static var data = [
        ShopThing(title: "조개껍데기", category: "소지품", image: "item_shell", price: "150"),
        ShopThing(title: "불가사리", category: "소지품", image: "item_starfish", price: "150"),
        ShopThing(title: "물고기", category: "소지품", image: "item_fish", price: "150"),
        ShopThing(title: "리본", category: "목", image: "item_ribbon", price: "200"),
        ShopThing(title: "흰색 꽃", category: "머리", image: "item_hairpin_flower_white", price: "200"),
        ShopThing(title: "꽃", category: "머리", image: "item_hairpin_flower", price: "200"),
        ShopThing(title: "불가사리", category: "머리", image: "item_hairpin_starfish", price: "200"),
        ShopThing(title: "모자", category: "머리", image: "item_hat", price: "300"),
        ShopThing(title: "안경", category: "눈", image: "item_glasses", price: "250"),
        ShopThing(title: "선글라스", category: "눈", image: "item_sunglasses", price: "250"),
        ShopThing(title: "물고기", category: "배경", image: "item_bg_fish", price: "300"),
        ShopThing(title: "불가사리", category: "배경", image: "item_bg_starfish", price: "300"),
        ShopThing(title: "문어", category: "배경", image: "item_bg_octopus", price: "300"),
        ShopThing(title: "바위", category: "배경", image: "item_bg_rock", price: "300"),
        ShopThing(title: "생명권", category: nil, image: "item_life", price: "500"),
        ShopThing(title: "부활권", category: nil, image: "item_resurrection", price: "2000"),
    ]
}
