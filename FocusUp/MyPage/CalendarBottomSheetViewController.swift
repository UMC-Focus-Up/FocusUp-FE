import UIKit

class CalendarBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedDate: Date?
    private var selectedIndexPath: IndexPath?
    private var selectedRoutine: (String, [Int], String, String, Int64, String)? // 선택된 루틴 정보를 저장할 변수

    var timeElapsed: TimeInterval? // 전달할 timeElapsed 값을 저장하는 프로퍼티
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 15)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor(named: "BlueGray4")?.cgColor
        bottomBorder.frame = CGRect(x: 0, y: 56, width: UIScreen.main.bounds.width, height: 1)
        view.layer.addSublayer(bottomBorder)
        
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.setTitleColor(UIColor(named: "BlueGray7"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.setTitleColor(UIColor(named: "Primary4"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var routinesByDay: [(String, [Int], String, String, Int64, String)] = [] // 차례대로 루틴이름, 반복주기, 시작시간, 목표시간, 루틴 ID, 시작 날짜
    private var dayOfWeek: Int = 0
    var routinesForDay: [(String, [Int], String, String, Int64, String)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        view.backgroundColor = .white
        setupUI()
        setupTableView()
        
        if let date = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            titleLabel.text = dateFormatter.string(from: date)
            
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            dayOfWeek = weekday - 1 // Adjust to 0 (Sunday) to 6 (Saturday)
            
            routinesByDay = getRoutines(for: dayOfWeek)
            tableView.reloadData()
            
            if routinesByDay.isEmpty {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        view.addSubview(contentView)
        headerView.addSubview(cancelButton)
        headerView.addSubview(nextButton)
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 57),
            
            cancelButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            nextButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RoutineTableViewCell.self, forCellReuseIdentifier: "RoutineCell")
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapNextButton() {
        if let selectedRoutine = selectedRoutine, let selectedDate = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일" // 원하는 날짜 포맷으로 설정
            let formattedDate = dateFormatter.string(from: selectedDate)

            // 선택된 루틴의 ID를 사용하여 execTime과 achieveRate를 가져오기
            var execTime = "00:00"  // 기본 값
            var achieveRate = 0.0   // 기본 값

            // MyPageViewController에서 불러온 서버 데이터를 사용
            let storedRoutines = MyPageViewController.sharedRoutines

            // 선택된 루틴 ID에 해당하는 execTime과 achieveRate를 찾기
            if let routineDetail = storedRoutines.first(where: { $0.id == selectedRoutine.4 }) {
                execTime = routineDetail.execTime // 해당 루틴의 execTime을 가져옴
                achieveRate = routineDetail.achieveRate // 해당 루틴의 achieveRate를 가져옴
            }

            // 목표 시간을 시간 단위로 변환
            let targetTimeInHours = convertTimeStringToHours(selectedRoutine.3)
            let execTimeInHours = convertTimeStringToHours(execTime)

            // 루틴 정보 출력
            let routineInfo = """
            목표 시간: \(targetTimeInHours)
            실제 루틴 시간: \(execTimeInHours)
            달성률: \(achieveRate)%
            """

            print("routine id: \(selectedRoutine.4)")
            print(routineInfo)

            // 1. CalendarBottomSheetViewController를 먼저 사라지게 합니다.
            dismiss(animated: true) {
                // 현재의 UIWindowScene을 가져옵니다.
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    // 현재 윈도우를 가져옵니다.
                    if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        // 현재 윈도우의 루트 뷰 컨트롤러를 가져옵니다.
                        if let rootViewController = window.rootViewController {
                            // 현재 뷰 컨트롤러가 표시 가능한 상태인지 확인
                            var topViewController = rootViewController
                            while let presentedViewController = topViewController.presentedViewController {
                                topViewController = presentedViewController
                            }
                            
                            let alertController = UIAlertController(title: formattedDate, message: routineInfo, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "확인", style: .cancel)
                            alertController.addAction(okAction)
                            okAction.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
                            
                            // 최상위 뷰 컨트롤러에서 UIAlertController를 표시합니다.
                            topViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            print("선택된 루틴이 없습니다.")
        }
    }

    // Helper function to convert "HH:MM" string to hours as a string value
    private func convertTimeStringToHours(_ timeString: String) -> String {
        let timeComponents = timeString.split(separator: ":")
        let hours = Int(timeComponents[0]) ?? 0
        return "\(hours)시간"
    }

    private func getRoutines(for dayOfWeek: Int) -> [(String, [Int], String, String, Int64, String)] {
        var routinesForDay: [(String, [Int], String, String, Int64, String)] = []
        
        for routine in RoutineDataModel.shared.routineData {
            if routine.1.contains(dayOfWeek) {
                routinesForDay.append(routine)
            }
        }
        
        return routinesForDay
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routinesByDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as! RoutineTableViewCell
        
        cell.selectionStyle = .none
        
        let routine = routinesByDay[indexPath.row]
        let isSelected = selectedIndexPath == indexPath
        cell.configure(with: routine.0, isSelected: isSelected, isFirstCell: indexPath.row == 0)
        
        // 버튼에 액션 추가
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(didTapRoutineButton(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc private func didTapRoutineButton(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        // 현재 선택된 셀의 상태를 토글합니다
        let isSelected = selectedIndexPath == indexPath
        if let cell = tableView.cellForRow(at: indexPath) as? RoutineTableViewCell {
            cell.configure(with: routinesByDay[indexPath.row].0, isSelected: !isSelected, isFirstCell: indexPath.row == 0)
        }
        
        // 선택된 인덱스 패스를 업데이트합니다
        if isSelected {
            selectedIndexPath = nil
            selectedRoutine = nil
        } else {
            selectedIndexPath = indexPath
            selectedRoutine = routinesByDay[indexPath.row]
        }
        
        // 선택된 루틴의 ID를 출력합니다
        if let selectedRoutine = selectedRoutine {
            print("선택된 루틴 ID: \(selectedRoutine.4)") // 루틴 ID 출력
        }
    }
}

class RoutineTableViewCell: UITableViewCell {
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        button.tintColor = UIColor.black
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1).cgColor
        return button
    }()
    
    private let squareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1).cgColor
        return button
    }()
    
    let checkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "check"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true // Initially hidden
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.addSubview(squareButton)
        squareButton.addSubview(checkImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, isSelected: Bool, isFirstCell: Bool) {
        button.setTitle(title, for: .normal)
        checkImageView.isHidden = !isSelected
        let borderColor: UIColor = isSelected ? UIColor(named: "Primary4") ?? .blue : UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1)
        button.layer.borderColor = borderColor.cgColor
        squareButton.layer.borderColor = borderColor.cgColor
        squareButton.backgroundColor = isSelected ? (UIColor(named: "Primary4")?.withAlphaComponent(0.1) ?? UIColor.blue.withAlphaComponent(0.1)) : .clear
        
        let topConstraint = isFirstCell ? button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30) : button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6)
        
        NSLayoutConstraint.activate([
            // Button constraints
            button.widthAnchor.constraint(equalToConstant: 342),
            button.heightAnchor.constraint(equalToConstant: 51),
            topConstraint,
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6), // 다른 셀은 6pt 패딩
            
            // Square button constraints
            squareButton.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            squareButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            squareButton.widthAnchor.constraint(equalToConstant: 25),
            squareButton.heightAnchor.constraint(equalToConstant: 25),
            
            // Button title constraints
            button.titleLabel!.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 16),
            button.titleLabel!.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            // Check image view constraints
            checkImageView.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension Notification.Name {
    static let didPassTimeElapsed = Notification.Name("didPassTimeElapsed")
}
