import UIKit

class GoalRoutineSettingViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var goalRoutineLabel: UILabel!
    @IBOutlet weak var goalRoutineTextField: UITextField!
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
    
    weak var delegate: RoutineDataDelegate?
    
    var goalRoutine: String = ""
    var repeatPeriodTags: [Int] = []
    var startTime: String = ""
    var goalTime: String = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttribute()
        setFont()
        setWeekStackViewButton()
        
        goalRoutineTextField.delegate = self
        if let listVC = navigationController?.viewControllers.first(where: {$0 is GoalRoutineListViewController}) as? GoalRoutineListViewController {
            delegate = listVC
    }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Function
    func setAttribute() {
        customTitleView()
        
        goalRoutineTextField.layer.borderColor = UIColor.blueGray3.cgColor
        goalRoutineTextField.layer.borderWidth = 1
        goalRoutineTextField.layer.cornerRadius = 8
        goalRoutineTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        goalRoutineTextField.leftViewMode = .always
        
        setTimeButtonAttribute(for: startTimeView)
        setTimeButtonAttribute(for: goalTimeView)
    }
    
    func setTimeButtonAttribute(for view: UIView) {
        view.layer.borderColor = UIColor.blueGray3.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
    }
    
    func setFont() {
        goalRoutineLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        goalRoutineTextField.font = UIFont(name: "Pretendard-Regular", size: 16)
        repeatPeriodLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        startTimeTitleLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        startTimeLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
        goalTimeTitleLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        goalTimeLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
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
        
        let rightBarButton: UIBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeButtonDidTap))
        
        if let buttonFont = UIFont(name: "Pretendard-Medium", size: 16) {
            rightBarButton.setTitleTextAttributes([.font: buttonFont], for: .normal)
            rightBarButton.setTitleTextAttributes([.font: buttonFont], for: .highlighted)
        }
        
        rightBarButton.tintColor = UIColor(named: "Primary4")
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func customTitleView() {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        let titleView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "목표 루틴 설정"
        titleLabel.font = UIFont(name: "Pretendard-Regular", size: 18)
        titleLabel.textColor = .black
        
        let customButton = UIButton(type: .system)
        if let informationImage = UIImage(named: "information") {
            customButton.setImage(informationImage, for: .normal)
        }
        customButton.addTarget(self, action: #selector(customButtonDidTap), for: .touchUpInside)
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(customButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        customButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            
            customButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            customButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            customButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            customButton.widthAnchor.constraint(equalToConstant: 24),
            customButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        titleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        self.navigationItem.titleView = titleView
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Action
    private func setWeekStackViewButton() {
        for case let button as UIButton in weekStackButton.arrangedSubviews {
            setButton(button)
        }
    }
    
    private func setButton(_ button: UIButton) {
        button.layer.cornerRadius = 21
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blueGray3.cgColor
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 13)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        UIView.performWithoutAnimation {
            if sender.isSelected {
                sender.isSelected = false
                sender.backgroundColor = UIColor.white
                sender.layer.borderColor = UIColor.blueGray4.cgColor
                sender.setTitleColor(UIColor.black, for: .normal)
                
                if let index = repeatPeriodTags.firstIndex(of: sender.tag) {
                    repeatPeriodTags.remove(at: index)
                }
            } else {
                sender.isSelected = true
                sender.backgroundColor = UIColor.primary4
                sender.layer.borderColor = UIColor.clear.cgColor
                sender.setTitleColor(UIColor.white, for: .normal)
                
                repeatPeriodTags.append(sender.tag)
            }
            sender.layoutIfNeeded()
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
    
    @objc func completeButtonDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "새로운 루틴을 추가하시겠습니까?", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
        alert.addAction(cancelAction)
        cancelAction.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.goalRoutine = self.goalRoutineTextField.text ?? ""
            self.startTime = self.startTimeLabel.text ?? ""
            self.goalTime = self.goalTimeLabel.text ?? ""
            let data: (String, [Int], String, String) = (self.goalRoutine, self.repeatPeriodTags, self.startTime, self.goalTime)
            self.delegate?.didReceiveData(data)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirmAction)
        confirmAction.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.preferredAction = confirmAction
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func customButtonDidTap(_ sender: UIButton) {
        print("Information.")
        
        guard let contentViewController = self.storyboard?.instantiateViewController(identifier: "InformationViewController") as? InformationViewController else { return }

        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: 230, cornerRadius: 26, dimmedAlpha: 1, isPannedable: false)
        
        self.present(bottomSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func setRoutineStartTime(_ sender: Any) {
        showCustomStartTimePicker()
    }
    
    @IBAction func setGoalTime(_ sender: Any) {
        showCustomGoalTimePicker()
    }
    
    private func showCustomStartTimePicker() {
        let customPickerView = CustomStartTimePickerView(frame: self.view.bounds)
        customPickerView.delegate = self
        self.view.addSubview(customPickerView)
    }
    
    private func showCustomGoalTimePicker() {
        let customPickerView = CustomGoalTimePickerView(frame: self.view.bounds)
        customPickerView.delegate = self
        self.view.addSubview(customPickerView)
    }
    
    private func updateStartTimeUI() {
        startTimeView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        startTimeLabel.textColor = UIColor.primary4
        startTimeButton.setImage(UIImage(named: "clock_after"), for: .normal)
    }
    
    private func updateGoalTimeUI() {
        goalTimeView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        goalTimeLabel.textColor = UIColor.primary4
        goalTimeButton.setImage(UIImage(named: "clock_after"), for: .normal)
    }
    
}

// MARK: - extension
extension GoalRoutineSettingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == goalRoutineTextField {
            textField.layer.borderColor = UIColor.primary4.cgColor
            textField.textColor = UIColor.primary4
            textField.tintColor = UIColor.primary4
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == goalRoutineTextField {
            textField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        }
    }
}

extension GoalRoutineSettingViewController: CustomStartTimePickerDelegate {
    func didSelectStartTime(_ time: String) {
        startTimeLabel.text = time
    }
    
    func didSelectStartTimeAndUpdateUI() {
        updateStartTimeUI()
    }
}

extension GoalRoutineSettingViewController: CustomGoalTimePickerDelegate {
    func didGoalSelectTime(_ time: String) {
        goalTimeLabel.text = time
    }
    
    func didSelectGoalTimeAndUpdateUI() {
        updateGoalTimeUI()
    }
}
