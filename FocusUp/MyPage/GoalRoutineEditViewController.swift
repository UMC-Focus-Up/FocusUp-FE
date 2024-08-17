import UIKit
import Alamofire

class GoalRoutineEditViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var goalRoutineLabel: UILabel!
    @IBOutlet weak var goalRoutineView: UIView!
    @IBOutlet weak var goalRoutineTextLabel: UILabel!
    @IBOutlet weak var repeatPeriodLabel: UILabel!
    @IBOutlet weak var weekStackButton: UIStackView!
    @IBOutlet weak var startTimeTitleLabel: UILabel!
    @IBOutlet weak var startTimeView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var goalTimeTitleLabel: UILabel!
    @IBOutlet weak var goalTimeView: UIView!
    @IBOutlet weak var goalTimeLabel: UILabel!
    @IBOutlet weak var goalTimeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var routineData: (String, [Int], String, String, Int64)?
    weak var delegate: RoutineDeleteDelegate?
    var routineIndex: Int?

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setFont()
        setWeekStackViewButton()
        
        if let routineData = routineData {
            let userRoutineId = routineData.4
            fetchRoutineDetails(userRoutineId: userRoutineId)
        }
    }
    
    
    // MARK: - Function
    func setAttribute() {
        customTitleView()
        
        goalRoutineView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        goalRoutineView.layer.borderWidth = 1
        goalRoutineView.layer.cornerRadius = 8
        
        setTimeButtonAttribute(for: startTimeView)
        setTimeButtonAttribute(for: goalTimeView)
        
        deleteButton.layer.cornerRadius = 28
    }
    
    func setTimeButtonAttribute(for view: UIView) {
        view.layer.borderColor = UIColor.blueGray3.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
    }
    
    func setFont() {
        goalRoutineLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        goalRoutineTextLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
        repeatPeriodLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        startTimeTitleLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        startTimeLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
        goalTimeTitleLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        goalTimeLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
        deleteButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 커스텀 폰트 설정
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
        let leftBarButton: UIBarButtonItem = UIBarButtonItem(image: backButton, style: .plain, target: self, action: #selector(backButtonDidTap))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func customTitleView() {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        let titleView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "목표 루틴 설정"
        titleLabel.font = UIFont(name: "Pretendard-Regular", size: 18)
        titleLabel.textColor = .black
        
        titleView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
        ])
        
        self.navigationItem.titleView = titleView
    }
    
    // MARK: - API
    var accessToken: String = ""
    
    func fetchRoutineDetails(userRoutineId: Int64) {
        let url = "http://15.165.198.110:80/api/routine/user/\(userRoutineId)"
        print("Request URL: \(url)")

        // 헤더 설정
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
                accessToken = token
            } else {
                print("accessToken이 없습니다.")
            }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let isSuccess = json["isSuccess"] as? Bool, isSuccess,
                   let result = json["result"] as? [String: Any] {
                    print("응답: \(json)")
                    self.updateUI(with: result)
                } else {
                    print("API 호출에 실패했습니다.")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUI(with result: [String: Any]) {
        print("result: \(result)")
        if let routineName = result["routineName"] as? String,
           let repeatCycleDay = result["repeatCycleDay"] as? [String],
           let startTime = result["startTime"] as? String,
           let endTime = result["endTime"] as? String {
            
            self.goalRoutineTextLabel.text = routineName
            self.startTimeLabel.text = convertTo12HourFormat(time: startTime)
            self.goalTimeLabel.text = endTime

            let dayMapping: [String: Int] = [
                "SUNDAY": 0, "MONDAY": 1, "TUESDAY": 2,
                "WEDNESDAY": 3, "THURSDAY": 4, "FRIDAY": 5, "SATURDAY": 6
            ]
            
            let selectedTags = repeatCycleDay.compactMap { dayMapping[$0] }
            for case let button as UIButton in weekStackButton.arrangedSubviews {
                setButton(button, selectedTags: selectedTags)
            }
        } else {
            print("데이터가 예상과 다릅니다.")
        }
    }
    
    // 12시간제로 변환하는 함수
    func convertTo12HourFormat(time: String) -> String {
        let formatter24Hour = DateFormatter()
        formatter24Hour.dateFormat = "HH:mm"
        
        let formatter12Hour = DateFormatter()
        formatter12Hour.dateFormat = "h:mm a"
        
        if let date = formatter24Hour.date(from: time) {
            return formatter12Hour.string(from: date)
        }
        return time  // 변환 실패 시 원래 시간을 반환
    }
    
    func deleteRoutine(userRoutineId: Int64) {
        let url = "http://15.165.198.110:80/api/routine/user/\(userRoutineId)"
        print("Request URL: \(url)")

        // 헤더 설정
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            accessToken = token
        } else {
            print("accessToken이 없습니다.")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(url, method: .delete, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let isSuccess = json["isSuccess"] as? Bool, isSuccess {
                    print("삭제 성공: \(json)")
                    // 삭제 성공 후의 처리
                    if let index = self.routineIndex {
                        self.delegate?.didDeleteRoutine(at: index)
                    }
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("삭제 실패")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Action
    private func setWeekStackViewButton() {
        for case let button as UIButton in weekStackButton.arrangedSubviews {
            setButton(button, selectedTags: routineData?.1 ?? [])
        }
    }
    
    private func setButton(_ button: UIButton, selectedTags: [Int]) {
        button.layer.cornerRadius = 21
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blueGray3.cgColor
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 13)
        
        if selectedTags.contains(button.tag) {
            button.isSelected = true
            button.backgroundColor = UIColor.primary4
            button.layer.borderColor = UIColor.clear.cgColor
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.isSelected = false
            button.backgroundColor = UIColor.white
            button.layer.borderColor = UIColor.blueGray4.cgColor
            button.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    @objc func backButtonDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "목표 루틴 설정을 취소하시겠습니까?", message: "작성 중인 내용은 저장되지 않습니다.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        alert.addAction(cancelAction)
        cancelAction.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirmAction)
        confirmAction.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.preferredAction = confirmAction
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "해당 목표 루틴을 삭제하시겠습니까?", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        alert.addAction(cancelAction)
        cancelAction.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirmAction = UIAlertAction(title: "삭제", style: .default) { _ in
            guard let userRoutineId = self.routineData?.4 else {
                print("루틴 ID가 없습니다.")
                return
            }
            self.deleteRoutine(userRoutineId: userRoutineId)
        }
        alert.addAction(confirmAction)
        confirmAction.setValue(UIColor(named: "EmphasizeError"), forKey: "titleTextColor")
        
        alert.preferredAction = confirmAction
        
        present(alert, animated: true, completion: nil)
    }
        
}
