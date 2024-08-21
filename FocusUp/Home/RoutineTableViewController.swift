//
//  RoutineTableViewController.swift
//  FocusUp
//
//  Created by 김민지 on 8/19/24.
//

import UIKit
import Alamofire

protocol RoutineTableViewControllerDelegate: AnyObject {
    func didSelectRoutine(_ routine: PostHomeResult)
}

class RoutineTableViewController: UIViewController {
    weak var delegate: RoutineTableViewControllerDelegate?

    var routineData: [(String, [Int], String, String, Int64, String)] = []
    private var selectedButton: UIButton?                           // 현재 선택된 버튼을 추적
    private var noDataLabel: UILabel!                               // 데이터 없을 떄 문구 추가

    
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

        let startButton = UIButton(type: .system)
        startButton.setTitle("시작", for: .normal)
        startButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        startButton.setTitleColor(UIColor(named: "Primary4"), for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)

        let routineLabel = UILabel()
        routineLabel.text = "목표 루틴 리스트 조회"
        routineLabel.font = UIFont(name: "Pretendard-Regular", size: 15)
        routineLabel.textColor = UIColor.black
        routineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(routineLabel)

        NSLayoutConstraint.activate([
            // 취소 버튼
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 시작 버튼
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 루틴 레이블
            routineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            routineLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 뷰 높이 설정
            view.heightAnchor.constraint(equalToConstant: 57)
        ])

        return view
    }()

    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    // MARK: 로딩 스피너 설정
    // API 요청이 완료될 때까지 비동기적으로 UI 업데이트할 수 있도록 도와줌
    private var loadingSpinner: UIActivityIndicatorView!

    private func setupLoadingSpinner() {
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.hidesWhenStopped = true
        view.addSubview(loadingSpinner)
        
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupNoDataLabel()
        configureHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRoutineButtons()  // 버튼 생성 함수 호출
        fetchRoutineData()
        setupLoadingSpinner() // 로딩 스피너 설정

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
    
    // 데이터가 없을 때 문구 설정
    private func setupNoDataLabel() {
        noDataLabel = UILabel()
        noDataLabel.text = "마이페이지에 들어가서 목표 루틴을 추가해주세요"
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.numberOfLines = 0
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        noDataLabel.isHidden = true
    }

    
    
    private func setupRoutineButtons() {
        // 기존 버튼 제거
        contentView.subviews.forEach { view in
            if view is UIButton {
                view.removeFromSuperview()
            }
        }
        
        // 버튼 생성
        for (index, routine) in routineData.enumerated() {
            let button = createButton(withTitle: routine.0, type: "\(routine.4)")
            button.tag = Int(routine.4) // 루틴 ID를 버튼의 태그에 저장
            contentView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 342),
                button.heightAnchor.constraint(equalToConstant: 51),
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CGFloat(30 + (index * 61))),
                button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ])
        }
    }

    
    private func configureHeaderView() {
        if let listLabel = headerView.subviews.compactMap({ $0 as? UILabel }).first {
            let listText = "목표 루틴 리스트 조회"
            let attributedString = NSMutableAttributedString(string: listText)
            
            let font = UIFont(name: "Pretendard-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
            let textColor = UIColor.black
            let underlineStyle = NSUnderlineStyle.single.rawValue
            
            attributedString.addAttributes([
                .font: font,
                .foregroundColor: textColor,
                .baselineOffset: 3.8
            ], range: NSRange(location: 0, length: listText.count))
            
            listLabel.attributedText = attributedString
        }
        
        // 취소 버튼의 액션 추가
        if let cancelButton = headerView.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == "취소" }) {
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }
        
        // 시작 버튼의 액션 추가
        if let completeButton = headerView.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == "시작" }) {
            completeButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
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
        if let previousSelectedButton = selectedButton {
            resetButtonSelection(previousSelectedButton)
        }
        
        updateButtonSelection(sender)
        selectedButton = sender
        
        // 선택된 버튼의 태그를 통해 루틴 ID 가져오기
        let routineID = Int64(sender.tag)
        print("Selected Routine ID: \(routineID)")
    }
    
    private func resetButtonSelection(_ button: UIButton) {
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
    
    @objc private func startButtonTapped() {
        guard let buttonType = selectedButton?.accessibilityIdentifier else {
            // 루틴을 선택하지 않은 경우 경고 메시지 표시
            let alert = UIAlertController(title: nil, message: "루틴을 선택해주세요!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 선택한 루틴의 ID를 추출
        guard let routineId = Int(buttonType) else {
            let alert = UIAlertController(title: nil, message: "루틴 ID를 찾을 수 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        // 서버로 선택한 루틴의 ID 전송
        let endpoint = "/api/user/home/routine"
        let parameters = ["routineId": routineId]  // 루틴 ID를 파라미터로 설정
        let token = UserDefaults.standard.string(forKey: "accessToken")  // 저장된 액세스 토큰 가져오기
           
        APIClient.postRequest(endpoint: endpoint, parameters: parameters, token: token) { (result: Result<PostHomeResponse, AFError>) in
            switch result {
            case .success(let response):
                if response.isSuccess, let routineResult = response.result {
                    print("루틴 전송 성공: \(response.result?.routineName ?? "알 수 없음")")
                    print("\(String(describing: response.result))")
                    
                    // delegate 메서드 호출
                    self.delegate?.didSelectRoutine(routineResult)
                    print("delegate 호출")
                    self.dismiss(animated: true, completion: nil)

                } else {
                    print("루틴 전송 실패: \(response.message)")
                    let alert = UIAlertController(title: nil, message: response.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                print("루틴 전송 중 오류 발생: \(error.localizedDescription)")
                let alert = UIAlertController(title: nil, message: "서버와의 통신 중 오류가 발생했습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

// MARK: - API 연동
    
    // 루틴 데이터 리스트 연동
    func fetchRoutineData() {
          let url = "http://15.165.198.110:80/api/routine/user/all"

          // 헤더 설정
          var accessToken: String = ""
          if let token = UserDefaults.standard.string(forKey: "accessToken") {
                  accessToken = token
              } else {
                  print("accessToken이 없습니다.")
              }
          
          let headers: HTTPHeaders = [
              "Authorization": "Bearer \(accessToken)",
              "Content-Type": "application/json"
          ]
          
          AF.request(url, method: .get, headers: headers).responseJSON { response in
              switch response.result {
              case .success(let value):
                  if let json = value as? [String: Any],
                     let result = json["result"] as? [String: Any],
                     let routines = result["routines"] as? [[String: Any]] {
                      
                      // 데이터 정렬: ID가 큰 루틴이 먼저 오도록 정렬
                      let sortedRoutines = routines.sorted {
                          guard let id1 = $0["id"] as? Int64,
                                let id2 = $1["id"] as? Int64 else { return false }
                          return id1 > id2
                      }

                      self.routineData = sortedRoutines.compactMap { routine in
                          if let id = routine["id"] as? Int64,
                             let name = routine["name"] as? String {
                              return (name, [], "", "", id, "")
                          }
                          return nil
                      }
                      self.setupRoutineButtons()  // 버튼 생성 함수 호출
                      
                      // 데이터가 없으면 문구 표시
                      if self.routineData.isEmpty {
                          self.noDataLabel.isHidden = false

                      } else {
                          self.noDataLabel.isHidden = true

                      }
                  }
              case .failure(let error):
                  print("Error fetching routine data: \(error)")
              }
          }
      }

    // 서버로 루틴 ID 전송
    private func sendRoutineIDToServer(routineID: Int64) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }

        let endpoint = "/api/user/home"
        let parameters = ["routineID": routineID] // 요청 본문에 포함될 데이터

        // API 요청
        APIClient.postRequest(endpoint: endpoint, parameters: parameters, token: token) { (result: Result<PostHomeResponse, AFError>) in
            switch result {
            case .success(let homeResponse):
                 if homeResponse.isSuccess {
                     if let routineResult = homeResponse.result {
                         print("Routine ID: \(routineResult.routineId)")
                         print("Routine Name: \(routineResult.routineName)")
                         print("Exec Time: \(routineResult.execTime)")
                         print("Goal Time: \(routineResult.goalTime)")
                         // 성공적으로 호출된 후 필요한 작업 수행
                     } else {
                         print("Error: Result is nil")
                     }
                 } else {
                     print("API 호출 실패: \(homeResponse.message)")
                 }
             case .failure(let error):
                 print("API 호출 실패: \(error.localizedDescription)")
             }
        }
    }
}

