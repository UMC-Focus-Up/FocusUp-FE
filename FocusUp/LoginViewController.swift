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
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error {
                    print("Error.")
                    print(error)
                } else if let oauthToken = oauthToken {
                    print("loginWithKakaoTalk() success.")
                    self?.loginToServer(socialType: "KAKAO", idToken: oauthToken.accessToken)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                if let error = error {
                    print(error)
                } else if let oauthToken = oauthToken {
                    print("loginWithKakaoAccount() success.")
                    self?.loginToServer(socialType: "KAKAO", idToken: oauthToken.accessToken)
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
    
    // 서버로 로그인 요청을 보내는 함수
    func loginToServer(socialType: String, idToken: String) {
        let url = "http://15.165.198.110:80/api/user/auth/login"
        let parameters: [String: Any] = [
            "socialType": socialType,
            "id": idToken
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: LoginResponse.self) { [weak self] response in
            switch response.result {
            case .success(let loginResponse):
                if loginResponse.isSuccess {
                    print("Server login success. Access Token: \(loginResponse.result.accessToken)")
                    // 토큰을 저장 (예: UserDefaults에 저장)
                    UserDefaults.standard.set(socialType, forKey: "loginSocialType")
                    UserDefaults.standard.set(loginResponse.result.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(loginResponse.result.refreshToken, forKey: "refreshToken")
                    self?.navigateToMainScreen()
                } else if loginResponse.message == "Token expired" { // 만료된 토큰의 경우 (예시)
                    self?.refreshAccessToken { success in
                        if success {
                            self?.loginToServer(socialType: socialType, idToken: idToken)
                        } else {
                            print("Failed to refresh token and re-login.")
                        }
                    }
                } else {
                    print("Server login failed: \(loginResponse.message)")
                }
            case .failure(let error):
                print("Server login error: \(error.localizedDescription)")
            }
        }
    }
    
    // AccessToken 재발급 함수
    func refreshAccessToken(completion: @escaping (Bool)->Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            print("No refresh token found.")
            completion(false)
            return
        }
        
        let url = "http://15.165.198.110:80/api/user/auth/reissue"
        let parameters: [String: Any] = [
            "refreshToken": refreshToken
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let loginResponse):
                if loginResponse.isSuccess {
                    print("Access token refreshed successfully.")
                    UserDefaults.standard.set(loginResponse.result.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(loginResponse.result.refreshToken, forKey: "refreshToken")
                    completion(true)
                } else {
                    print("Failed to refresh access token: \(loginResponse.message)")
                    completion(false)
                }
            case .failure(let error):
                print("Error refreshing access token: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // 메인 화면으로 전환하는 함수
    func navigateToMainScreen() {
        guard let mainVC = self.storyboard?.instantiateViewController(identifier: "CustomTabBarController") as? CustomTabBarController else { return }
        mainVC.modalTransitionStyle = .coverVertical
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
}

// MARK: - extension
extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        if let accessToken = naverLoginInstance?.accessToken {
            print("Naver login Success. Access Token: \(accessToken)")
            loginToServer(socialType: "NAVER", idToken: accessToken)
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        if let accessToken = naverLoginInstance?.accessToken {
            print("Naver token refreshed. Access Token: \(accessToken)")
        }
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Naver logout Success.")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) {
        print("Naver login error: \(error.localizedDescription)")
        self.naverLoginInstance?.requestDeleteToken()
    }
}

// 서버의 로그인 응답 구조체
struct LoginResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: LoginResult
}

struct LoginResult: Decodable {
    let accessToken: String
    let refreshToken: String
}
