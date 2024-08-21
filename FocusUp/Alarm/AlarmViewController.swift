//
//  AlarmViewController.swift
//  FocusUp
//
//  Created by 김서윤 on 8/2/24.
//

import UIKit
import UserNotifications
import Alamofire

protocol AlarmViewControllerDelegate: AnyObject {
    func didSelectRoutineIdfromAlarmVC(_ routineId: Int)
}

class AlarmViewController: UIViewController {
    
    weak var delegate: AlarmViewControllerDelegate?
    
    @IBOutlet weak var shellNum: UILabel!
    @IBOutlet weak var fishNum: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet var goButton: UIButton!
    @IBOutlet var laterButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    @IBOutlet var goNum: UILabel!
    @IBOutlet var laterNum: UILabel!
    @IBOutlet var noNum: UILabel!
    
    var name: String?
    var startTime: Date?
    var alarmID: Int?
    var userInfo: [String: Any]?
    var life: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let name = name, let startTime = startTime {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "a hh:mm"
            timeLabel.text = timeFormatter.string(from: startTime)
            contentLabel.text = "< \(name) >"
        }
        
        if let alarmID = alarmID {
            print("알람 ID: \(alarmID)") // ID를 UI에서 사용할 수 있습니다.
        } else {
            print("알람 ID가 설정되지 않았습니다.") // 디버깅 메시지 추가
        }
        
        // 생명, 코인 수 API 연동
        fetchLifeAndPoints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMinusSelecteddNotification), name: .minusSelected, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLifeAndPoints()
    }

    
    @objc private func handleMinusSelecteddNotification() {
        fetchLifeAndPoints()
    }
    
    @IBAction func goBtnClick(_ sender: Any) {
        // `alarmID`가 nil인지 확인
        guard let alarmID = alarmID else {
            print("Error: alarmID is nil.")
            return
        }
        
        // Option 0으로 설정하고 서버에 POST 요청 전송
        self.sendAlarmActionRequest(option: .now)
        delegate?.didSelectRoutineIdfromAlarmVC(alarmID)
        navigateToMainViewController()                      // 홈화면으로 이동
    }
    
    @IBAction func laterBtnClick(_ sender: Any) {
        // "title"
        let fullText = "물고기(코인) 5마리가\n 차감되었습니다."
        let attributedTitle = NSMutableAttributedString(string: fullText)
        
        // 전체에 Semibold 16px 적용
        let titleRange = (fullText as NSString).range(of: fullText)
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        // “5마리”에 Primary4 색상 적용
        let fishCountRange = (fullText as NSString).range(of: "5마리")
        attributedTitle.addAttribute(.foregroundColor, value: UIColor(named: "Primary4")!, range: fishCountRange)

        // “차감”에 EmphasizeError 색상 적용
        let deductionRange = (fullText as NSString).range(of: "차감")
        attributedTitle.addAttribute(.foregroundColor, value: UIColor(named: "EmphasizeError")!, range: deductionRange)

        // UIAlertController 생성
        let alert = UIAlertController(title: "", message: "5분 뒤에 알람이 다시 옵니다.", preferredStyle: .alert)
        
        // NSAttributedString을 title에 설정
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let confirm = UIAlertAction(title: "확인", style: .default) { action in
            
            // Option 1로 설정하고 서버에 POST 요청 전송
            self.sendAlarmActionRequest(option: .later)
            NotificationCenter.default.post(name: .minusSelected, object: nil)
            
            // 현재 화면을 닫고 메인 뷰 컨트롤러로
            self.navigateToMainViewController()
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        self.scheduleNotification(minutes: 5)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func noBtnClick(_ sender: Any) {
        // "title"
        let fullText = "조개(생명) 하나가 차감되었습니다."
        let attributedTitle = NSMutableAttributedString(string: fullText)
        
        // "title"에 Semibold 16px 적용
        let titleRange = (fullText as NSString).range(of: fullText)
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        // “하나”에 Primary4 색상 적용
        let oneRange = (fullText as NSString).range(of: "하나")
        attributedTitle.addAttribute(.foregroundColor, value: UIColor(named: "Primary4")!, range: oneRange)

        // “차감”에 EmphasizeError 색상 적용
        let deductionRange = (fullText as NSString).range(of: "차감")
        attributedTitle.addAttribute(.foregroundColor, value: UIColor(named: "EmphasizeError")!, range: deductionRange)

        // UIAlertController 생성
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        // NSAttributedString을 title에 설정
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let confirm = UIAlertAction(title: "확인", style: .default) { action in
            
            // Option 2로 설정하고 서버에 POST 요청 전송
            self.sendAlarmActionRequest(option: .no)
            NotificationCenter.default.post(name: .minusSelected, object: nil)
            
            // 현재 화면을 닫고 메인 뷰 컨트롤러로
            if self.life ?? 0 > 0 {
                self.navigateToMainViewController()
            } else {
                self.navigateToCharacterViewController()
                NotificationCenter.default.post(name: .zeroAlert, object: nil)
            }
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    private func sendAlarmActionRequest(option: AlarmOption) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        guard let alarmID = alarmID else {
            print("알람 ID가 없습니다.")
            return
        }
        
        let parameters = AlarmRequestModel(routineId: alarmID, option: option)
        
        let endpoint = "/api/alarm/user/\(alarmID)?option=\(option.rawValue)"
        
        APIClient.postRequest(endpoint: endpoint, parameters: parameters, token: token) { (result: Result<AlarmResponse, AFError>) in
            switch result {
            case .success(let response):
                print("알람 버튼 클릭 성공")
                let life = response.result?.life
            case .failure(let error):
                print("알람 버튼 클릭 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotification(minutes: Int) {
        // 현재 시간에서 지정한 분만큼 더한 새 알람 시간 계산
        guard let newDate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date()) else { return }

        // 새 알람 시간의 DateComponents를 추출
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: newDate)

        // 트리거 생성 (새 알람 시간에 알람이 울리도록 설정)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // 알람 콘텐츠 설정
        let content = UNMutableNotificationContent()
        content.title = "루틴 실행할 시간이에요! ⏰️"
        
        // name이 nil이 아닐 때만 content.body에 값을 설정
        if let name = name {
            content.body = "< \(name) >"
        } else {
            content.body = "< 루틴 이름 없음 >" // 기본값 설정
        }
        
        content.sound = .default
        
        // userInfo를 기존 알람의 userInfo로 설정
        if let userInfo = userInfo {
            content.userInfo = userInfo
        } else {
            content.userInfo = ["alarmID": alarmID ?? -1, "name": name ?? "알림", "startTime": startTime ?? Date(), "targetScene": "Alarm"]
        }

        // 고유 식별자를 가진 알람 요청 생성
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 알람 요청을 UNUserNotificationCenter에 추가
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알람 추가 오류: \(error.localizedDescription)")
            } else {
                print("알람이 \(newDate)로 설정되었습니다.")
            }
        }
    }
    
    private func navigateToCharacterViewController() {
        // 스토리보드에서 CustomTabBarController 인스턴스 생성
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController") as? CustomTabBarController else {
            print("CustomTabBarController를 찾을 수 없습니다.")
            return
        }
        
        // 원하는 탭 인덱스로 이동 (예: 캐릭터 뷰가 2번째 탭이라면 index는 1)
        tabBarController.selectedIndex = 1
        
        // 화면을 완전히 대체하도록 modalPresentationStyle 설정
        tabBarController.modalPresentationStyle = .fullScreen
        
        // MainViewController로 이동
        self.present(tabBarController, animated: true, completion: nil)
    }
    
    private func navigateToMainViewController() {
        // 스토리보드에서 MainViewController 인스턴스 생성
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainVC = storyboard.instantiateViewController(withIdentifier: "CustomTabBarController") as? CustomTabBarController else {
            print("CustomTabBarController를 찾을 수 없습니다.")
            return
        }
        
        // 화면을 완전히 대체하도록 modalPresentationStyle 설정
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.selectedIndex = 0  // Assuming the home screen is the first tab
        
        // MainViewController로 이동
        self.view.window?.rootViewController = mainVC
        self.view.window?.makeKeyAndVisible()
    }
    
    private func setupUI() {
        // Do any additional setup after loading the view.

        shellNum.font = UIFont.pretendardMedium(size: 16)
        fishNum.font = UIFont.pretendardMedium(size: 16)
        
        timeLabel.font = UIFont.pretendardSemibold(size: 48)
        textLabel.font = UIFont.pretendardRegular(size: 16)
        contentLabel.font = UIFont.pretendardBold(size: 20)
        
        goButton.titleLabel?.font = UIFont.pretendardMedium(size: 15)
        laterButton.titleLabel?.font = UIFont.pretendardMedium(size: 15)
        noButton.titleLabel?.font = UIFont.pretendardMedium(size: 15)
        
        goNum.font = UIFont.pretendardMedium(size: 15)
        laterNum.font = UIFont.pretendardMedium(size: 15)
        noNum.font = UIFont.pretendardMedium(size: 15)
    }
    
// MARK: API 연동
    
    // 생명과 코인 API 연동
    private func fetchLifeAndPoints() {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        APIClient.getRequest(endpoint: "/api/alarm/user", token: token) { (result: Result<AlarmUserResponse, AFError>) in
            switch result {
            case .success(let response):
                let life = response.result.life
                let point = response.result.point
                DispatchQueue.main.async {
                    self.shellNum.text = "\(life)" // 생명 정보를 라벨에 표시
                    self.fishNum.text = "\(point)"
                }
            case .failure(let error):
                print("Failed to fetch life data: \(error)")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .minusSelected, object: nil)
    }
}

extension Notification.Name {
    static let minusSelected = Notification.Name("minusSelected")
    static let zeroAlert = Notification.Name("zeroAlert")
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
