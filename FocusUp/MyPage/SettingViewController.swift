//
//  SettingViewController.swift
//  FocusUp
//
//  Created by 성호은 on 7/24/24.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

class SettingViewController: UIViewController {
    // MARK: - property
    @IBOutlet weak var levelManageButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naverLoginInstance?.delegate = self

        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.title = "설정"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let customFont = UIFont(name: "Pretendard-Regular", size: 18) {
            let textAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: customFont
            ]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        } else {
            print("커스텀 폰트를 로드할 수 없습니다.")
        }
        
        let backButton = UIImage(named: "arrow_left")
        let leftBarButton: UIBarButtonItem = UIBarButtonItem(image: backButton, style: .plain, target: self, action: #selector(completeButtonDidTap))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    // MARK: - action
    @IBAction func didTapLogOutBtn(_ sender: Any) {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: .alert)
        
        let Cancel = UIAlertAction(title: "취소", style: .default, handler: { (action) -> Void in})
        alert.addAction(Cancel)
        Cancel.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let logout = UIAlertAction(title: "로그아웃", style: .default, handler: { (action) in
            // 로그인 상태 확인
            let loginSocialType = UserDefaults.standard.string(forKey: "loginSocialType")

            // 네이버 로그아웃 처리
            if loginSocialType == "NAVER" {
                self.naverLoginInstance?.requestDeleteToken()
            }
            
            // 카카오 로그아웃 처리
            if loginSocialType == "KAKAO" {
                UserApi.shared.logout {(error) in
                    if let error = error {
                        print(error)
                    }
                    
                    print("Kakao logout Success.")
                    self.clearUserDataAndGoToLogin()
                }
            }
        })
        
        alert.addAction(logout)
        logout.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.preferredAction = logout
        
        present(alert, animated: true, completion: nil)
    }
    
    func clearUserDataAndGoToLogin() {
        // UserDefaults에서 토큰 제거
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        
        // 로그인 화면으로 돌아가기
        if let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController {
            loginVC.modalTransitionStyle = .coverVertical
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapLevelManageButton(_ sender: Any) {
        let levelControlVC = LevelControlViewController()
        levelControlVC.modalPresentationStyle = .pageSheet
        
        if let sheet = levelControlVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { context in
                return 547 // 높이 설정
            }
            sheet.detents = [customDetent] // 사용자 지정 높이만 사용
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 8
        }
        
        present(levelControlVC, animated: true, completion: nil)
    }
    
    @objc func completeButtonDidTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - extension
extension SettingViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Naver login Success.")
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        naverLoginInstance?.accessToken
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Naver logout Success.")
        self.clearUserDataAndGoToLogin()
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) {
        print("error = \(error.localizedDescription)")
        self.naverLoginInstance?.requestDeleteToken()
    }
    
    
}
