import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import NaverThirdPartyLogin
import Alamofire

class LoginViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var naverButton: UIButton!
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setFont()
        
        naverLoginInstance?.delegate = self
    }
    
    // MARK: - Action
    @IBAction func kakaoButtonTapped(_ sender: Any) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("Error.")
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    self.handleKakaoLogin(oauthToken: oauthToken)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("loginWithKakaoAccount() success.")
                    self.handleKakaoLogin(oauthToken: oauthToken)
                }
            }
        }
    }
    
    @IBAction func naverButtonTapped(_ sender: Any) {
        naverLoginInstance?.requestThirdPartyLogin()
    }
    
    // MARK: - Function
    func setAttribute() {
        kakaoButton.layer.cornerRadius = 26
        naverButton.layer.cornerRadius = 26
    }
    
    func setFont() {
        kakaoButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 15)
        kakaoButton.titleLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        naverButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 15)
    }
    
    private func handleKakaoLogin(oauthToken: OAuthToken?) {
        UserApi.shared.me { [weak self] (user, error) in
            if let error = error {
                print(error)
                return
            }
            guard let user = user else { return }
            let id = String(user.id ?? 0)
            let socialType = "KAKAO"
            self?.sendSocialInfo(socialType: socialType, id: id)
            
            guard let mainVC = self?.storyboard?.instantiateViewController(identifier: "CustomTabBarController") as? CustomTabBarController else { return }
            mainVC.modalTransitionStyle = .coverVertical
            mainVC.modalPresentationStyle = .fullScreen
            self?.present(mainVC, animated: true, completion: nil)
        }
    }
    
    private func sendSocialInfo(socialType: String, id: String) {
        let parameters: [String: Any] = [
            "socialType": socialType,
            "id": id
        ]
        AF.request("http://15.165.198.110:80/api/user/auth/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            switch response.result {
            case .success(let value):
                // HTTP 상태 코드 확인
                if let httpResponse = response.response {
                    print("HTTP 상태 코드: \(httpResponse.statusCode)")
                }
                // 응답 데이터 확인
                if let json = value as? [String: Any] {
                    print("응답 데이터: \(json)")
                    // 성공적인 응답 처리
                    if let success = json["isSuccess"] as? Bool, success {
                        print("백엔드 연결 성공")
                    } else {
                        print("백엔드 연결 실패")
                    }
                }
            case .failure(let error):
                print("연결 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - extension
extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let mainVC = self.storyboard?.instantiateViewController(identifier: "CustomTabBarController") as? CustomTabBarController else { return }
        mainVC.modalTransitionStyle = .coverVertical
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
        
        print("Naver login Success.")
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        naverLoginInstance?.accessToken
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Naver logout Success.")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) {
        print("error = \(error.localizedDescription)")
        self.naverLoginInstance?.requestDeleteToken()
    }
    
}
