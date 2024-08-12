//
//  CharacterViewController.swift
//  FocusUp
//
//  Created by 김서윤 on 7/24/24.
//

import UIKit
import Alamofire
import UserNotifications

class CharacterViewController: UIViewController {
    @IBOutlet var shellfishView: UIView!
    @IBOutlet var bottomButton: UIButton!
    @IBOutlet var shopButton: UIButton!
    @IBOutlet var bgView: UIImageView!
    @IBOutlet var firstBubbleView: UIImageView!
    
    @IBOutlet var shellNum: UILabel!
    @IBOutlet var fishNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShellfishViewBorder()
        setupBottomButtonBorder()
        setupShopButtonAppearance()
        shopButton.configureButtonWithTitleBelowImage(spacing: 6.0)
        
        fetchDataFromURL()
        scheduleCharacterNotification()
        
        shellNum.font = UIFont.pretendardMedium(size: 16)
        fishNum.font = UIFont.pretendardMedium(size: 16)
        
        // 앱이 실행될 때마다 firstBubbleView를 3초 동안 표시
        firstBubbleView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.firstBubbleView.isHidden = true
        }
        
        // bgView에 tap gesture recognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bgViewTapped))
        bgView.isUserInteractionEnabled = true
        bgView.addGestureRecognizer(tapGesture)
    }
    
    private func setupBottomButtonBorder() {
        let borderLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bottomButton.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 26.0, height: 26.0))
        
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor(red: 234/255.0, green: 236/255.0, blue: 240/255.0, alpha: 1.0).cgColor
        borderLayer.lineWidth = 1.0
        
        bottomButton.layer.sublayers?.removeAll { $0 is CAShapeLayer }
        
        bottomButton.layer.addSublayer(borderLayer)
    }
    
    private func setupShellfishViewBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: shellfishView.frame.height - 1, width: shellfishView.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor(red: 229/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0).cgColor
        
        shellfishView.layer.sublayers?.removeAll { $0.backgroundColor == bottomBorder.backgroundColor }
        
        shellfishView.layer.addSublayer(bottomBorder)
    }
    
    private func setupShopButtonAppearance() {
        shopButton.layer.shadowColor = UIColor(red: 34/255.0, green: 88/255.0, blue: 113/255.0, alpha: 0.3).cgColor
        shopButton.layer.shadowOffset = CGSize(width: 0, height: 2) // 0px 2px
        shopButton.layer.shadowRadius = 2 // 2px
        shopButton.layer.shadowOpacity = 1
        shopButton.layer.masksToBounds = false
        
        shopButton.layer.cornerRadius = 12
        shopButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        shopButton.titleLabel?.font = UIFont.pretendardSemibold(size: 14)
    }
    
    @IBAction func configureButton(_ sender: Any) {
        self.showBottomSheet()
    }
    
    @IBAction func configureShopButton(_ sender: Any) {
        showShopBottomSheet()
    }
    
    @objc private func bgViewTapped() {
            // "조개껍데기"를 제목으로 didTapItem 호출
            didTapItem(withTitle: "조개껍데기")
        }
    
    private func showBottomSheet() {
        // MARK: Show BottomSheetViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // 스토리보드 이름 "Main"
        let contentViewController = storyboard.instantiateViewController(withIdentifier: "ContentViewController")
        
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: 500, cornerRadius: 26, dimmedAlpha: 0.4, isPannedable: true)
        
        self.present(bottomSheetViewController, animated: true)
    }
    
    private func showShopBottomSheet() {
        // MARK: Show BottomSheetViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // 스토리보드 이름 "Main"
        let shopViewController = storyboard.instantiateViewController(withIdentifier: "ShopViewController")
        
        let bottomSheetViewController = BottomSheetViewController(contentViewController: shopViewController, defaultHeight: 500, cornerRadius: 26, dimmedAlpha: 0.4, isPannedable: true)
        
        self.present(bottomSheetViewController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBottomButtonBorder()
        setupShellfishViewBorder()
        setupShopButtonAppearance()
    }
    
    private func fetchDataFromURL() {
        // Alamofire를 사용하여 GET 요청을 보냅니다.
        let url = "http://15.165.198.110:80/test"
        AF.request(url, method: .get).response { response in
            // 응답을 받았는지 확인합니다.
            if let error = response.error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // 상태 코드와 응답 데이터 처리
            if let statusCode = response.response?.statusCode {
                print("HTTP Status Code: \(statusCode)")
            }

            if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
        }
    }
    
    private func scheduleCharacterNotification() {
        // 알림 예약 예제: 현재 시간에서 10초 후
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .second, value: 5, to: now)!
        
        // UNUserNotificationCenter 인스턴스를 가져옴
        UNUserNotificationCenter.current().addNotificationRequest(date: futureDate) { error in
            if let error = error {
                print("Error adding notification request: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(futureDate)")
            }
        }
    }
    
    func didTapItem(withTitle title: String) {
        // "title" 부분은 Semibold 16px, "을(를) 삭제하시겠습니까?" 부분은 Medium 16px 폰트를 적용
        let fullText = "\(title)을(를) 삭제하시겠습니까?"
        let attributedTitle = NSMutableAttributedString(string: fullText)
        
        // "title"에 Semibold 16px 적용
        let titleRange = (fullText as NSString).range(of: title)
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        // "을(를) 삭제하시겠습니까?"에 Medium 16px 적용
        let messageRange = (fullText as NSString).range(of: "을(를) 삭제하시겠습니까?")
        attributedTitle.addAttribute(.font, value: UIFont.pretendardMedium(size: 16), range: messageRange)
        
        // UIAlertController 생성
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        // NSAttributedString을 title에 설정
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
        cancel.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirm = UIAlertAction(title: "삭제", style: .default) { action in
            print("\(title) 삭제")
        }
        confirm.setValue(UIColor(named: "EmphasizeError"), forKey: "titleTextColor")
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
}

extension UIButton {
    func configureButtonWithTitleBelowImage(spacing: CGFloat = 4.0) {
        guard let currentImage = self.imageView?.image,
              let currentTitle = self.titleLabel?.text else {
            return
        }
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = currentImage
        configuration.title = currentTitle
        configuration.imagePlacement = .top
        configuration.imagePadding = spacing
        
        self.configuration = configuration
    }
}

