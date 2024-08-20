import UIKit

protocol CustomTimePickerDelegate: AnyObject {
    func didSelectTime(_ time: String)
    func didSelectStartTimeAndUpdateUI()
    func didSelectGoalTimeAndUpdateUI()
}

class CustomTimePickerViewController: UIViewController {
    // MARK: - Property
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var is24HourFormat: Bool = true
    weak var delegate: CustomTimePickerDelegate?
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setFont()

        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        
        if is24HourFormat == true {
            picker.locale = Locale(identifier: "en_GB")
            let calendar = Calendar.current
            let components = DateComponents(hour: 0, minute: 0)
            if let defaultTime = calendar.date(from: components) {
                picker.setDate(defaultTime, animated: false)
            }
        } else if is24HourFormat == false {
            picker.locale = Locale(identifier: "en_US_POSIX")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        picker.setValue(UIColor.black, forKey: "textColor")
    }
    
    // MARK: - Function
    func setFont() {
        cancelButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        confirmButton.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
    }
    
    // MARK: - Action
    @IBAction func doneButtonTapped(_ sender: Any) {
        let selectedDate = picker.date
        let formatter = DateFormatter()
        formatter.dateFormat = is24HourFormat ? "HH:mm" : "h:mm a"
        let timeString = formatter.string(from: selectedDate)
        delegate?.didSelectTime(timeString)
        if is24HourFormat == true {
            delegate?.didSelectGoalTimeAndUpdateUI()
        } else if is24HourFormat == false {
            delegate?.didSelectStartTimeAndUpdateUI()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
