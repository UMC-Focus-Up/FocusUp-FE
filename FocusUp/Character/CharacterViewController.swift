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
        
        shellNum.font = UIFont.pretendardMedium(size: 16)
        fishNum.font = UIFont.pretendardMedium(size: 16)
        
        // 캐릭터 정보를 조회합니다.
        fetchCharacterInfo()
        scheduleCharacterNotification()
        
        // 앱이 실행될 때마다 firstBubbleView를 3초 동안 표시
        firstBubbleView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.firstBubbleView.isHidden = true
        }
        
        // bgView에 tap gesture recognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bgViewTapped))
        bgView.isUserInteractionEnabled = true
        bgView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleItemPurchasedNotification), name: .itemPurchased, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleItemSelectedNotification), name: .itemSelected, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCharacterInfo()
    }
    
    @objc private func handleItemPurchasedNotification() {
        fetchCharacterInfo()
    }
    
    @objc private func handleItemSelectedNotification() {
        fetchCharacterInfo()
    }
    
    private var shouldShowAlert = false
    private var itemTitle: String?
    
    // MARK: - 캐릭터 정보 조회
    private func fetchCharacterInfo() {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        APIClient.getRequest(endpoint: "/api/user/character", token: token) { (result: Result<CharacterResponse, AFError>) in
            switch result {
            case .success(let characterResponse):
                if characterResponse.isSuccess {
                    if let characterResult = characterResponse.result {
                        self.shellNum.text = "\(characterResult.life)"
                        self.fishNum.text = "\(characterResult.point)"
                        
                        // status가 false이면 bgView의 배경을 "bg_character" 이미지로 설정
                        if !characterResult.status {
                            self.bgView.image = UIImage(named: "bg_character")
                            self.shouldShowAlert = false // 알림 표시하지 않음
                            self.itemTitle = nil // item이 없으므로 itemTitle도 nil로 설정
                        } else if let item = characterResult.item {
                            // item이 있는 경우, 해당 title에 맞는 이미지를 설정
                            if let characterUI = CharacterUI.data.first(where: { $0.title == item.name }) {
                                self.bgView.image = UIImage(named: characterUI.image)
                            }
                            self.shouldShowAlert = true // 알림 표시하도록 설정
                            self.itemTitle = item.name // item의 title을 저장
                        } else {
                            // item이 없는 경우, "ui_character" 이미지를 설정
                            self.bgView.image = UIImage(named: "ui_character")
                            self.shouldShowAlert = false // 알림 표시하지 않음
                            self.itemTitle = nil // item이 없으므로 itemTitle도 nil로 설정
                        }
                        
                        print("Character info successfully fetched.")
                    }
                } else {
                    print("Error: \(characterResponse.message)")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func bgViewTapped() {
        if shouldShowAlert, let title = itemTitle {
            // 저장된 itemTitle을 사용하여 didTapItem 호출
            didTapItem(withTitle: title)
        }
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
    
    // MARK: - 아이템 삭제 연동
    private func deleteItem(withTitle title: String) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("오류: 액세스 토큰이 없습니다.")
            return
        }
        
        // 요청 본문이 필요 없는 경우 postRequestWithoutParameters를 호출
        APIClient.postRequestWithoutParameters(endpoint: "/api/item/deselect", token: token) { (result: Result<DeleteResponse, AFError>) in
            switch result {
            case .success(let deleteResponse):
                if deleteResponse.isSuccess {
                    self.showAlert(title: "성공", message: deleteResponse.result ?? "아이템이 성공적으로 삭제되었습니다.")
                    self.fetchCharacterInfo()
                } else {
                    self.showAlert(title: "실패", message: deleteResponse.message)
                }
            case .failure(let error):
                print("오류: \(error.localizedDescription)")
                self.showAlert(title: "오류", message: "네트워크 오류가 발생했습니다.")
            }
        }
    }


    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
            self.deleteItem(withTitle: title)
        }
        confirm.setValue(UIColor(named: "EmphasizeError"), forKey: "titleTextColor")
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: .itemPurchased, object: nil)
        NotificationCenter.default.removeObserver(self, name: .itemSelected, object: nil)
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

