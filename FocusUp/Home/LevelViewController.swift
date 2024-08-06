//
//  LevelViewController.swift
//  FocusUp
//
//  Created by 김민지 on 7/25/24.
//

import UIKit

class LevelViewController: UIViewController {
    
    @IBOutlet weak var boosterTime: UILabel!
    @IBOutlet weak var levelInfo: UIStackView!
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setFont()
    }
    
    
    // MARK: - Function
    func setFont() {
        boosterTime.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        
        let customFont = UIFont(name: "Pretendard-Medium", size: 17)
        
        // UIStackView는 폰트를 설정할 수 없으므로, 개별 UILabel 또는 UIButton에 대해 폰트를 설정
        for subview in levelInfo.arrangedSubviews {
            if let label = subview as? UILabel {
                label.font = customFont
            } else if let button = subview as? UIButton {
                button.titleLabel?.font = customFont
            }
        }
    }
}
