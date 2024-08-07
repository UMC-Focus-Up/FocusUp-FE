//
//  MyPageViewController.swift
//  FocusUp
//
//  Created by 성호은 on 7/24/24.
//

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
    
    // MARK: - Outlets
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var goalRoutineLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
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
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendar()
        setupNotifications()
        updateLevelLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setWeekdayLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        configureTabBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
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
        
        updateProgressView(to: 0.2) // Initial progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.updateProgressView(to: 0.4) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.updateProgressView(to: 0.6) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self.updateProgressView(to: 0.8) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { self.updateProgressView(to: 1.0) }
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
    
    // MARK: - Actions
    @IBAction func didTapSettingBtn(_ sender: Any) {
        guard let toSettingVC = storyboard?.instantiateViewController(identifier: "SettingViewController") else { return }
        navigationController?.pushViewController(toSettingVC, animated: true)
    }
    
    @IBAction func didTapMoreBtn(_ sender: Any) {
        guard let toGoalRoutineListVC = storyboard?.instantiateViewController(identifier: "GoalRoutineListViewController") else { return }
        navigationController?.pushViewController(toGoalRoutineListVC, animated: true)
    }
    
    @IBAction func didTapAddNewRoutineBtn(_ sender: Any) {
        guard let toGoalRoutineSettingVC = storyboard?.instantiateViewController(identifier: "GoalRoutineSettingViewController") else { return }
        navigationController?.pushViewController(toGoalRoutineSettingVC, animated: true)
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        if let buttonType = notification.userInfo?["buttonType"] as? String, buttonType == "levelButton" {
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
    
    // MARK: - Helper Methods
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
    
    private func updateProgressView(to progress: Float) {
        levelProgress.setProgress(progress, animated: true)
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
    
    // MARK: - FSCalendar Delegate and DataSource Methods
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeaderViewForCurrentMonth()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return appearance.titleDefaultColor
    }
    
    @objc private func didTapPreviousMonthButton() {
        let currentPage = calendarView.currentPage
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentPage)!
        calendarView.setCurrentPage(previousMonth, animated: true)
    }
    
    @objc private func didTapNextMonthButton() {
        let currentPage = calendarView.currentPage
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentPage)!
        calendarView.setCurrentPage(nextMonth, animated: true)
    }
}

