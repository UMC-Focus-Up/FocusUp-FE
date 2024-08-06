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
    @IBOutlet weak var routineLabel: UILabel!
    
    var timer: Timer?

    var timeRemaining: TimeInterval = 360 // 예: 1시간
    let boosterTimeThreshold: TimeInterval = 600 // 10분 (600초)

    var timeElapsed: TimeInterval = 590             // 경과 시간
    
    // 멈춤 시간 추적 타이머
    var pauseTimer: Timer?
    var pauseTimeElapsed: TimeInterval = 0
    let pauseTimeLimit: TimeInterval = 600
    var pauseMessage: UILabel?                      // 멈춤 메시지를 저장할 변수

    // 부스터 시간
    let boosterTimeThreshold: TimeInterval = 600    // 10분 (600초)
    let maxBoosterTime: TimeInterval = 10800        // 최대 부스터 시간 (3시간)


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
            sheet.prefersGrabberVisible = true
        }
        
        self.present(levelVC, animated: true, completion: nil)
    }
    
    @IBAction func playButton(_ sender: Any) {
        if timer == nil {
            startTimer()                        // 타이머 시작
            removePauseMessage()                // 타이머 시작 시 멈춤 메시지 제거
            stopPauseTimer()                    // 멈춤 타이머 중지

        } else {
            timer?.invalidate()                 // 타이머 중지
            timer = nil

            stopTimer()
            displayPauseMessage()               // 멈춤 메시지 표시
            startPauseTimer()                   // 멈춤 타이머 시작
        }
    }
    
    
    // cancel 알림 표시
    @IBAction func cancelButton(_ sender: Any) {
        let cancelButtonAlert = UIAlertController(title: "집중 시간을 끝내시겠습니까?", message: nil, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "끝내기 ", style: .default) { _ in
            // 타이머 초기화
            self.resetTimer()
            self.routineLabel.isHidden = true 
            
            // 코인알림 표시
            self.showCoinAlert()
        }
        cancelButtonAlert.addAction(confirm)

        
        let closeAlert = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        closeAlert.setValue(UIColor.gray, forKey: "titleTextColor")
        cancelButtonAlert.addAction(closeAlert)

        self.present(cancelButtonAlert, animated: true, completion: nil)
    }


// MARK: - Function

    // 타이머 시작
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        updateTimeLabel()
    }
          
    @objc func timerFired() {
          timeElapsed += 1
          updateTimeLabel()
      }
    
    // 타이머 중지
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        updateTimeLabel()
    }

    // 멈춤추적 타이머
    func startPauseTimer() {
         pauseTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(pauseTimerFired), userInfo: nil, repeats: true)
     }
     
     func stopPauseTimer() {
         pauseTimer?.invalidate()
         pauseTimer = nil
         pauseTimeElapsed = 0
     }
     
     @objc func pauseTimerFired() {
         pauseTimeElapsed += 1
         if pauseTimeElapsed >= pauseTimeLimit {
             resetTimer()
             showCoinAlert()
         }
     }
    
    // 타이머 초기화
     func resetTimer() {
         stopTimer()            // 타이머 멈춤
         timeElapsed = 0        // 경과 시간 초기화
         updateTimeLabel()      // UI 업데이트
         stopPauseTimer()       // 멈춤 타이머 중지 및 초기화
         removePauseMessage()   // 멈춤 메시지 제거
         routineLabel.isHidden = true
     }
     
    // 코인 알람
     func showCoinAlert() {
         let coinAlertController = UIAlertController(title: "물고기(코인) 80마리 획득!", message: "집중시간 50마리\n 루틴 시간 30마리", preferredStyle: .alert)
         
         let coinConfirm = UIAlertAction(title: "확인", style: .default, handler: nil)
         coinAlertController.addAction(coinConfirm)
         
         self.present(coinAlertController, animated: true, completion: nil)
     }

    
    // 현재 남은 시간 화면에 표시
    func updateTimeLabel() {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        setColor()
    }
    
    
    func setColor() {
        if timeElapsed >= boosterTimeThreshold && timeElapsed < maxBoosterTime {
            // 부스터 상태
            let boosterColor = UIColor.emphasizeError
            
            timerOutline.backgroundColor = boosterColor
            timerLabel.textColor = boosterColor
            closedButtonOutlet.setImage(UIImage(named: "end_btn_booster"), for: .normal)
            addButtonOutlet.setImage(UIImage(named: "add_btn_booster"), for: .normal)
 
            if timer == nil {
                print("Setting playButton to play_btn_booster")

                playButtonOutlet.setImage(UIImage(named: "play_btn_booster"), for: .normal)
            } else {
                print("Setting playButton to stop_btn_booster")

                playButtonOutlet.setImage(UIImage(named: "stop_btn_booster"), for: .normal)
            }
          
            boosterLabel.isHidden = false            // boosterLabel 표시
        } else {
            
            let originColor = UIColor.primary4
            
            timerOutline.backgroundColor = originColor
            timerLabel.textColor = originColor
            closedButtonOutlet.setImage(UIImage(named: "end_btn"), for: .normal)
            addButtonOutlet.setImage(UIImage(named: "add_btn"), for: .normal)
            
            if timer == nil {
                playButtonOutlet.setImage(UIImage(named: "play_btn"), for: .normal)
            } else {
                playButtonOutlet.setImage(UIImage(named: "stop_btn"), for: .normal)
            }
            
            boosterLabel.isHidden = true            // boosterLabel 숨기기
        }
    }
    
    
    
    func displayPauseMessage() {
        if pauseMessage == nil {
            let newPauseMessage = UILabel()
            newPauseMessage.textColor = .emphasizeError
            newPauseMessage.numberOfLines = 2
            newPauseMessage.font = UIFont(name: "Pretendard-Semibold", size: 14)
            newPauseMessage.translatesAutoresizingMaskIntoConstraints = false
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.alignment = .center
            
            let attributedText = NSMutableAttributedString(
                string: "멈춤 허용시간은 최대 10분입니다.\n 10분을 넘기면 집중 시간이 종료됩니다.",
                attributes: [
                    .paragraphStyle: paragraphStyle,
                    .font: newPauseMessage.font as Any,
                    .foregroundColor: newPauseMessage.textColor as Any
                ]
            )
            
            newPauseMessage.attributedText = attributedText
            view.addSubview(newPauseMessage)
            
            NSLayoutConstraint.activate([
                newPauseMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                newPauseMessage.topAnchor.constraint(equalTo: timerOutline.bottomAnchor, constant: 20)
            ])
            
            pauseMessage = newPauseMessage
        }
    }
    
    func removePauseMessage() {
           pauseMessage?.removeFromSuperview()
           pauseMessage = nil
    }
    
    func setAttribute() {
        timerOutline.layer.cornerRadius = timerOutline.frame.height/2
        timerOutline.clipsToBounds = true
        timerInline.layer.cornerRadius = timerInline.frame.height/2
        timerInline.clipsToBounds = true
        
        boosterLabel.isHidden = true        // boosterLabel 숨김처리
        
        // level 버튼 언더라인 추가
        if let title = level.title(for: .normal) {
            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: title.count))
            level.setAttributedTitle(attributedString, for: .normal)
        }
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

