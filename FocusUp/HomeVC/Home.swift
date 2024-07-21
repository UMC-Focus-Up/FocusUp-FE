//
//  Home.swift
//  FocusUp
//
//  Created by 김민지 on 7/21/24.
//

import UIKit

class Home: UIViewController {
    
    @IBOutlet weak var shellNumber: UILabel!
    @IBOutlet weak var fishNumber: UILabel!
    @IBOutlet weak var level: UIButton!
    @IBOutlet weak var timerOutline: UIView!
    @IBOutlet weak var timerInline: UIView!
    @IBOutlet weak var timerTime: UILabel!
    
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setFont()
    }
    
    // MARK: - Action
    
    @IBAction func levelButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let levelModal = storyboard.instantiateViewController(withIdentifier: "levelModal") as? LevelModal else {
            return
        }
        
        // 모달로 표시
        levelModal.modalPresentationStyle = .pageSheet
        
        if let sheet = levelModal.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true // 손잡이 표시
        }
        
        self.present(levelModal, animated: true, completion: nil)
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
    }
    @IBAction func addButton(_ sender: Any) {
    }
    @IBAction func timerButton(_ sender: Any) {
    }
    
    // MARK: - Function
    func setAttribute() {
        timerOutline.layer.cornerRadius = timerOutline.frame.height/2
        timerOutline.clipsToBounds = true
        timerInline.layer.cornerRadius = timerInline.frame.height/2
        timerInline.clipsToBounds = true
    }
    
    func setFont() {
        shellNumber.font = UIFont(name: "Pretendard-Regular", size: 16)
        fishNumber.font = UIFont(name: "Pretendard-Regular", size: 16)
        level.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 17)!
        timerTime.font = UIFont(name: "Pretendard-Semibold", size: 40)
    }
        
}

