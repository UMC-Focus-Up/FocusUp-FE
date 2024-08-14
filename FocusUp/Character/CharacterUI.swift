//
//  CharacterUI.swift
//  FocusUp
//
//  Created by 김서윤 on 8/14/24.
//

import UIKit

struct CharacterUI {
    let title: String
    var image: String
}

extension CharacterUI {
    static var data = [
        CharacterUI(title: "조개껍데기", image: "ui_shell"),
        CharacterUI(title: "불가사리", image: "ui_starfish"),
        CharacterUI(title: "물고기", image: "ui_fish"),
        CharacterUI(title: "리본", image: "ui_ribbon"),
        CharacterUI(title: "흰색 꽃", image: "ui_hairpin_flower_white"),
        CharacterUI(title: "꽃", image: "ui_hairpin_flower"),
        CharacterUI(title: "불가사리", image: "ui_hairpin_starfish"),
        CharacterUI(title: "모자", image: "ui_hat"),
        CharacterUI(title: "안경", image: "ui_glasses"),
        CharacterUI(title: "선글라스", image: "ui_sunglasses"),
        CharacterUI(title: "물고기", image: "ui_bg_fish"),
        CharacterUI(title: "불가사리", image: "ui_bg_starfish"),
        CharacterUI(title: "문어", image: "ui_bg_octopus"),
        CharacterUI(title: "바위", image: "ui_bg_rock"),
    ]
}

