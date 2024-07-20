//
//  LoginViewController.swift
//  FocusUp
//
//  Created by 김미주 on 17/07/2024.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var findPasswordButton: UIButton!
    @IBOutlet weak var snsLabel: UILabel!
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setFont()
    }
    
    
    // MARK: - Action
    
    
    // MARK: - Function
    func setAttribute() {
        setTextFieldAttribute(for: emailTextField)
        setTextFieldAttribute(for: passwordTextField)
        
        loginButton.layer.borderColor = UIColor.primary4.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 28
    }
    
    func setTextFieldAttribute(for textField: UITextField) {
        textField.layer.borderColor = UIColor.blueGray2.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        textField.leftViewMode = .always
    }
    
    func setFont() {
        emailLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        emailTextField.font = UIFont(name: "Pretendard-Regular", size: 16)
        passwordLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        passwordTextField.font = UIFont(name: "Pretendard-Regular", size: 16)
        loginButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        signupButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 13)
        findPasswordButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 13)
        snsLabel.font = UIFont(name: "Pretendard-Medium", size: 13)
    }

}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.primary4.cgColor
        textField.textColor = UIColor.primary4
        textField.tintColor = UIColor.primary4
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.primary2.cgColor
    }
}
