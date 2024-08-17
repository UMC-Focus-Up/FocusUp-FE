import UIKit

class CalendarBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var selectedDate: Date?
    private var selectedIndexPath: IndexPath?
    private var selectedRoutine: (String, [Int], String, String)? // 선택된 루틴 정보를 저장할 변수

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
    
    private var routinesByDay: [(String, [Int], String, String)] = [] // 차례대로 루틴이름, 반복주기, 시작시간, 목표시간
    private var dayOfWeek: Int = 0
    
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
            
            // 목표 시간을 문자열에서 시간과 분으로 변환
            let goalTimeString = selectedRoutine.3
            let goalTimeComponents = goalTimeString.split(separator: ":")
            
            // 시간과 분을 정수로 변환
            let hours = Int(goalTimeComponents.first ?? "0") ?? 0
            let minutes = Int(goalTimeComponents.last ?? "0") ?? 0
            
            // 목표 시간을 시간 단위로 변환
            let totalHours = hours + (minutes / 60)
            
            // 실제 소요 시간을 시간 단위로 변환
            let timeElapsedInHours = Int(timeElapsed ?? 0) / 3600
            
            // 달성률 계산 (소수점 첫째자리까지 표시)
            let totalGoalHours = Double(totalHours)
            let achievementRate = totalGoalHours > 0 ? min(max((Double(timeElapsedInHours) / totalGoalHours) * 100, 0), 100) : 0
            let formattedAchievementRate = String(format: "%.1f", achievementRate) // 소수점 첫째자리까지
            
            let routineInfo = """
            목표 시간 : \(totalHours)시간
            실제 루틴 시간 : \(timeElapsedInHours)시간
            달성률 : \(formattedAchievementRate)%
            """
            
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


    
    private func getRoutines(for dayOfWeek: Int) -> [(String, [Int], String, String)] {
        var routinesForDay: [(String, [Int], String, String)] = []
        
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
        cell.configure(with: routine.0, isSelected: isSelected)
        
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
            cell.configure(with: routinesByDay[indexPath.row].0, isSelected: !isSelected)
        }
        
        // 선택된 인덱스 패스를 업데이트합니다
        if isSelected {
            selectedIndexPath = nil
            selectedRoutine = nil
        } else {
            selectedIndexPath = indexPath
            selectedRoutine = routinesByDay[indexPath.row]
        }
        
        // 선택된 루틴의 이름을 출력합니다
        if let selectedRoutine = selectedRoutine {
            print("선택된 루틴: \(selectedRoutine.0)")
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
        squareButton.addSubview(checkImageView) // Add checkImageView to squareButton
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 342),
            button.heightAnchor.constraint(equalToConstant: 51),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            squareButton.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            squareButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            squareButton.widthAnchor.constraint(equalToConstant: 25),
            squareButton.heightAnchor.constraint(equalToConstant: 25),
            
            button.titleLabel!.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 16),
            button.titleLabel!.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            checkImageView.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, isSelected: Bool) {
        button.setTitle(title, for: .normal)
        checkImageView.isHidden = !isSelected
        let borderColor: UIColor = isSelected ? UIColor(named: "Primary4") ?? .blue : UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1)
        button.layer.borderColor = borderColor.cgColor
        squareButton.layer.borderColor = borderColor.cgColor
        squareButton.backgroundColor = isSelected ? (UIColor(named: "Primary4")?.withAlphaComponent(0.1) ?? UIColor.blue.withAlphaComponent(0.1)) : .clear
    }
}

extension Notification.Name {
    static let didPassTimeElapsed = Notification.Name("didPassTimeElapsed")
}
