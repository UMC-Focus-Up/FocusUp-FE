//
//  AlarmViewController.swift
//  FocusUp
//
//  Created by 김서윤 on 8/2/24.
//

import UIKit
import UserNotifications

class AlarmViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet var goButton: UIButton!
    @IBOutlet var laterButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    @IBOutlet var goNum: UILabel!
    @IBOutlet var laterNum: UILabel!
    @IBOutlet var noNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
    
    @IBAction func goBtnClick(_ sender: Any) {
        self.navigateToMainViewController()
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
            print("5분 뒤 알람")
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
            self.navigateToMainViewController()
            print("조개 차감")
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func scheduleNotification(minutes: Int) {
        // 현재 시간에서 지정한 분만큼 더한 새 알람 시간 계산
        let newDate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date())!
        
        // 알람 요청 생성
        UNUserNotificationCenter.current().addNotificationRequest(date: newDate) { error in
            if let error = error {
                print("알람 추가 오류: \(error.localizedDescription)")
            } else {
                print("알람이 \(newDate)로 설정되었습니다.")
            }
        }
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
        
        // MainViewController로 이동
        self.present(mainVC, animated: true, completion: nil)
    }
    
}

extension UNUserNotificationCenter {
    func addNotificationRequest(date: Date, completionHandler: @escaping (Error?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "루틴 실행할 시간이에요! ⏰️"
        content.body = "< 매일 30분 독서하기 >"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["targetScene": "Alarm"]
        
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        self.add(request, withCompletionHandler: completionHandler)
    }
}
