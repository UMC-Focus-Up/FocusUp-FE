//
//  HomeViewConotroller.swift
//  FocusUp
//
//  Created by 김민지 on 7/24/24.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController, RoutineTableViewControllerDelegate, AlarmViewControllerDelegate {

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
    
    private var tableView: UITableView!
    
    private var routineId: Int = 0                // 루틴 ID를 저장할 변수
    private var goalTime: String = ""             // 루틴 목표 시간을 나타내는 변수

    var timer: Timer?
    var timeElapsed: TimeInterval = 0             // 경과 시간
    
    // 멈춤 시간 추적 타이머
    var pauseTimer: Timer?
    var pauseTimeElapsed: TimeInterval = 0
    let pauseTimeLimit: TimeInterval = 600
    var pauseMessage: UILabel?                    // 멈춤 메시지를 저장할 변수

    // 부스터 시간
    private var boosterTimeThreshold: TimeInterval = 1      // 기본값 설정: 레벨 1로 default
    let maxBoosterTime: TimeInterval = 2                     // 최대 부스터 시간 (3시간)
    
    
// MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupShellfishViewBorder()
        setAttribute()
        setFont()
        
        updateTimeLabel()
    }
    
    // 다른 화면에서 현재 화면으로 돌아올 때만 처리되는 메서드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // routineId 값을 전달하여 처리
        fetchHomeData(routineId: routineId) { [weak self] level in
            guard let self = self else { return }
            self.updateBoosterTimeThreshold(level: level)
            self.updateLevelButtonUI()              // level 버튼 UI 업데이트 호출
        }
    }
    
    
// MARK: - Action

    // MARK: levelButton
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
    

    // MARK: cancelButton
    // cancel 알림 표시
    @IBAction func cancelButton(_ sender: Any) {
        // title 폰트 설정
        let title = "집중 시간을 끝내시겠습니까?"
        let attributedTitle = NSMutableAttributedString(string: title)
        let titleRange = (title as NSString).range(of: title)
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        
        let cancelButtonAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "끝내기 ", style: .default) { _ in
            print("끝: \(self.routineId)")
            
            // Pass the timeElapsed value to CalendarBottomSheet
            let timeElapsedToPass = self.timeElapsed
    
            // maxBoosterTime을 초과했는지 확인
            let hasExceededMaxTime = timeElapsedToPass > self.maxBoosterTime
            
            // 코인알림 표시
            self.showCoinAlert()
            // 타이머 초기화
            self.resetTimer()
            
            // 루틴 종료시 timeElapsed 값 전송하기 위한 API 연동
            self.sendRoutineEndToAPI(routineId: self.routineId, timeElapsed: timeElapsedToPass)
            

            // fetchHomeData 호출
            self.fetchHomeData(routineId: 0) { result in
                // 데이터 로드 완료 후 처리
                print("Home data fetch completed with result: \(result)")
                
            }
        }
        
        cancelButtonAlert.addAction(confirm)

        let closeAlert = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        closeAlert.setValue(UIColor.gray, forKey: "titleTextColor")
        cancelButtonAlert.addAction(closeAlert)

        self.present(cancelButtonAlert, animated: true, completion: nil)
    }
    
    // MARK: addButton
    // 루틴 조회를 위한 addButton
    @IBAction func addButton(_ sender: Any) {
        let routineVC = RoutineTableViewController()

        routineVC.delegate = self
        routineVC.modalPresentationStyle = .pageSheet
        if let sheet = routineVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        self.present(routineVC, animated: true, completion: nil)
    }

    

// MARK: - API
    
    private func fetchHomeData(routineId: Int, completion: @escaping (Int) -> Void = { _ in }) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        let endpoint = "/api/user/home"
        let parameters: [String: Any] = ["routineId": routineId]
        
        print("Fetching home data with parameters: \(parameters)")
        
        // routineId가 없는 경우에는 빈 파라미터를 보내거나 해당 API 엔드포인트가 정상 동작하도록 처리
        APIClient.getRequest(endpoint: endpoint, parameters: parameters, token: token) { (result: Result<HomeResponse, AFError>) in
            switch result {
            case .success(let homeResponse):
                if homeResponse.isSuccess {
                    print("홈화면:\(homeResponse)")
                    
                    if let homeResult = homeResponse.result {

                        self.shellNumber.text = "\(homeResult.life)"
                        self.fishNumber.text = "\(homeResult.point)"
                        
                        if routineId == 0 {
                            self.routineId = 0
                            self.routineLabel.text = "오늘의 루틴 없음"
                        } else {
                            self.routineId = homeResult.routineId
                            self.routineLabel.text = "\(homeResult.routineName)"
                        }
                        
                        self.goalTime = homeResult.goalTime
                        
                        var config = UIButton.Configuration.plain()
                        config.title = "Level \(homeResult.level)"
                        config.baseForegroundColor = homeResult.userLevel ? .black : UIColor(named: "Primary4")
                        self.level.configuration = config
                        
                        self.updateBoosterTimeThreshold(level: homeResult.level)
                        self.updateLevelButtonUI()              // level 버튼 UI 업데이트 호출
                        
                        completion(homeResult.level)
                    } else {
                        print("Error: 홈화면 결과 데이터가 없습니다.")
                    }
                } else {
                    print("API 호출 실패: \(homeResponse.message)")
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
    
    // 서버에 timeElapsed 전송
    private func sendRoutineEndToAPI(routineId: Int, timeElapsed: TimeInterval) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        // timeElapsed를 hour, minute, second, nano로 변환
        let elapsedTime = Int(timeElapsed)
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let formattedTime = String(format: "%02d:%02d", hours, minutes)

        let postRoutineRequest = PostRoutineRequest(execTime: formattedTime)
        
        APIClient.postRequest(endpoint: "/api/routine/\(routineId)", parameters: postRoutineRequest, token: token) { (result: Result<PostRoutineResponse, AFError>) in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    print("Successfully sent routine execTime: \(formattedTime)")

                } else {
                    print("API call failed: \(response.message)")
                }
            case .failure(let error):
                print("Failed to send routine execTime: \(error)")
            }
        }
    }
    
    
// MARK: Function
    
    // RoutineTableViewControllerDelegate 메서드 구현
    func didSelectRoutineIdfromRoutineTableView(_ routineId: Int) {
        self.routineId = routineId
        fetchHomeData(routineId: routineId) { [weak self] level in
            guard let self = self else { return }
            self.updateBoosterTimeThreshold(level: level)
        }
    }
    
    // AlarmViewControllerDelegate 메서드
    func didSelectRoutineIdfromAlarmVC(_ routineId: Int) {
        print("델리게이트 메서드 호출됨")
        self.routineId = routineId
        fetchHomeData(routineId: routineId) { [weak self] level in
            guard let self = self else { return }
            self.updateBoosterTimeThreshold(level: level)
        }
        print("알람통해서 들어온 루틴아이디: \(routineId)")
    }
    
    // 유저 레벨에 따른 부스터 시간 업데이트
    private func updateBoosterTimeThreshold(level: Int) {
        let boosterTimeMapping: [Int: TimeInterval] = [
            1: 600,    // 10분
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
    
// MARK: 타이머 관련 메서드
    // 타이머 시작
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        updateTimeLabel()
    }
          
    @objc private func timerFired() {
        timeElapsed += 1
        updateTimeLabel()
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
     }
     
// MARK: 코인 알람
    // 집중시간: 집중한 시간만큼 적립된 코인 (부스터 타임 포함)
    // 루틴시간: 목표 시간 이상 집중했을 때 지급하는 코인 (고정값 30)
    // 보너스:  루틴 알람을 통해 들어왔을 때 지급하는 코인 (고정값 30)
    // 부스터 타임은 1분에 n배의 코인 휙득 (레벨에 따라 배수가 달라짐) -> 부스터 타임에만 1분에 n배씩 휙득
   
    // 코인 API 연동시 집중시간이랑, 루틴시간만 포함하도록 (보너스는 이미 30코인 추가가 되었기에 값을 넘겨줄 필요가 없음)
    private func calculateCoins() -> (focusCoins: Int, routineCoins: Int) {
        // 코인 휙득 기준 설정
        let normalCoinRate = 1                      // 1분당 1코인
        let routineCoins = 30                       // 루틴 시간에 지급하는 코인
        let boosterMultiplier = 2                   // 레벨에 따른 부스터 타임 배수
        
        var focusCoins = 0
        var earnedRoutineCoins = 0
        
        let boosterTimeThresholdInMinutes = Double(boosterTimeThreshold)
        let maxBoosterTimeInMinutes = Double(maxBoosterTime)
        let timeElapsedInMinutes = timeElapsed / 60.0

        // 집중 시간 코인 계산
        if timeElapsed >= boosterTimeThreshold && timeElapsed <= maxBoosterTime {
            // 부스터 타임 적용
            let normalTimeCoins = Int(boosterTimeThresholdInMinutes) * normalCoinRate
            let boosterTimeCoins = Int((timeElapsedInMinutes - boosterTimeThresholdInMinutes)) * normalCoinRate * boosterMultiplier
            focusCoins += normalTimeCoins + boosterTimeCoins
        } else if timeElapsedInMinutes < boosterTimeThresholdInMinutes {
            // 부스터 타임 전 일반 시간 적용
            focusCoins += Int(timeElapsedInMinutes) * normalCoinRate
        } else if timeElapsedInMinutes > maxBoosterTimeInMinutes {
            // 최대 부스터 시간 이후
            let normalTimeCoins = Int(boosterTimeThresholdInMinutes) * normalCoinRate
            let boosterTimeCoins = Int((maxBoosterTimeInMinutes - boosterTimeThresholdInMinutes)) * normalCoinRate * boosterMultiplier
            focusCoins += normalTimeCoins + boosterTimeCoins
        }
        
        // goalTime을 분 단위로 변환
        let goalTimeInMinutes = convertTimeToMinutes(self.goalTime)
        
        // timeElapsed가 goalTime보다 클 경우에만 루틴 코인 획득
        if timeElapsed >= goalTimeInMinutes {
            earnedRoutineCoins = routineCoins
        }
        
        return (focusCoins, earnedRoutineCoins)
    }
    
    // 시간 문자열을 분 단위로 변환하는 함수
    private func convertTimeToMinutes(_ timeString: String) -> Double {
        let components = timeString.split(separator: ":").map { Double($0) ?? 0 }
        let hours = components.count > 0 ? components[0] : 0
        let minutes = components.count > 1 ? components[1] : 0
        return (hours * 60) + minutes
    }
    
    // 코인 정산알람창
    private func showCoinAlert() {
         let coins = calculateCoins()
         let totalCoins = coins.focusCoins + coins.routineCoins
         
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
    
// MARK: UI SETTING
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

        }
    
    // 레벨 버튼 UI 업데이트 함수
    private func updateLevelButtonUI() {
        guard let config = level.configuration else { return }
        let levelTitle = config.title ?? "Level 1"
        
        // 기본적인 폰트와 텍스트 설정
        let attributedString = NSMutableAttributedString(string: levelTitle)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Regular", size: 17)!, range: NSRange(location: 0, length: levelTitle.count))
        
        // 언더라인 설정
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: levelTitle.count))
        
        // Primary4 색상 적용 여부
        let textColor = config.baseForegroundColor == UIColor(named: "Primary4") ? UIColor(named: "Primary4")! : UIColor.black
        attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: levelTitle.count))
        
        // 설정된 속성을 버튼에 적용
        level.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func setFont() {
        shellNumber.font = UIFont(name: "Pretendard-Medium", size: 16)
        fishNumber.font = UIFont(name: "Pretendard-Medium", size: 16)
        level.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 17)!
        timerLabel.font = UIFont(name: "Pretendard-Semibold", size: 40)
        boosterLabel.font = UIFont(name: "Pretendard-Semibold", size: 16)
    }
}


