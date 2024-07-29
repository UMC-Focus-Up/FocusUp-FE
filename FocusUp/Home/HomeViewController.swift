//
//  HomeViewConotroller.swift
//  FocusUp
//
//  Created by 김민지 on 7/24/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var shellNumber: UILabel!
    @IBOutlet weak var fishNumber: UILabel!
    @IBOutlet weak var level: UIButton!
    @IBOutlet weak var timerOutline: UIView!
    @IBOutlet weak var timerInline: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var closedButtonOutlet: UIButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var boosterLabel: UILabel!
    
    
    var timer: Timer?
    var timeRemaining: TimeInterval = 360 // 예: 1시간
    let boosterTimeThreshold: TimeInterval = 600 // 10분 (600초)

// MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setFont()
        updateTimeLabel()
    }
    
// MARK: - Action
    
    @IBAction func levelButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let levelVC = storyboard.instantiateViewController(withIdentifier: "levelVC") as? LevelViewController else {
            return
        }
        
        // 모달로 표시
        levelVC.modalPresentationStyle = .pageSheet
        
        if let sheet = levelVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true  // 손잡이 표시
        }
        
        self.present(levelVC, animated: true, completion: nil)
    }
    
    @IBAction func playButton(_ sender: Any) {
        if timer == nil {
            startTimer()                        // 타이머 시작
        } else {
            timer?.invalidate()                 // 타이머 중지
            timer = nil
        }
    }
    


// MARK: - Function
    
    // 타이머 시작
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
        
    @objc func timerFired() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            updateTimeLabel()       // 타이머가 1초 씩 감소될 마다 화면에 표시
        } else {                    // 시간이 0이 되면 타이머 종료됨
            timer?.invalidate()
            timer = nil
        }
    }
    
    // 현재 남은 시간 화면에 표시
    func updateTimeLabel() {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        setColor()
    }
    
    
    func setAttribute() {
        timerOutline.layer.cornerRadius = timerOutline.frame.height/2
        timerOutline.clipsToBounds = true
        timerInline.layer.cornerRadius = timerInline.frame.height/2
        timerInline.clipsToBounds = true
        
        boosterLabel.isHidden = true        // boosterLabel 숨김처리
    }
    
    func setFont() {
        shellNumber.font = UIFont(name: "Pretendard-Regular", size: 16)
        fishNumber.font = UIFont(name: "Pretendard-Regular", size: 16)
        level.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 17)!
        timerLabel.font = UIFont(name: "Pretendard-Semibold", size: 40)
        boosterLabel.font = UIFont(name: "Pretendard-Semibold", size: 16)
    }
    
    func setColor() {
        if timeRemaining <= boosterTimeThreshold {
            let boosterColor = UIColor.emphasizeError
            
            timerOutline.backgroundColor = boosterColor
            timerLabel.textColor = boosterColor
            closedButtonOutlet.setImage(UIImage(named: "end_btn_booster"), for: .normal)
            addButtonOutlet.setImage(UIImage(named: "add_btn_booster"), for: .normal)
            playButtonOutlet.setImage(UIImage(named: "play_btn_booster"), for: .normal)
          
            boosterLabel.isHidden = false            // boosterLabel 표시
        } else {
            boosterLabel.isHidden = true // boosterLabel 숨기기
        }
    }
        
}

