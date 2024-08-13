//
//  LevelControlViewController.swift
//  FocusUp
//
//  Created by 성호은 on 7/31/24.
//

import UIKit

class LevelControlViewController: UIViewController {
    
    // MARK: - Properties
    static var sharedData = LevelControlSharedData()
        
    private var userLevel: Int {
        get {
            return LevelControlViewController.sharedData.userLevel
        }
        set {
            LevelControlViewController.sharedData.userLevel = newValue
        }
    }
    
    private var selectedButton: UIButton? // 현재 선택된 버튼을 추적
    
    // MARK: - Views
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // 하단 보더 추가
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor(named: "BlueGray4")?.cgColor
        bottomBorder.frame = CGRect(x: 0, y: 56, width: UIScreen.main.bounds.width, height: 1)
        view.layer.addSublayer(bottomBorder)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        cancelButton.setTitleColor(UIColor(named: "BlueGray7"), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        let completeButton = UIButton(type: .system)
        completeButton.setTitle("완료", for: .normal)
        completeButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        completeButton.setTitleColor(UIColor(named: "Primary4"), for: .normal)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completeButton)
        
        let levelLabel = UILabel()
        levelLabel.font = UIFont(name: "Pretendard-Regular", size: 15)
        levelLabel.textColor = UIColor.black
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)
        
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            levelLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        setupLevelButtons()
        configureHeaderView()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 57),
            
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLevelButtons() {
        let myLevelButton = createButton(withTitle: "My Level", type: "myLevelButton")
        contentView.addSubview(myLevelButton)
        
        NSLayoutConstraint.activate([
            myLevelButton.widthAnchor.constraint(equalToConstant: 342),
            myLevelButton.heightAnchor.constraint(equalToConstant: 51),
            myLevelButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            myLevelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        var previousButton: UIButton = myLevelButton
        
        for level in 1..<userLevel {
            let levelButton = createButton(withTitle: "Level \(level)", type: "levelButton")
            contentView.addSubview(levelButton)
            
            NSLayoutConstraint.activate([
                levelButton.widthAnchor.constraint(equalToConstant: 342),
                levelButton.heightAnchor.constraint(equalToConstant: 51),
                levelButton.topAnchor.constraint(equalTo: previousButton.bottomAnchor, constant: 12),
                levelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ])
            
            previousButton = levelButton
        }
    }
    
    private func configureHeaderView() {
        if let levelLabel = headerView.subviews.compactMap({ $0 as? UILabel }).first {
            let levelText = "My Level : \(userLevel)"
            let attributedString = NSMutableAttributedString(string: levelText)
            
            let font = UIFont(name: "Pretendard-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
            let textColor = UIColor.black
            let underlineStyle = NSUnderlineStyle.single.rawValue
            
            attributedString.addAttributes([
                .font: font,
                .foregroundColor: textColor,
                .underlineStyle: underlineStyle,
                .baselineOffset: 3.8
            ], range: NSRange(location: 0, length: levelText.count))
            
            levelLabel.attributedText = attributedString
        }
        
        // 취소 버튼의 액션 추가
        if let cancelButton = headerView.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == "취소" }) {
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }
        
        // 완료 버튼의 액션 추가
        if let completeButton = headerView.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == "완료" }) {
            completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - Button Creation
    
    private func createButton(withTitle title: String, type: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = type
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // square 이미지를 대체하는 버튼 생성
        let squareButton = UIButton(type: .system)
        squareButton.translatesAutoresizingMaskIntoConstraints = false
        squareButton.backgroundColor = UIColor.clear
        squareButton.layer.cornerRadius = 4
        squareButton.layer.borderWidth = 1
        squareButton.layer.borderColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1).cgColor
        squareButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        squareButton.heightAnchor.constraint(equalToConstant: 25).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(squareButton)
        stackView.addArrangedSubview(titleLabel)
        
        button.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "BlueGray3")?.cgColor
        
        // Check 이미지 추가
        let checkImageView = UIImageView(image: UIImage(named: "check"))
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.isHidden = true
        button.addSubview(checkImageView)
        
        NSLayoutConstraint.activate([
            checkImageView.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: UIButton) {
        // 현재 선택된 버튼이 있다면 그 버튼의 선택 상태 해제
        if let previousSelectedButton = selectedButton {
            resetButtonSelection(previousSelectedButton)
        }
        
        // 새로운 버튼 선택 상태 설정
        updateButtonSelection(sender)
        
        // 선택된 버튼 업데이트
        selectedButton = sender
    }
    
    private func resetButtonSelection(_ button: UIButton) {
        // 선택 상태 해제
        if let previousCheckImageView = button.subviews.compactMap({ $0 as? UIImageView }).last {
            previousCheckImageView.isHidden = true
        }
        if let previousSquareButton = button.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.compactMap({ $0 as? UIButton }).first {
            if previousSquareButton.layer.borderColor == UIColor(named: "Primary4")?.cgColor {
                previousSquareButton.layer.borderColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1).cgColor
                previousSquareButton.backgroundColor = UIColor.clear
            }
        }
        if button.layer.borderColor == UIColor(named: "Primary4")?.cgColor {
            button.layer.borderColor = UIColor(named: "BlueGray3")?.cgColor
        }
    }
    
    private func updateButtonSelection(_ button: UIButton) {
        if let checkImageView = button.subviews.compactMap({ $0 as? UIImageView }).last {
            checkImageView.isHidden = !checkImageView.isHidden
        }
        if let squareButton = button.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.compactMap({ $0 as? UIButton }).first {
            if squareButton.layer.borderColor == UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1).cgColor {
                squareButton.layer.borderColor = UIColor(named: "Primary4")?.cgColor
                squareButton.backgroundColor = UIColor(named: "Primary4")?.withAlphaComponent(0.1)
            } else {
                squareButton.layer.borderColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1).cgColor
                squareButton.backgroundColor = .clear
            }
        }
        if button.layer.borderColor == UIColor(named: "BlueGray3")?.cgColor {
            button.layer.borderColor = UIColor(named: "Primary4")?.cgColor
        } else {
            button.layer.borderColor = UIColor(named: "BlueGray3")?.cgColor
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func completeButtonTapped() {
        let buttonType = selectedButton?.accessibilityIdentifier ?? "none"
        
        if buttonType == "myLevelButton" {
            NotificationCenter.default.post(name: .didCancelLevelSelection, object: nil)
        } else {
            NotificationCenter.default.post(name: .didCompleteLevelSelection, object: nil, userInfo: ["buttonType": buttonType])
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let didCompleteLevelSelection = Notification.Name("didCompleteLevelSelection")
    static let didCancelLevelSelection = Notification.Name("didCancelLevelSelection")
}

// 공유 데이터 모델 정의
class LevelControlSharedData {
    var userLevel: Int = 1
}



