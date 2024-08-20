//
//  RoutineTableViewController.swift
//  FocusUp
//
//  Created by 김민지 on 8/19/24.
//

import UIKit
import Alamofire

class RoutineTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var routineTableView: UITableView!
    @IBOutlet weak var routineListBar: UINavigationBar!
    
    // 서버에서 받아온 루틴 데이터 저장하는 배열
    var routineData: [(String, [Int], String, String, Int64, String)] = []
    private var noDataLabel: UILabel!                                           // 데이터 없을 떄 문구 추가
    private var selectedIndexPath: IndexPath? = nil
    private var selectedButton: UIButton?                                       // 현재 선택된 버튼을 추적
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNoDataLabel()
        setupNavigationBar()
        setupNoDataLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRoutineData()
    }

    // 네비게이션 바 설정
    private func setupNavigationBar() {
        let navigationItem = UINavigationItem(title: "목표 루틴 리스트 조회")
        
        // 왼쪽에 취소 버튼
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain , target: self, action: #selector(cancelButtonTapped))
        cancelButton.tintColor = UIColor.gray
        navigationItem.leftBarButtonItem = cancelButton
        
        // 오른쪽에 시작 버튼
        if noDataLabel.isHidden {
            let startButton = UIBarButtonItem(title: "시작", style: .plain, target: self, action: #selector(startButtonTapped))
            navigationItem.rightBarButtonItem = startButton
        } else {
            navigationItem.rightBarButtonItem = nil // 루틴이 없으면 오른쪽 버튼 제거
        }
        routineListBar.items = [navigationItem]
    }
    
    // 네비게이션 - 취소 버튼 동작
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)        // 현재 뷰 컨트롤 닫기
    }
    
    // 네비게이션 - 시작 버튼 동작
    @objc private func startButtonTapped() {
        guard let selectedIndexPath = selectedIndexPath else {
            // 루틴을 선택하지 않은 경우 경고 메시지 표시
            let alert = UIAlertController(title: nil, message: "루틴을 선택해주세요!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let selectedRoutine = routineData[selectedIndexPath.row]
        
        // 서버로 선택한 루틴의 ID 전송
        sendRoutineIDToServer(routineID: selectedRoutine.4)
    }
    
    // 테이블 뷰 설정
    private func setupTableView() {
        routineTableView.delegate = self
        routineTableView.dataSource = self
        routineTableView.reloadData()
        
        // Register the CustomRoutineTableViewCell class
        routineTableView.register(CustomRoutineTableViewCell.self, forCellReuseIdentifier: "RoutineCell")
        
        // Adjust separator inset and layout margins
        routineTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        routineTableView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    // 데이터가 없을 때 문구 설정
    private func setupNoDataLabel() {
        noDataLabel = UILabel()             // UILabel 초기화
        noDataLabel.text = "마이페이지에 들어가서 목표 루틴을 추가해주세요"
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.frame = view.bounds
        noDataLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noDataLabel.numberOfLines = 0
        view.addSubview(noDataLabel)
        noDataLabel.isHidden = true         // 처음에는 숨김
     }

    
    // 루틴 데이터를 서버에서 가져옴
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
                    
                    // 데이터가 없으면 문구 표시

                    if self.routineData.isEmpty {
                        self.noDataLabel.isHidden = false

                    } else {
                        self.noDataLabel.isHidden = true

                    }
                    self.routineTableView.reloadData()      // 테이블뷰 업데이트
                    self.setupNavigationBar()               // 네비게이션바 업데이트
                }
            case .failure(let error):
                print("Error fetching routine data: \(error)")
            }
        }
        routineTableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as? CustomRoutineTableViewCell else {
            return UITableViewCell()
        }
        
        let isSelected = indexPath == selectedIndexPath
        cell.configure(isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        tableView.reloadData()
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
        APIClient.postRequest(endpoint: endpoint, parameters: parameters, token: token) { (result: Result<HomeResponse, AFError>) in
            switch result {
            case .success(let homeResponse):
                if homeResponse.isSuccess {
                    print("API 호출 성공: \(homeResponse)")
                    // 성공적으로 호출된 후 필요한 작업 수행
                } else {
                    print("API 호출 실패: \(homeResponse.message)")
                }
            case .failure(let error):
                print("API 호출 실패: \(error.localizedDescription)")
            }
        }
    }
}
     

