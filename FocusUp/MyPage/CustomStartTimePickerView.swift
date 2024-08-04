import UIKit

protocol CustomStartTimePickerDelegate: AnyObject {
    func didSelectStartTime(_ time: String)
    func didSelectStartTimeAndUpdateUI()
}

class CustomStartTimePickerView: UIView {
    weak var delegate: CustomStartTimePickerDelegate?
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.locale = Locale(identifier: "en_US_POSIX")
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(didTapCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(didTapDone))
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        containerView.addSubview(toolbar)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            toolbar.topAnchor.constraint(equalTo: containerView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
    }
    
    @objc private func didTapCancel() {
        self.removeFromSuperview()
    }
    
    @objc private func didTapDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // AM/PM 표시를 포함한 포맷
        let selectedTime = dateFormatter.string(from: datePicker.date)
        delegate?.didSelectStartTime(selectedTime)
        delegate?.didSelectStartTimeAndUpdateUI() // UI 업데이트 트리거
        self.removeFromSuperview()
    }
}
