//
//  HomeViewConotroller.swift
//  FocusUp
//
//  Created by 김민지 on 7/24/24.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {
    
    @IBOutlet weak var shellfishView: UIView!
    @IBOutlet weak var shellNumber: UILabel!
    @IBOutlet weak var fishNumber: UILabel!
    @IBOutlet weak var level: UIButton!
    
    @IBOutlet weak var timerOutline: UIView!
    @IBOutlet weak var timerInline: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var boosterLabel: UILabel!
    @IBOutlet weak var routineLabel: UILabel!
    
    @IBOutlet weak var closedButtonOutlet: UIButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    private var routineId: Int?                   // 루틴 ID를 저장할 변수
    
    var timer: Timer?
    var timeElapsed: TimeInterval = 0             // 경과 시간
    
    // 멈춤 시간 추적 타이머
    var pauseTimer: Timer?
    var pauseTimeElapsed: TimeInterval = 0
    let pauseTimeLimit: TimeInterval = 600
    var pauseMessage: UILabel?                      // 멈춤 메시지를 저장할 변수

    // 부스터 시간
    private var boosterTimeThreshold: TimeInterval = 600      // 기본값 설정: 레벨 1로 default
    let maxBoosterTime: TimeInterval = 2                     // 최대 부스터 시간 (3시간)
//    var boosterTimeThreshold: TimeInterval = 600    // 10분 (600초) : 레벨 1로 default 값으로 둠
//    let maxBoosterTime: TimeInterval = 10800        // 최대 부스터 시간 (3시간)

    private var isInBoosterTime = false
    
// MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupShellfishViewBorder()
        setAttribute()
        setFont()
        
        // Fetching API
        fetchLifeData()                                     // 생명 수 연동
        fetchHomeData { [weak self] level in                // 홈화면에 데이터 업데이트
            guard let self = self else { return }
            self.updateBoosterTimeThreshold(level: level)
        }
        
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
            stopTimer()
            displayPauseMessage()               // 멈춤 메시지 표시
            startPauseTimer()                   // 멈춤 타이머 시작
        }
    }
    
    
    // cancel 알림 표시
    @IBAction func cancelButton(_ sender: Any) {
        // title 폰트 설정
        let title = "집중 시간을 끝내시겠습니까?"
        let attributedTitle = NSMutableAttributedString(string: title)
        let titleRange = (title as NSString).range(of: title)
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        
        let cancelButtonAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "끝내기 ", style: .default) { _ in
            
            // 코인알림 표시
            self.showCoinAlert()
            // 타이머 초기화
            self.resetTimer()
            self.routineLabel.isHidden = true
            
            // Call the API to complete the routine
            
        }
        
        cancelButtonAlert.addAction(confirm)

        let closeAlert = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        closeAlert.setValue(UIColor.gray, forKey: "titleTextColor")
        cancelButtonAlert.addAction(closeAlert)

        self.present(cancelButtonAlert, animated: true, completion: nil)
    }
    
    
    // 루틴 조회를 위한 addButton
    @IBAction func addButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let goalRoutineVC = storyboard.instantiateViewController(withIdentifier: "GoalRoutineListViewController") as? GoalRoutineListViewController {
            goalRoutineVC.isAddMode = false // 추가 모드가 아니도록 설정
            
            if let sheet = goalRoutineVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            self.present(goalRoutineVC, animated: true, completion: nil)
        }
    }
    

// MARK: - API
    
    // 생명 정보를 가져오기 위한 API 연동
     private func fetchLifeData() {
         guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
             print("Error: No access token found.")
             return
         }
         
         APIClient.getRequest(endpoint: "/api/alarm/user", token: token) { (result: Result<AlarmUserResponse, AFError>) in
             switch result {
             case .success(let response):
                 let life = response.result.life
                 DispatchQueue.main.async {
                     self.shellNumber.text = "\(life)" // 생명 정보를 라벨에 표시
                 }
             case .failure(let error):
                 print("Failed to fetch life data: \(error)")
             }
         }
     }


    private func fetchHomeData(completion: @escaping (Int) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        let endpoint = "/api/user/home"
        
        APIClient.getRequest(endpoint: endpoint, token: token) { (result: Result<HomeResponse, AFError>) in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    DispatchQueue.main.async {
                        print("홈화면:\(response)")
                        let result = response.result
                        self.routineId = result.routineId       // 홈화면에서 조회되는 루틴 ID 저장 => 루틴 알람 완료에서 사용
                        self.routineLabel.text = result.routineName.isEmpty ? "오늘의 루틴 없음" : result.routineName
                        self.shellNumber.text = "\(result.life)"
                        self.fishNumber.text = "\(result.point)"
                        self.level.setAttributedTitle(nil, for: .normal)
                        self.level.setTitle("Level \(result.level)", for: .normal)
                        self.level.layoutIfNeeded()

                        // 클로저를 통해 level 값 전달
                        completion(result.level)
                    }
                } else {
                    print("API 호출 실패: \(response.message)")
                }
            case .failure(let error):
                print("API 호출 실패: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func sendCoinDataToAPI(totalCoins: Int) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        let pointData = SendCoinData(point: totalCoins)
        
        APIClient.postRequest(endpoint: "/api/user/addPoint", parameters: pointData, token: token) { (result: Result<EmptyResponse, AFError>) in
            switch result {
            case .success:
                print("Successfully sent point data: \(pointData)")
            case .failure(let error):
                print("Failed to send point data: \(error)")
            }
        }
    }
    
    private func sendPostRoutineRequest() {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
    }
    
    
    
// MARK: Function
    
    // 유저 레벨에 따른 부스터 시간 업데이트
    private func updateBoosterTimeThreshold(level: Int) {
        let boosterTimeMapping: [Int: TimeInterval] = [
            1: 1,    // 10분
            2: 1200,   // 20분
            3: 1800,   // 30분
            4: 2700,   // 45분
            5: 3600,   // 60분
            6: 4500,   // 75분
            7: 5400    // 90분
        ]
        
        if let threshold = boosterTimeMapping[level] {
            boosterTimeThreshold = threshold
        } else {
            boosterTimeThreshold = 600
        }
    }
    
    // 타이머 시작
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        updateTimeLabel()
    }
    
    private func notifyBoosterTimeEntry() {
        NotificationCenter.default.post(name: .boosterTimeEntered, object: nil)
    }
          
    @objc private func timerFired() {
        timeElapsed += 1
        updateTimeLabel()
        
        // 부스터 타임 진입 여부 확인
        if timeElapsed >= boosterTimeThreshold && timeElapsed < maxBoosterTime {
            if !isInBoosterTime {
                notifyBoosterTimeEntry()  // 부스터 타임에 처음 진입한 경우에만 알림을 보냅니다.
                isInBoosterTime = true    // 부스터 타임에 진입했음을 기록합니다.
            }
        } else {
            isInBoosterTime = false  // 부스터 타임에서 벗어났음을 기록합니다.
        }
    }
      
    
    // 타이머 중지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        updateTimeLabel()
    }

    // 멈춤추적 타이머
    private func startPauseTimer() {
         pauseTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(pauseTimerFired), userInfo: nil, repeats: true)
     }
     
    private func stopPauseTimer() {
         pauseTimer?.invalidate()
         pauseTimer = nil
         pauseTimeElapsed = 0
     }
     
    @objc private func pauseTimerFired() {
         pauseTimeElapsed += 1
         if pauseTimeElapsed >= pauseTimeLimit {
             resetTimer()
             showCoinAlert()
         }
     }
    
    // 타이머 초기화
    private func resetTimer() {
         stopTimer()                // 타이머 멈춤
         let coins = calculateCoins()
         timeElapsed = 0            // 경과 시간 초기화
         updateTimeLabel()          // UI 업데이트
         stopPauseTimer()           // 멈춤 타이머 중지 및 초기화
         removePauseMessage()       // 멈춤 메시지 제거
         routineLabel.isHidden = true
     }
     
    // 코인 알람
    // 집중시간: 집중한 시간만큼 적립된 코인 (부스터 타임 포함)
    // 루틴시간: 루틴 알림을 통해 들어오고, 목표 시간 이상 집중했을 때 지급하는 코인 (고정값 30)
    // 보너스:  루틴 알람을 통해 들어왔을 때 지급하는 코인 (고정값 30)
    // 부스터 타임은 1분에 n배의 코인 휙득 (레벨에 따라 배수가 달라짐) -> 부스터 타임에만 1분에 n배씩 휙득
   
    // 코인 API 연동시 집중시간이랑, 루틴시간만 포함하도록 (보너스는 이미 30코인 추가가 되었기에 값을 넘겨줄 필요가 없음)
    private func calculateCoins() -> (focusCoins: Int, routineCoins: Int, bonusCoins: Int) {
        // 코인 휙득 기준 설정
        let normalCoinRate = 1                      // 1분당 1코인
        let routineCoins = 30                       // 루틴 시간에 지급하는 코인
        let bonusThreshold: TimeInterval = 3600     // 보너스 지급 기준
        let bonusCoins = 30                         // 보너스 코인
        let boosterMultiplier = 2                   // 레벨에 따른 부스터 타임 배수
        
        var focusCoins = 0
        
        // 집중 시간 코인 계산
        if timeElapsed >= boosterTimeThreshold && timeElapsed <= maxBoosterTime {
            // 부스터 타임 적용
            let normalTimeCoins = Int(boosterTimeThreshold / 60) * normalCoinRate
            let boosterTimeCoins = Int((timeElapsed - boosterTimeThreshold) / 60) * normalCoinRate * boosterMultiplier
            focusCoins += normalTimeCoins + boosterTimeCoins
        } else if timeElapsed < boosterTimeThreshold {
            // 부스터 타임 전 일반 시간 적용
            focusCoins += Int(timeElapsed / 60) * normalCoinRate
        } else if timeElapsed > maxBoosterTime {
            // 최대 부스터 시간 이후
            let normalTimeCoins = Int(boosterTimeThreshold / 60) * normalCoinRate
            let boosterTimeCoins = Int((maxBoosterTime - boosterTimeThreshold) / 60) * normalCoinRate * boosterMultiplier
            focusCoins += normalTimeCoins + boosterTimeCoins
        }

        // 보너스 코인 추가
        if timeElapsed >= bonusThreshold {
            focusCoins += bonusCoins
        }

        return (focusCoins, routineCoins, bonusCoins)
    }
    
    // 코인 정산알람창
    private func showCoinAlert() {
         let coins = calculateCoins()
         let totalCoins = coins.focusCoins + coins.routineCoins + coins.bonusCoins
         
         // title 폰트 및 색상 설정
         let title = "물고기(코인) \(totalCoins)마리 획득!"
         let attributedTitle = NSMutableAttributedString(string: title)
         
         let titleRange = (title as NSString).range(of: title)
         attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
         let coinRange = (title as NSString).range(of: "\(totalCoins)")
         attributedTitle.addAttribute(.foregroundColor, value: UIColor(named: "Primary4")!, range: coinRange)
         
         // message 설정
         var message = "집중시간 \(coins.focusCoins)마리"
         
         // 루틴 코인이 있는 경우 메시지에 추가
         if coins.routineCoins > 0 {
             message += "\n 루틴 시간 \(coins.routineCoins)마리"
         }
         // 보너스 코인이 있는 경우 메시지에 추가
         if coins.bonusCoins > 0 {
             message += "\n 보너스 \(coins.bonusCoins)마리"
         }
         
         let coinAlertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
         )
         
         coinAlertController.setValue(attributedTitle, forKey: "attributedTitle")
         
         let coinConfirm = UIAlertAction(title: "확인", style: .default, handler: nil)
         coinAlertController.addAction(coinConfirm)
         
         self.present(coinAlertController, animated: true, completion: nil)
         
         // fishNumber 업데이트
         if let currentFishCoins = Int(fishNumber.text ?? "0") {
             let newFishCoins = currentFishCoins + totalCoins
             fishNumber.text = "\(newFishCoins)"
         }
        
        // 코인 휙득 후 API에 데이터 전송
        sendCoinDataToAPI(totalCoins: totalCoins)
     }
    
    
    // 현재 남은 시간 화면에 표시
    private func updateTimeLabel() {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        setColor()
    }
    
    
    private func setColor() {
        if timeElapsed >= boosterTimeThreshold && timeElapsed < maxBoosterTime {
            // 부스터 상태
            let boosterColor = UIColor.emphasizeError
            
            timerOutline.backgroundColor = boosterColor
            timerLabel.textColor = boosterColor
            closedButtonOutlet.setImage(UIImage(named: "end_btn_booster"), for: .normal)
            addButtonOutlet.setImage(UIImage(named: "add_btn_booster"), for: .normal)
 
            if timer == nil {
                playButtonOutlet.setImage(UIImage(named: "play_btn_booster"), for: .normal)
            } else {
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
    
    
    
    private func displayPauseMessage() {
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
    
    private func removePauseMessage() {
           pauseMessage?.removeFromSuperview()
           pauseMessage = nil
    }
    
    
    // shellfishView 아래 테두리 추가
    private func setupShellfishViewBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: shellfishView.frame.height - 1, width: shellfishView.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor(red: 229/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0).cgColor
        
        shellfishView.layer.sublayers?.removeAll { $0.backgroundColor == bottomBorder.backgroundColor }
        
        shellfishView.layer.addSublayer(bottomBorder)
    }
    
    private func setAttribute() {
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
    
    private func setFont() {
        shellNumber.font = UIFont(name: "Pretendard-Medium", size: 16)
        fishNumber.font = UIFont(name: "Pretendard-Medium", size: 16)
        level.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 17)!
        timerLabel.font = UIFont(name: "Pretendard-Semibold", size: 40)
        boosterLabel.font = UIFont(name: "Pretendard-Semibold", size: 16)
    }
}

