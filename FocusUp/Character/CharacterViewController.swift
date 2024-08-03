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
    }
    
    @IBAction func configureButton(_ sender: Any) {
        self.showBottomSheet()
    }
    
    private func showBottomSheet() {
        // MARK: Show BottomSheetViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // 스토리보드 이름이 "Main"이라 가정
        let contentViewController = storyboard.instantiateViewController(withIdentifier: "ContentViewController")
        
//        let contentViewController = ContentViewController()
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: 500, cornerRadius: 26, dimmedAlpha: 0.4, isPannedable: true)
        
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

