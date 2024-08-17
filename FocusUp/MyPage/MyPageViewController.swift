import UIKit
import FSCalendar

// MARK: - Custom Calendar Header View
class CustomHeaderView: UIView {
    
    let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "calendar_arrow_left"), for: .normal)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "calendar_arrow_right"), for: .normal)
        return button
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 24)
        label.textColor = UIColor(named: "Primary4")
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(previousButton)
        addSubview(nextButton)
        addSubview(monthLabel)
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func updateMonthLabel(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        monthLabel.text = dateFormatter.string(from: date)
    }
}

// MARK: - MyPage ViewController
class MyPageViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var goalRoutineLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var routineTableView: UITableView!
    @IBOutlet weak var levelStateLabel: UILabel!
    @IBOutlet weak var levelNoticeLabel: UILabel!
    @IBOutlet weak var presentLevelLabel: UILabel!
    @IBOutlet weak var levelProgress: UIProgressView!
    @IBOutlet weak var levelLabel: UIStackView!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var calendarView: FSCalendar!
    
    private var calendarHeaderView: CustomHeaderView!
    private var levelDownLabel: UILabel?
    private var modifyNoticeLabel: UILabel?
    
    var routineData: [(String, [Int], String, String)] = []
    
    private var savedTimeElapsed: TimeInterval = 0
    private var uptoNext: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        
        setupUI()
        setupCalendar()
        setupNotifications()
        
        updateLevelLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLevelProgressUpdate), name: .didPassMaxBoosterTime, object: nil)
        
        routineTableView.delegate = self
        routineTableView.dataSource = self
        let listNib = UINib(nibName: "GoalRoutineTableViewCell", bundle: nil)
        routineTableView.register(listNib, forCellReuseIdentifier: "GoalRoutineTableViewCell")
        let addNib = UINib(nibName: "GoalRoutineAddTableViewCell", bundle: nil)
        routineTableView.register(addNib, forCellReuseIdentifier: "GoalRoutineAddTableViewCell")
        routineTableView.separatorStyle = .none
        routineTableView.isScrollEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setWeekdayLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        configureTabBar()
        
        routineData = RoutineDataModel.shared.routineData
        routineTableView.reloadData()
    }
    
    func didDeleteRoutine(at index: Int) {
        RoutineDataModel.shared.deleteRoutine(at: index)
        routineData = RoutineDataModel.shared.routineData
        routineTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        goalRoutineLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        addUnderlineToMoreButton()
        levelStateLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        levelNoticeLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        presentLevelLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        addUnderlineToPresentLevelLabel()
        setLevelLabel()
        calendarLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        calendarView.appearance.weekdayFont = UIFont(name: "Pretendard-Regular", size: 14)
        
        levelProgress.layer.cornerRadius = 5
        levelProgress.clipsToBounds = true
        levelProgress.translatesAutoresizingMaskIntoConstraints = false
        levelProgress.progress = 0.0
        view.addSubview(levelProgress)
        
        if let progressLayer = levelProgress.subviews.last {
            progressLayer.layer.cornerRadius = 5
            progressLayer.clipsToBounds = true
        }
        
        NSLayoutConstraint.activate([
            levelProgress.topAnchor.constraint(equalTo: levelNoticeLabel.bottomAnchor, constant: 19),
            levelProgress.bottomAnchor.constraint(equalTo: levelLabel.topAnchor, constant: -11),
            levelProgress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            levelProgress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            levelProgress.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        updateLevelNoticeLabel()
    }
    
    private func setupCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        setupCalendarHeaderView()
        updateHeaderViewForCurrentMonth()
        
        calendarView.scope = .month
        calendarView.scrollDirection = .horizontal
        calendarView.placeholderType = .none
        
        setupCalendarAppearance()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .didCompleteLevelSelection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCancelLevelSelection), name: .didCancelLevelSelection, object: nil)
    }
    
    private func configureNavigationBar() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.title = "마이페이지"
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemBackground
        navigationBarAppearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    private func configureTabBar() {
        tabBarItem.title = "MyPage"
        if let tabBar = tabBarController?.tabBar {
            tabBar.barTintColor = UIColor.systemBackground
            tabBar.standardAppearance.shadowColor = .clear
            tabBar.scrollEdgeAppearance?.shadowColor = .clear
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
    }
    
    @IBAction func didTapSettingBtn(_ sender: Any) {
        guard let toSettingVC = storyboard?.instantiateViewController(identifier: "SettingViewController") else { return }
        navigationController?.pushViewController(toSettingVC, animated: true)
    }
    
    @IBAction func didTapMoreBtn(_ sender: Any) {
        guard let toGoalRoutineListVC = storyboard?.instantiateViewController(identifier: "GoalRoutineListViewController") else { return }
        navigationController?.pushViewController(toGoalRoutineListVC, animated: true)
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        if let buttonType = notification.userInfo?["buttonType"] as? String, buttonType.contains("levelButton") {
            handleLevelSelectionCompletion()
        }
    }
    
    @objc private func handleLevelSelectionCompletion() {
        levelNoticeLabel?.isHidden = true
        presentLevelLabel?.isHidden = true
        levelProgress?.isHidden = true
        levelLabel?.isHidden = true
        
        let levelDownLabel = UILabel()
        levelDownLabel.text = "현재 레벨 하향 기능을 사용하였습니다."
        levelDownLabel.font = UIFont(name: "Pretendard-Regular", size: 13)
        levelDownLabel.textColor = UIColor(named: "EmphasizeError")
        levelDownLabel.textAlignment = .center

        let modifyNoticeLabel = UILabel()
        modifyNoticeLabel.text = "하향된 레벨을 사용 중에는 레벨업 도달 횟수가 증가하지 않습니다.\n레벨을 복원할 경우 이전에 저장된 도달 횟수부터 다시 증가합니다."
        modifyNoticeLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        modifyNoticeLabel.textColor = UIColor.black
        modifyNoticeLabel.textAlignment = .center
        modifyNoticeLabel.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5

        let attributedString = NSMutableAttributedString(string: modifyNoticeLabel.text ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        modifyNoticeLabel.attributedText = attributedString
        
        view.addSubview(levelDownLabel)
        view.addSubview(modifyNoticeLabel)
        
        levelDownLabel.translatesAutoresizingMaskIntoConstraints = false
        modifyNoticeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            levelDownLabel.leadingAnchor.constraint(equalTo: levelStateLabel.leadingAnchor),
            levelDownLabel.topAnchor.constraint(equalTo: levelStateLabel.bottomAnchor, constant: 19),
            modifyNoticeLabel.leadingAnchor.constraint(equalTo: levelStateLabel.leadingAnchor),
            modifyNoticeLabel.topAnchor.constraint(equalTo: levelDownLabel.bottomAnchor, constant: 10)
        ])
        
        self.levelDownLabel = levelDownLabel
        self.modifyNoticeLabel = modifyNoticeLabel
    }
    
    @objc private func didTapCompleteButton() {
        levelNoticeLabel?.isHidden = false
        presentLevelLabel?.isHidden = false
        levelProgress?.isHidden = false
        levelLabel?.isHidden = false
        
        levelDownLabel?.removeFromSuperview()
        modifyNoticeLabel?.removeFromSuperview()
    }
    
    @objc private func handleCancelLevelSelection() {
        didTapCompleteButton()
    }
    
    @objc private func didTapMyLevelButton() {
        handleLevelSelectionCompletion()
    }
    
    func showEditViewController(forRoutineAt index: Int) {
        let editVC = storyboard?.instantiateViewController(withIdentifier: "GoalRoutineEditViewController") as! GoalRoutineEditViewController
        editVC.delegate = self
        editVC.routineIndex = index
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func addUnderlineToMoreButton() {
        let title = "더보기"
        let font = UIFont(name: "Pretendard-Regular", size: 10)
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .font: font ?? .systemFont(ofSize: 10),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.black,
            .baselineOffset: 3.0
        ])
        moreButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func addUnderlineToPresentLevelLabel() {
        guard let title = presentLevelLabel.text else { return }
        let attributedString = NSMutableAttributedString(string: title)
        let underlineStyle = NSUnderlineStyle.single.rawValue
        attributedString.addAttributes([
            .underlineStyle: underlineStyle,
            .baselineOffset: 3.0
        ], range: NSRange(location: 0, length: title.count))
        presentLevelLabel.attributedText = attributedString
    }
    
    private func setLevelLabel() {
        for case let label as UILabel in levelLabel.arrangedSubviews {
            label.font = UIFont(name: "Pretendard-Regular", size: 12)
        }
    }
    
    private func updateLevelLabel() {
        let userLevel = LevelControlViewController.sharedData.userLevel
        presentLevelLabel.text = "현재 Level \(userLevel)"
    }
    
    
    private func setWeekdayLabels() {
        let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
        for (index, label) in calendarView.calendarWeekdayView.weekdayLabels.enumerated() {
            label.text = weekdaySymbols[index]
            label.font = UIFont(name: "Pretendard-Regular", size: 12)
            label.textColor = UIColor(red: 0.42, green: 0.44, blue: 0.45, alpha: 1)
        }
    }
    
    private func setupCalendarHeaderView() {
        calendarHeaderView = CustomHeaderView()
        view.addSubview(calendarHeaderView)
        
        calendarHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarHeaderView.topAnchor.constraint(equalTo: calendarView.topAnchor),
            calendarHeaderView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            calendarHeaderView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            calendarHeaderView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        calendarHeaderView.previousButton.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        calendarHeaderView.nextButton.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        
        calendarView.calendarHeaderView.isHidden = true
    }
    
    private func setupCalendarAppearance() {
        calendarView.appearance.todayColor = UIColor.clear
        calendarView.appearance.todaySelectionColor = UIColor.clear
        calendarView.appearance.selectionColor = UIColor.clear
        calendarView.appearance.titleSelectionColor = UIColor.black
        calendarView.appearance.titleTodayColor = UIColor.black
    }
    
    private func updateHeaderViewForCurrentMonth() {
        let currentPage = calendarView.currentPage
        calendarHeaderView.updateMonthLabel(with: currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        showBottomSheet(for: date)
    }
    
    private func showBottomSheet(for date: Date) {
        let dayOfWeek = Calendar.current.component(.weekday, from: date) - 1
        let routinesForDay = RoutineDataModel.shared.routineData.filter { $0.1.contains(dayOfWeek) }
        
        if !routinesForDay.isEmpty {
            let bottomSheetVC = CalendarBottomSheetViewController()
            bottomSheetVC.modalPresentationStyle = .pageSheet
            bottomSheetVC.selectedDate = date
            bottomSheetVC.timeElapsed = savedTimeElapsed // timeElapsed 값을 전달
            
            if let sheet = bottomSheetVC.sheetPresentationController {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    return 547
                }
                sheet.detents = [customDetent]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 8
            }
            
            present(bottomSheetVC, animated: true, completion: nil)
        } else {
            // 루틴이 없는 경우의 처리
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            let formattedDate = dateFormatter.string(from: date)
            
            let alert = UIAlertController(title: "\(formattedDate)", message: "목표 루틴이 없습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(okAction)
            okAction.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
            
            present(alert, animated: true, completion: nil)
        }
    }

    
    @objc private func didTapPreviousMonthButton() {
        let currentPage = calendarView.currentPage
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentPage)!
        calendarView.setCurrentPage(previousMonth, animated: true)
        updateHeaderViewForCurrentMonth()  // Add this line
    }

    @objc private func didTapNextMonthButton() {
        let currentPage = calendarView.currentPage
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentPage)!
        calendarView.setCurrentPage(nextMonth, animated: true)
        updateHeaderViewForCurrentMonth()  // Add this line
    }

    
    @objc func handleLevelProgressUpdate() {
        // progress를 0.2씩 증가
        updateLevelProgress(by: 0.2)
    }
    
    // progress 값을 업데이트하는 메소드
    func updateLevelProgress(by increment: Float) {
        let newProgress = min(levelProgress.progress + increment, 1.0)
        levelProgress.setProgress(newProgress, animated: true)
        updateLevelNoticeLabel()
        
        if newProgress >= 1.0 {
            // progress가 1.0에 도달하면 userLevel 증가 및 progress 초기화
            LevelControlViewController.sharedData.userLevel += 1
            levelProgress.setProgress(0.0, animated: false) // progress를 0으로 초기화
            updateLevelLabel()
        } else {
            levelProgress.setProgress(newProgress, animated: true)
        }
    }
    
    private func updateLevelNoticeLabel() {
        // progress에 따라 표시할 숫자 계산
        let progressValues: [Float: Int] = [
            0.0: 5,
            0.2: 4,
            0.4: 3,
            0.6: 2,
            0.8: 1,
            1.0: 5
        ]
        // 현재 progress 값에 해당하는 숫자를 가져와 presentLevelLabel에 표시
        let currentProgress = round(levelProgress.progress * 5) / 5 // 가장 가까운 0.2 단위로 반올림
        let currentLabelValue = progressValues[currentProgress] ?? 0
        levelNoticeLabel.text = "다음 레벨업 도달 횟수까지 \(currentLabelValue)번 남았어요!"
    }
}

// MARK: - extension
extension MyPageViewController {
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTimeElapsedUpdate(_:)), name: .didPassTimeElapsed, object: nil)
    }
    
    @objc private func handleTimeElapsedUpdate(_ notification: Notification) {
        if let timeElapsed = notification.userInfo?["timeElapsed"] as? TimeInterval {
            savedTimeElapsed = timeElapsed
        }
    }
}

extension Notification.Name {
    static let didPassMaxBoosterTime = Notification.Name("didPassMaxBoosterTime")
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return routineData.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = routineTableView.dequeueReusableCell(withIdentifier: "GoalRoutineTableViewCell", for: indexPath) as? GoalRoutineTableViewCell else { return UITableViewCell() }
            let data = routineData[indexPath.row]
            cell.titleLabel.text = data.0
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = routineTableView.dequeueReusableCell(withIdentifier: "GoalRoutineAddTableViewCell", for: indexPath) as? GoalRoutineAddTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 56
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let editVC = storyboard?.instantiateViewController(withIdentifier: "GoalRoutineEditViewController") as! GoalRoutineEditViewController
            editVC.delegate = self
            editVC.routineIndex = indexPath.row
            editVC.routineData = routineData[indexPath.row]
            navigationController?.pushViewController(editVC, animated: true)
        } else {
            guard let GoalRoutineSettingVC = self.storyboard?.instantiateViewController(identifier: "GoalRoutineSettingViewController") else { return }
            self.navigationController?.pushViewController(GoalRoutineSettingVC, animated: true)
        }
    }
}

extension MyPageViewController: RoutineDataDelegate {
    func didReceiveData(_ data: (String, [Int], String, String)) {
        print("Received Data: \(data.0), \(data.1), \(data.2), \(data.3)")
        routineData.insert(data, at: 0)
        routineTableView.reloadData()
    }
}

extension MyPageViewController: RoutineDeleteDelegate {}

extension MyPageViewController: RoutineUpdateDelegate {
    func didUpdateRoutine() {
        routineData = RoutineDataModel.shared.routineData
        routineTableView.reloadData()
    }
}
