//
//  MyRoomThings.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit

struct MyThing {
    let title: String
    let category: String?
    var image: String
}

extension MyThing {
    static var data = [
        MyThing(title: "조개껍데기", category: "소지품", image: "item_shell"),
        MyThing(title: "불가사리", category: "소지품", image: "item_starfish"),
        MyThing(title: "물고기", category: "소지품", image: "item_fish"),
        MyThing(title: "리본", category: "목", image: "item_ribbon"),
        MyThing(title: "흰색 꽃", category: "머리", image: "item_hairpin_flower_white"),
        MyThing(title: "꽃", category: "머리", image: "item_hairpin_flower"),
        MyThing(title: "불가사리", category: "머리", image: "item_hairpin_starfish"),
        MyThing(title: "모자", category: "머리", image: "item_hat"),
        MyThing(title: "안경", category: "눈", image: "item_glasses"),
        MyThing(title: "선글라스", category: "눈", image: "item_sunglasses"),
        MyThing(title: "물고기", category: "배경", image: "item_bg_fish"),
        MyThing(title: "불가사리", category: "배경", image: "item_bg_starfish"),
        MyThing(title: "문어", category: "배경", image: "item_bg_octopus"),
        MyThing(title: "바위", category: "배경", image: "item_bg_rock"),
        MyThing(title: "생명권", category: nil, image: "item_life"),
        MyThing(title: "부활권", category: nil, image: "item_resurrection"),
    ]
}
