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
    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet var goButton: UIButton!
    @IBOutlet var laterButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBtnClick(_ sender: Any) {
        self.navigateToMainViewController()
    }
    
    @IBAction func laterBtnClick(_ sender: Any) {
        // 알림을 표시할 AlertController 생성
        let alert = UIAlertController(title: "물고기(코인) 5마리가 차감되었습니다.", message: "5분 뒤에 알람이 다시 옵니다.", preferredStyle: .alert)
        self.scheduleNotification(minutes: 5)
        
        // 확인 버튼 추가
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
        }))
        
        // AlertController 표시
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func noBtnClick(_ sender: Any) {
        // 알림을 표시할 AlertController 생성
        let alert = UIAlertController(title: "조개(생명) 하나가 차감되었습니다.", message: nil, preferredStyle: .alert)
        
        // 확인 버튼 추가
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // MainViewController로 이동
            self.navigateToMainViewController()
        }))
        
         // AlertController 표시
         self.present(alert, animated: true, completion: nil)
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
